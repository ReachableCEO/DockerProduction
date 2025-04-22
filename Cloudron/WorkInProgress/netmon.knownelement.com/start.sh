#!/bin/bash

set -eu

# Setup directories
if [ ! -d "/app/data/rrd" ] || [ -z "$(ls -A /app/data/rrd)" ]; then
    echo "First run, initializing data directories..."
    mkdir -p /app/data/rrd
    mkdir -p /app/data/logs
    mkdir -p /app/data/config
    mkdir -p /app/data/plugins
    
    # Copy initial configurations if they don't exist
    if [ ! -f "/app/data/config/config.php" ]; then
        cp /tmp/data/config/config.php /app/data/config/
    fi
fi

# Create necessary log files
touch /app/data/logs/librenms.log
touch /app/data/logs/auth.log
touch /app/data/logs/discovery.log
touch /app/data/logs/poller.log

# Environment variables for database and redis
export DB_HOST=${CLOUDRON_MYSQL_HOST}
export DB_PORT=${CLOUDRON_MYSQL_PORT}
export DB_USER=${CLOUDRON_MYSQL_USERNAME}
export DB_PASS=${CLOUDRON_MYSQL_PASSWORD}
export DB_NAME=${CLOUDRON_MYSQL_DATABASE}
export REDIS_HOST=${CLOUDRON_REDIS_HOST}
export REDIS_PORT=${CLOUDRON_REDIS_PORT}
export REDIS_DB=0
export REDIS_PASS=${CLOUDRON_REDIS_PASSWORD}
export APP_URL=https://${CLOUDRON_APP_DOMAIN}

# Set up OIDC authentication if enabled
if [[ -n "${CLOUDRON_OIDC_IDENTIFIER:-}" ]]; then
    echo "Configuring OIDC authentication..."
    sed -i "s|'auth_mechanism' => 'mysql'|'auth_mechanism' => 'socialite'|g" /app/data/config/config.php
    
    # Add OIDC configuration
    cat >> /app/data/config/config.php << EOF
\$config['auth_socialite_oidc']['enabled'] = true;
\$config['auth_socialite_oidc']['client_id'] = '${CLOUDRON_OIDC_CLIENT_ID}';
\$config['auth_socialite_oidc']['client_secret'] = '${CLOUDRON_OIDC_CLIENT_SECRET}';
\$config['auth_socialite_oidc']['authorize_url'] = '${CLOUDRON_OIDC_ISSUER}/auth';
\$config['auth_socialite_oidc']['token_url'] = '${CLOUDRON_OIDC_ISSUER}/token';
\$config['auth_socialite_oidc']['userinfo_url'] = '${CLOUDRON_OIDC_ISSUER}/userinfo';
\$config['auth_socialite_oidc']['scope'] = 'openid email profile groups';
\$config['auth_socialite_oidc']['redirect'] = 'https://${CLOUDRON_APP_DOMAIN}/auth/oidc/callback';
EOF
fi

# Set up LDAP authentication if enabled and OIDC is not enabled
if [[ -z "${CLOUDRON_OIDC_IDENTIFIER:-}" && -n "${CLOUDRON_LDAP_SERVER:-}" ]]; then
    echo "Configuring LDAP authentication..."
    sed -i "s|'auth_mechanism' => 'mysql'|'auth_mechanism' => 'ldap'|g" /app/data/config/config.php
    
    # Add LDAP configuration
    cat >> /app/data/config/config.php << EOF
\$config['auth_ldap_server'] = '${CLOUDRON_LDAP_SERVER}';
\$config['auth_ldap_port'] = ${CLOUDRON_LDAP_PORT};
\$config['auth_ldap_version'] = 3;
\$config['auth_ldap_starttls'] = true;
\$config['auth_ldap_prefix'] = '${CLOUDRON_LDAP_BIND_DN%%,*}';
\$config['auth_ldap_suffix'] = ',${CLOUDRON_LDAP_BIND_DN#*,}';
\$config['auth_ldap_group'] = '${CLOUDRON_LDAP_USERS_GROUP_DN}';
\$config['auth_ldap_groupbase'] = '${CLOUDRON_LDAP_GROUPS_BASE_DN}';
\$config['auth_ldap_groups']['admin']['level'] = 10;
\$config['auth_ldap_groups']['admin']['group'] = '${CLOUDRON_LDAP_ADMINS_GROUP_DN}';
EOF
fi

# Fix permissions
chown -R cloudron:cloudron /app/data

# Initialize database if needed
echo "Checking database..."
if ! mysql -h "${CLOUDRON_MYSQL_HOST}" -P "${CLOUDRON_MYSQL_PORT}" -u "${CLOUDRON_MYSQL_USERNAME}" -p"${CLOUDRON_MYSQL_PASSWORD}" -e "USE ${CLOUDRON_MYSQL_DATABASE}" 2>/dev/null; then
    echo "Setting up database schema..."
    cd /app/code
    php build-base.php
fi

# Apply database updates if needed
cd /app/code
php includes/sql-schema/update.php

# Create admin user on first run if authentication is MySQL
if [[ ! -n "${CLOUDRON_OIDC_IDENTIFIER:-}" && ! -n "${CLOUDRON_LDAP_SERVER:-}" ]]; then
    if ! mysql -h "${CLOUDRON_MYSQL_HOST}" -P "${CLOUDRON_MYSQL_PORT}" -u "${CLOUDRON_MYSQL_USERNAME}" -p"${CLOUDRON_MYSQL_PASSWORD}" -e "SELECT username FROM users WHERE username='admin'" ${CLOUDRON_MYSQL_DATABASE} 2>/dev/null | grep -q admin; then
        echo "Creating admin user..."
        php adduser.php admin admin 10 admin@localhost
    fi
fi

# Link config file
ln -sf /app/data/config/config.php /app/code/config.php

# Setup cron jobs
echo "Setting up cron jobs..."
cat > /etc/cron.d/librenms << EOF
# Run a complete discovery of all devices once every 6 hours
33  */6 * * *   cloudron   cd /app/code/ && php discovery.php -h all >> /app/data/logs/discovery-all.log 2>&1
# Run a complete poll of all devices once every 5 minutes
*/5 *   * * *   cloudron   cd /app/code/ && php poller.php -h all >> /app/data/logs/poll-all.log 2>&1
# Run hourly maintenance tasks
15  *   * * *   cloudron   cd /app/code/ && php daily.php >> /app/data/logs/daily.log 2>&1
# Run daily maintenance tasks
15  0   * * *   cloudron   cd /app/code/ && php daily.sh >> /app/data/logs/daily.log 2>&1
# Check services
*/5 *   * * *   cloudron   cd /app/code/ && php check-services.php >> /app/data/logs/check-services.log 2>&1
# Process alerts
*/5 *   * * *   cloudron   cd /app/code/ && php alerts.php >> /app/data/logs/alerts.log 2>&1
# Poll billing
*/5 *   * * *   cloudron   cd /app/code/ && php poll-billing.php >> /app/data/logs/poll-billing.log 2>&1
# Generate billing data
01  *   * * *   cloudron   cd /app/code/ && php billing-calculate.php >> /app/data/logs/billing-calculate.log 2>&1
# Update device groups
*/5 *   * * *   cloudron   cd /app/code/ && php update-device-groups.php >> /app/data/logs/update-device-groups.log 2>&1
EOF

# Start supervisord to manage all processes
echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf