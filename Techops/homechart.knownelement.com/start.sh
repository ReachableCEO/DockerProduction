#!/bin/bash
set -e

# Create required runtime directories
mkdir -p /run/nginx/body /run/nginx/proxy /run/nginx/fastcgi /run/nginx/uwsgi /run/nginx/scgi
chown -R cloudron:cloudron /run/nginx

# Initialize data directory if not existing
if [ ! -d "/app/data/config" ]; then
    mkdir -p /app/data/config
    chown -R cloudron:cloudron /app/data
fi

# Configuration
CONFIG_FILE="/app/data/config/homechart.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating initial configuration file..."
    cat > "$CONFIG_FILE" <<EOL
{
  "app": {
    "baseURL": "${CLOUDRON_APP_ORIGIN}",
    "proxyAddr": "127.0.0.1, 172.18.0.1"
  },
  "postgresql": {
    "hostname": "${CLOUDRON_POSTGRESQL_HOST}",
    "username": "${CLOUDRON_POSTGRESQL_USERNAME}",
    "password": "${CLOUDRON_POSTGRESQL_PASSWORD}",
    "database": "${CLOUDRON_POSTGRESQL_DATABASE}"
  },
  "oidc": {
    "cloudron": {
      "clientID": "${CLOUDRON_OIDC_CLIENT_ID}",
      "clientSecret": "${CLOUDRON_OIDC_CLIENT_SECRET}",
      "displayName": "Cloudron",
      "oidcIssuerURL": "${CLOUDRON_OIDC_ISSUER}"
    }
  },
  "logging": {
    "level": "info"
  }
}
EOL
    chown cloudron:cloudron "$CONFIG_FILE"
fi

# Link HomeChart configuration
export HOMECHART_CONFIG_FILE="$CONFIG_FILE"

# Set the port for HomeChart to run on (internal port)
export HOMECHART_APP_PORT=8000

# Start supervisor which manages nginx and homechart
exec /usr/bin/supervisord --configuration /etc/supervisor/supervisord.conf