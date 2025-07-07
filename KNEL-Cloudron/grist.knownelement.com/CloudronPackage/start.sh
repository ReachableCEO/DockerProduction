#!/bin/bash
set -e

# Cloudron environment variables
export GRIST_APP_ROOT="/app/pkg/grist-core"
export GRIST_DATA_DIR="/app/data/docs"
export GRIST_SESSION_SECRET="${CLOUDRON_SESSION_SECRET}"
export APP_HOME_URL="${CLOUDRON_APP_URL}"
export GRIST_DOMAIN="${CLOUDRON_APP_DOMAIN}"
export GRIST_SINGLE_ORG="cloudron"
export GRIST_HIDE_UI_ELEMENTS="billing"
export GRIST_MAX_UPLOAD_ATTACHMENT_MB=100
export GRIST_MAX_UPLOAD_IMPORT_MB=300
export GRIST_SANDBOX_FLAVOR="gvisor"
export GRIST_USER_ROOT="/app/data"
export GRIST_THROTTLE_CPU="true"
export GRIST_DEFAULT_EMAIL="${CLOUDRON_ADMIN_EMAIL}"
export GRIST_FORCE_LOGIN="true"
export GRIST_SUPPORT_ANON="false"
export COOKIE_MAX_AGE=2592000000 # 30 days in milliseconds

# Setup OpenID Connect for Cloudron authentication
export GRIST_OIDC_IDP_ISSUER="${CLOUDRON_APP_ORIGIN}"
export GRIST_OIDC_IDP_CLIENT_ID="${CLOUDRON_OAUTH_CLIENT_ID}"
export GRIST_OIDC_IDP_CLIENT_SECRET="${CLOUDRON_OAUTH_CLIENT_SECRET}"
export GRIST_OIDC_IDP_SCOPES="openid profile email"
export GRIST_OIDC_SP_HOST="${CLOUDRON_APP_URL}"
export GRIST_OIDC_SP_PROFILE_EMAIL_ATTR="email"
export GRIST_OIDC_SP_PROFILE_NAME_ATTR="name"
export GRIST_OIDC_IDP_ENABLED_PROTECTIONS="PKCE,STATE"

# Database configuration using Cloudron PostgreSQL addon
export TYPEORM_TYPE="postgres"
export TYPEORM_DATABASE="${CLOUDRON_POSTGRESQL_DATABASE}"
export TYPEORM_USERNAME="${CLOUDRON_POSTGRESQL_USERNAME}"
export TYPEORM_PASSWORD="${CLOUDRON_POSTGRESQL_PASSWORD}"
export TYPEORM_HOST="${CLOUDRON_POSTGRESQL_HOST}"
export TYPEORM_PORT="${CLOUDRON_POSTGRESQL_PORT}"
export TYPEORM_LOGGING="false"

# Initialize or update data directories if they don't exist
if [ ! -d "/app/data/docs" ]; then
    mkdir -p /app/data/docs
    echo "Created docs directory"
fi

if [ ! -d "/app/data/home" ]; then
    mkdir -p /app/data/home
    echo "Created home directory"
fi

# Copy initialization data if needed
if [ -d "/app/pkg/init_data" ] && [ ! -f "/app/data/.initialized" ]; then
    cp -R /app/pkg/init_data/* /app/data/
    touch /app/data/.initialized
    echo "Copied initialization data"
fi

# Ensure proper permissions
chown -R cloudron:cloudron /app/data

# Start supervisor to manage Grist and Nginx
exec /usr/bin/supervisord --nodaemon -c /etc/supervisor/supervisord.conf