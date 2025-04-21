#!/bin/bash

set -eu

# Setup runtime environment
echo "Setting up Rundeck runtime environment..."

# Initialize data directories if they don't exist
for dir in etc server/data var/logs projects libext .ssh; do
    if [ ! -d "/app/data/$dir" ]; then
        mkdir -p "/app/data/$dir"
        if [ -d "/tmp/data/$dir" ] && [ -n "$(ls -A "/tmp/data/$dir" 2>/dev/null)" ]; then
            cp -r "/tmp/data/$dir/"* "/app/data/$dir/"
        fi
    fi
done

# Setup database connection
DB_URL="jdbc:postgresql://${CLOUDRON_POSTGRESQL_HOST}:${CLOUDRON_POSTGRESQL_PORT}/${CLOUDRON_POSTGRESQL_DATABASE}?user=${CLOUDRON_POSTGRESQL_USERNAME}&password=${CLOUDRON_POSTGRESQL_PASSWORD}"
export RUNDECK_SERVER_DATASTORE_URL="$DB_URL"
export RUNDECK_DATABASE_URL="$DB_URL"
export RUNDECK_DATABASE_DRIVER="org.postgresql.Driver"
export RUNDECK_DATABASE_USERNAME="${CLOUDRON_POSTGRESQL_USERNAME}"
export RUNDECK_DATABASE_PASSWORD="${CLOUDRON_POSTGRESQL_PASSWORD}"

# Generate initial admin password if not exists
if ! grep -q "^admin:" /app/data/etc/realm.properties 2>/dev/null; then
    PASSWORD=$(openssl rand -hex 8)
    echo "admin:admin,user,admin" > /app/data/etc/realm.properties
    sed -i "s|{{ .password }}|$PASSWORD|g" /run/cloudron/app.json
else
    sed -i "s|{{ .password }}|<existing password>|g" /run/cloudron/app.json
fi

# Update configurations
if [ -f "/app/data/etc/framework.properties" ]; then
    # Set domain in framework.properties
    sed -i "s|framework.server.url = .*|framework.server.url = https://${CLOUDRON_APP_DOMAIN}|g" /app/data/etc/framework.properties
    sed -i "s|framework.server.hostname = .*|framework.server.hostname = ${CLOUDRON_APP_DOMAIN}|g" /app/data/etc/framework.properties
fi

if [ -f "/app/data/etc/rundeck-config.properties" ]; then
    # Update database connection in rundeck-config.properties
    sed -i "s|dataSource.url = .*|dataSource.url = ${RUNDECK_SERVER_DATASTORE_URL}|g" /app/data/etc/rundeck-config.properties
    sed -i "s|grails.serverURL = .*|grails.serverURL = https://${CLOUDRON_APP_DOMAIN}|g" /app/data/etc/rundeck-config.properties
fi

# Configure authentication
if [[ -n "${CLOUDRON_OAUTH_IDENTIFIER:-}" ]]; then
    echo "Configuring OAuth/OIDC authentication..."
    export RUNDECK_SECURITY_OAUTH_ENABLED=true
    export RUNDECK_SECURITY_OAUTH_CLIENTID="${CLOUDRON_OAUTH_CLIENT_ID}"
    export RUNDECK_SECURITY_OAUTH_CLIENTSECRET="${CLOUDRON_OAUTH_CLIENT_SECRET}"
    export RUNDECK_SECURITY_OAUTH_AUTHORIZEURL="${CLOUDRON_OAUTH_ORIGIN}/auth/realms/${CLOUDRON_OAUTH_IDENTIFIER}/protocol/openid-connect/auth"
    export RUNDECK_SECURITY_OAUTH_TOKENURL="${CLOUDRON_OAUTH_ORIGIN}/auth/realms/${CLOUDRON_OAUTH_IDENTIFIER}/protocol/openid-connect/token"
    export RUNDECK_SECURITY_OAUTH_USERINFOURI="${CLOUDRON_OAUTH_ORIGIN}/auth/realms/${CLOUDRON_OAUTH_IDENTIFIER}/protocol/openid-connect/userinfo"
    
    cp /tmp/data/etc/jaas-oidc.conf /app/data/etc/jaas-oidc.conf
    export RUNDECK_JAASLOGIN=true
    export RDECK_JVM_OPTS="${RDECK_JVM_OPTS:-} -Drundeck.jaaslogin=true -Dloginmodule.name=oauth -Djava.security.auth.login.config=/app/data/etc/jaas-oidc.conf"
    
    # Add necessary properties to rundeck-config.properties
    echo "rundeck.security.oauth.enabled=true" >> /app/data/etc/rundeck-config.properties
    echo "rundeck.security.oauth.clientId=${CLOUDRON_OAUTH_CLIENT_ID}" >> /app/data/etc/rundeck-config.properties
    echo "rundeck.security.oauth.clientSecret=${CLOUDRON_OAUTH_CLIENT_SECRET}" >> /app/data/etc/rundeck-config.properties
    echo "rundeck.security.oauth.authorizeUrl=${CLOUDRON_OAUTH_ORIGIN}/auth/realms/${CLOUDRON_OAUTH_IDENTIFIER}/protocol/openid-connect/auth" >> /app/data/etc/rundeck-config.properties
    echo "rundeck.security.oauth.tokenUrl=${CLOUDRON_OAUTH_ORIGIN}/auth/realms/${CLOUDRON_OAUTH_IDENTIFIER}/protocol/openid-connect/token" >> /app/data/etc/rundeck-config.properties
    echo "rundeck.security.oauth.userInfoUri=${CLOUDRON_OAUTH_ORIGIN}/auth/realms/${CLOUDRON_OAUTH_IDENTIFIER}/protocol/openid-connect/userinfo" >> /app/data/etc/rundeck-config.properties
    echo "rundeck.security.oauth.autoCreateUsers=true" >> /app/data/etc/rundeck-config.properties
    echo "rundeck.security.oauth.defaultRoles=user" >> /app/data/etc/rundeck-config.properties
elif [[ -n "${CLOUDRON_LDAP_SERVER:-}" ]]; then
    echo "Configuring LDAP authentication..."
    cp /tmp/data/etc/jaas-ldap.conf /app/data/etc/jaas-ldap.conf
    
    # Replace placeholders in JAAS config
    sed -i "s|{{ldap.url}}|${CLOUDRON_LDAP_SERVER}:${CLOUDRON_LDAP_PORT}|g" /app/data/etc/jaas-ldap.conf
    sed -i "s|{{ldap.bindDn}}|${CLOUDRON_LDAP_BIND_DN}|g" /app/data/etc/jaas-ldap.conf
    sed -i "s|{{ldap.bindPassword}}|${CLOUDRON_LDAP_BIND_PASSWORD}|g" /app/data/etc/jaas-ldap.conf
    sed -i "s|{{ldap.userBaseDn}}|${CLOUDRON_LDAP_USERS_BASE_DN}|g" /app/data/etc/jaas-ldap.conf
    sed -i "s|{{ldap.groupBaseDn}}|${CLOUDRON_LDAP_GROUPS_BASE_DN}|g" /app/data/etc/jaas-ldap.conf
    
    export RUNDECK_JAASLOGIN=true
    export RDECK_JVM_OPTS="${RDECK_JVM_OPTS:-} -Drundeck.jaaslogin=true -Dloginmodule.name=ldap -Djava.security.auth.login.config=/app/data/etc/jaas-ldap.conf"
    
    # Enable JAAS LDAP in rundeck-config.properties
    echo "rundeck.security.jaasLoginModuleName=ldap" >> /app/data/etc/rundeck-config.properties
    echo "rundeck.security.jaasProviderName=ldap" >> /app/data/etc/rundeck-config.properties
    echo "rundeck.jaaslogin=true" >> /app/data/etc/rundeck-config.properties
    echo "rundeck.feature.caseInsensitiveUsername.enabled=true" >> /app/data/etc/rundeck-config.properties
    echo "rundeck.security.syncLdapUser=true" >> /app/data/etc/rundeck-config.properties
else
    # Use file-based authentication
    echo "Using file-based authentication..."
    export RDECK_JVM_OPTS="${RDECK_JVM_OPTS:-} -Drundeck.jaaslogin=true -Dloginmodule.name=file -Djava.security.auth.login.config=/app/data/etc/jaas-file.conf"
    echo 'RDpropertyfilelogin { org.eclipse.jetty.jaas.spi.PropertyFileLoginModule required debug="true" file="/app/data/etc/realm.properties"; };' > /app/data/etc/jaas-file.conf
    echo "rundeck.security.jaasLoginModuleName=file" >> /app/data/etc/rundeck-config.properties
    echo "rundeck.security.jaasProviderName=file" >> /app/data/etc/rundeck-config.properties
fi

# Set permissions
chown -R cloudron:cloudron /app/data

echo "Starting Rundeck services..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf