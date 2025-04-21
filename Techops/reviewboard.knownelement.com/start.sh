#!/bin/bash
set -e

# Create data directories if they don't exist
if [ ! -f /app/data/.initialized ]; then
    echo "Initializing Review Board data directories..."
    
    # Create directories
    mkdir -p /app/data/conf
    mkdir -p /app/data/media
    mkdir -p /app/data/static
    mkdir -p /app/data/logs
    
    # Generate a random admin password and save it
    ADMIN_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)
    echo $ADMIN_PASSWORD > /app/data/admin_password.txt
    chmod 640 /app/data/admin_password.txt
    
    # Mark as initialized
    touch /app/data/.initialized
    echo "Initialization complete."
fi

# Set proper ownership
chown -R cloudron:cloudron /app/data

# Configure database connection
if [ ! -f /app/data/conf/settings_local.py ]; then
    echo "Creating Review Board configuration..."
    
    # Get database connection details from CLOUDRON_POSTGRESQL_URL
    DB_HOST=$(echo "${CLOUDRON_POSTGRESQL_URL}" | cut -d@ -f2 | cut -d/ -f1)
    DB_NAME=$(echo "${CLOUDRON_POSTGRESQL_URL}" | cut -d/ -f4)
    DB_USER=$(echo "${CLOUDRON_POSTGRESQL_URL}" | cut -d/ -f3 | cut -d: -f1)
    DB_PASSWORD=$(echo "${CLOUDRON_POSTGRESQL_URL}" | cut -d: -f3 | cut -d@ -f1)
    
    # Create settings_local.py
    cat > /app/data/conf/settings_local.py << EOF
# Cloudron Review Board Settings
import os

# Database settings
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': '${DB_NAME}',
        'USER': '${DB_USER}',
        'PASSWORD': '${DB_PASSWORD}',
        'HOST': '${DB_HOST}',
    }
}

# Site settings
SITE_ROOT = '/'
MEDIA_ROOT = '/app/data/media'
STATIC_ROOT = '/app/data/static'

# Email settings
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'mail'
EMAIL_PORT = 25
DEFAULT_FROM_EMAIL = 'reviewboard@${CLOUDRON_APP_DOMAIN}'
SERVER_EMAIL = 'reviewboard@${CLOUDRON_APP_DOMAIN}'

# Cache settings
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
    }
}
EOF
    
    # Add authentication settings based on Cloudron's environment
    if [ -n "${CLOUDRON_LDAP_SERVER}" ]; then
        # LDAP Authentication
        cat >> /app/data/conf/settings_local.py << EOF
# LDAP Authentication
AUTHENTICATION_BACKENDS = (
    'django_auth_ldap.backend.LDAPBackend',
    'django.contrib.auth.backends.ModelBackend',
)

import ldap
from django_auth_ldap.config import LDAPSearch, GroupOfNamesType

AUTH_LDAP_SERVER_URI = "ldap://${CLOUDRON_LDAP_SERVER}:${CLOUDRON_LDAP_PORT}"
AUTH_LDAP_BIND_DN = "${CLOUDRON_LDAP_BIND_DN}"
AUTH_LDAP_BIND_PASSWORD = "${CLOUDRON_LDAP_BIND_PASSWORD}"
AUTH_LDAP_USER_SEARCH = LDAPSearch(
    "${CLOUDRON_LDAP_USERS_BASE_DN}",
    ldap.SCOPE_SUBTREE,
    "(${CLOUDRON_LDAP_USERNAME_FIELD}=%(user)s)"
)
AUTH_LDAP_GROUP_SEARCH = LDAPSearch(
    "${CLOUDRON_LDAP_GROUPS_BASE_DN}",
    ldap.SCOPE_SUBTREE,
    "(objectClass=groupOfNames)"
)
AUTH_LDAP_GROUP_TYPE = GroupOfNamesType()
AUTH_LDAP_USER_ATTR_MAP = {
    "first_name": "givenName",
    "last_name": "sn",
    "email": "mail"
}
AUTH_LDAP_ALWAYS_UPDATE_USER = True
EOF
    elif [ -n "${CLOUDRON_OIDC_IDENTIFIER}" ]; then
        # OIDC Authentication
        cat >> /app/data/conf/settings_local.py << EOF
# OIDC Authentication
AUTHENTICATION_BACKENDS = (
    'mozilla_django_oidc.auth.OIDCAuthenticationBackend',
    'django.contrib.auth.backends.ModelBackend',
)

OIDC_RP_CLIENT_ID = "${CLOUDRON_OIDC_CLIENT_ID}"
OIDC_RP_CLIENT_SECRET = "${CLOUDRON_OIDC_CLIENT_SECRET}"
OIDC_OP_AUTHORIZATION_ENDPOINT = "${CLOUDRON_OIDC_ENDPOINT}/authorize"
OIDC_OP_TOKEN_ENDPOINT = "${CLOUDRON_OIDC_ENDPOINT}/token"
OIDC_OP_USER_ENDPOINT = "${CLOUDRON_OIDC_ENDPOINT}/userinfo"
OIDC_OP_JWKS_ENDPOINT = "${CLOUDRON_OIDC_ENDPOINT}/jwks"
OIDC_AUTHENTICATE_CLASS = 'mozilla_django_oidc.views.OIDCAuthenticationRequestView'
OIDC_CALLBACK_CLASS = 'mozilla_django_oidc.views.OIDCAuthenticationCallbackView'
LOGIN_REDIRECT_URL = '/'
LOGOUT_REDIRECT_URL = '/'

def oidc_username_transform(username):
    return username.split('@')[0]

OIDC_USERNAME_ALGO = oidc_username_transform
EOF
    fi
fi

# Initialize the Review Board site if not already done
if [ ! -f /app/data/.db_initialized ]; then
    echo "Setting up the Review Board site..."
    
    # Get database connection details
    DB_HOST=$(echo "${CLOUDRON_POSTGRESQL_URL}" | cut -d@ -f2 | cut -d/ -f1)
    DB_NAME=$(echo "${CLOUDRON_POSTGRESQL_URL}" | cut -d/ -f4)
    DB_USER=$(echo "${CLOUDRON_POSTGRESQL_URL}" | cut -d/ -f3 | cut -d: -f1)
    DB_PASSWORD=$(echo "${CLOUDRON_POSTGRESQL_URL}" | cut -d: -f3 | cut -d@ -f1)
    
    # Create a site directory for Review Board
    rb-site install --noinput \
        --domain-name=${CLOUDRON_APP_DOMAIN} \
        --site-root=/ \
        --static-url=static/ \
        --media-url=media/ \
        --db-type=postgresql \
        --db-name=${DB_NAME} \
        --db-user=${DB_USER} \
        --db-pass=${DB_PASSWORD} \
        --db-host=${DB_HOST} \
        --cache-type=memcached \
        --cache-info=localhost:11211 \
        --web-server-type=wsgi \
        --admin-user=admin \
        --admin-password=$(cat /app/data/admin_password.txt) \
        --admin-email=admin@${CLOUDRON_APP_DOMAIN} \
        /app/data/site
    
    # Copy settings_local.py to the site
    cp /app/data/conf/settings_local.py /app/data/site/conf/settings_local.py
    
    # Mark as initialized
    touch /app/data/.db_initialized
    echo "Database initialization complete."
fi

# Collect static files if they don't exist yet
if [ ! -f /app/data/.static_collected ]; then
    echo "Collecting static files..."
    cd /app/data/site
    PYTHONPATH=/app/data/site python /app/data/site/manage.py collectstatic --noinput
    touch /app/data/.static_collected
    echo "Static files collected."
fi

# Configure NGINX to use the static and media directories
sed -i "s|CLOUDRON_APP_DOMAIN|${CLOUDRON_APP_DOMAIN}|g" /etc/nginx/sites-available/default

# Start services using supervisord
echo "Starting Review Board..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf