#!/bin/bash
set -e

# PostgreSQL configuration from Cloudron environment variables
if [ -n "${CLOUDRON_POSTGRESQL_HOST}" ]; then
    export INVENTREE_DB_ENGINE="postgresql"
    export INVENTREE_DB_NAME="${CLOUDRON_POSTGRESQL_DATABASE}"
    export INVENTREE_DB_USER="${CLOUDRON_POSTGRESQL_USERNAME}"
    export INVENTREE_DB_PASSWORD="${CLOUDRON_POSTGRESQL_PASSWORD}"
    export INVENTREE_DB_HOST="${CLOUDRON_POSTGRESQL_HOST}"
    export INVENTREE_DB_PORT="${CLOUDRON_POSTGRESQL_PORT}"
else
    echo "PostgreSQL addon not configured!"
    exit 1
fi

# Ensure data directories exist
if [ ! -d "${INVENTREE_HOME}/media" ]; then
    echo "Creating media directory..."
    mkdir -p "${INVENTREE_HOME}/media"
    cp -rn /tmp/data/media/* "${INVENTREE_HOME}/media/" || true
fi

if [ ! -d "${INVENTREE_HOME}/static" ]; then
    echo "Creating static directory..."
    mkdir -p "${INVENTREE_HOME}/static"
    cp -rn /tmp/data/static/* "${INVENTREE_HOME}/static/" || true
fi

if [ ! -d "${INVENTREE_HOME}/plugins" ]; then
    echo "Creating plugins directory..."
    mkdir -p "${INVENTREE_HOME}/plugins"
    cp -rn /tmp/data/plugins/* "${INVENTREE_HOME}/plugins/" || true
fi

if [ ! -d "${INVENTREE_HOME}/config" ]; then
    echo "Creating config directory..."
    mkdir -p "${INVENTREE_HOME}/config"
    cp -rn /tmp/data/config/* "${INVENTREE_HOME}/config/" || true
fi

# Generate secret key if it doesn't exist
if [ ! -f "${INVENTREE_SECRET_KEY_FILE}" ]; then
    echo "Generating secret key..."
    python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())" > "${INVENTREE_SECRET_KEY_FILE}"
fi

cd /app/code/inventree

# Apply database migrations and collect static files
echo "Applying database migrations..."
/app/code/env/bin/python manage.py migrate --noinput

echo "Collecting static files..."
/app/code/env/bin/python manage.py collectstatic --noinput

# Create superuser if not exists
echo "Checking for superuser..."
DJANGO_SUPERUSER_PASSWORD="${INVENTREE_ADMIN_PASSWORD}" \
/app/code/env/bin/python manage.py createsuperuser --noinput \
    --username "${INVENTREE_ADMIN_USER}" \
    --email "${INVENTREE_ADMIN_EMAIL}" || true

# Set proper permissions
chown -R cloudron:cloudron "${INVENTREE_HOME}"

# Start supervisor to manage processes
echo "Starting supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf