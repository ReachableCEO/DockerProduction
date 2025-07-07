#!/bin/bash
set -e

echo "Starting Consul Democracy..."

# Initialize the data directory if it doesn't exist
/app/code/init-data.sh

cd /app/code

# Setup environment variables
export DATABASE_URL="postgresql://${CLOUDRON_POSTGRESQL_USERNAME}:${CLOUDRON_POSTGRESQL_PASSWORD}@${CLOUDRON_POSTGRESQL_HOST}:${CLOUDRON_POSTGRESQL_PORT}/${CLOUDRON_POSTGRESQL_DATABASE}"
export SECRET_KEY_BASE=$(cat /app/data/secret_key_base)
export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=true
export RAILS_LOG_TO_STDOUT=true

# Configure email settings
export SMTP_ADDRESS=${CLOUDRON_MAIL_SMTP_SERVER}
export SMTP_PORT=${CLOUDRON_MAIL_SMTP_PORT}
export SMTP_DOMAIN=${CLOUDRON_APP_DOMAIN}
export SMTP_USER_NAME=${CLOUDRON_MAIL_SMTP_USERNAME}
export SMTP_PASSWORD=${CLOUDRON_MAIL_SMTP_PASSWORD}

# LDAP Setup for Cloudron integration
export LDAP_HOST=${CLOUDRON_LDAP_SERVER}
export LDAP_PORT=${CLOUDRON_LDAP_PORT}
export LDAP_ADMIN_USER=${CLOUDRON_LDAP_BIND_DN}
export LDAP_ADMIN_PASSWORD=${CLOUDRON_LDAP_BIND_PASSWORD}
export LDAP_BASE=${CLOUDRON_LDAP_USERS_BASE_DN}

# Run db migrations if needed
echo "Running database migrations..."
bundle exec rake db:migrate

# Seed the database if it's the first run
if [ ! -f /app/data/.initialized ]; then
  echo "First run detected, seeding the database..."
  bundle exec rake db:seed
  touch /app/data/.initialized
fi

# Start the application server via supervisord
echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf