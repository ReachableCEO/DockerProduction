#!/bin/bash
set -e

# Create directory structure if it doesn't exist
if [ ! -d /app/data/uploads ]; then
    mkdir -p /app/data/uploads
    cp -r /tmp/data/uploads/* /app/data/uploads/ 2>/dev/null || true
    chown -R cloudron:cloudron /app/data/uploads
fi

if [ ! -d /app/data/logs ]; then
    mkdir -p /app/data/logs
    cp -r /tmp/data/logs/* /app/data/logs/ 2>/dev/null || true
    chown -R cloudron:cloudron /app/data/logs
fi

if [ ! -f /app/data/config/config.yml ]; then
    mkdir -p /app/data/config
    cp -r /tmp/data/config/* /app/data/config/ 2>/dev/null || true
    
    # Configure database connection
    sed -i "s/host: .*/host: ${CLOUDRON_MYSQL_HOST}/" /app/data/config/config.yml
    sed -i "s/port: .*/port: ${CLOUDRON_MYSQL_PORT}/" /app/data/config/config.yml
    sed -i "s/database: .*/database: ${CLOUDRON_MYSQL_DATABASE}/" /app/data/config/config.yml
    sed -i "s/username: .*/username: ${CLOUDRON_MYSQL_USERNAME}/" /app/data/config/config.yml
    sed -i "s/password: .*/password: ${CLOUDRON_MYSQL_PASSWORD}/" /app/data/config/config.yml
    
    # Configure paths
    sed -i "s|uploads: .*|uploads: /app/data/uploads|" /app/data/config/config.yml
    sed -i "s|logs: .*|logs: /app/data/logs|" /app/data/config/config.yml
    
    # Configure LDAP if enabled
    if [ "${CLOUDRON_LDAP_ENABLED}" == "true" ]; then
        # Update LDAP settings in config
        sed -i "s/ldap_enabled: .*/ldap_enabled: true/" /app/data/config/config.yml
        sed -i "s/ldap_host: .*/ldap_host: ${CLOUDRON_LDAP_SERVER}/" /app/data/config/config.yml
        sed -i "s/ldap_port: .*/ldap_port: ${CLOUDRON_LDAP_PORT}/" /app/data/config/config.yml
        sed -i "s/ldap_username: .*/ldap_username: ${CLOUDRON_LDAP_BIND_DN}/" /app/data/config/config.yml
        sed -i "s/ldap_password: .*/ldap_password: ${CLOUDRON_LDAP_BIND_PASSWORD}/" /app/data/config/config.yml
        sed -i "s/ldap_base_dn: .*/ldap_base_dn: ${CLOUDRON_LDAP_USERS_BASE_DN}/" /app/data/config/config.yml
    fi
    
    chown -R cloudron:cloudron /app/data/config
fi

# Create a symlink to the config file
ln -sf /app/data/config/config.yml /app/code/config.yml

# Set proper permissions
chown -R cloudron:cloudron /app/data

# Start the supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf