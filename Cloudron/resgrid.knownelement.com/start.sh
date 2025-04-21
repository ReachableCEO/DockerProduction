#!/bin/bash
set -e

# Function for logging
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S"): $1"
}

log "Starting Resgrid Cloudron App..."

# Initialize data directory if it's the first run
if [ ! -f /app/data/config/.initialized ]; then
    log "First run detected, initializing data directory..."
    
    # Copy initial configuration files if they don't exist
    if [ ! -f /app/data/config/resgrid.env ]; then
        log "Creating initial configuration..."
        
        # Generate random keys and passwords
        ADMIN_PASSWORD=$(openssl rand -base64 12)
        DB_PASSWORD=${CLOUDRON_MYSQL_PASSWORD}
        API_KEY=$(openssl rand -hex 32)
        
        # Create environment configuration from template
        export RESGRID_ADMIN_PASSWORD=$ADMIN_PASSWORD
        export RESGRID_DB_PASSWORD=$DB_PASSWORD
        export RESGRID_API_KEY=$API_KEY
        export RESGRID_DB_HOST=${CLOUDRON_MYSQL_HOST}
        export RESGRID_DB_PORT=${CLOUDRON_MYSQL_PORT}
        export RESGRID_DB_USER=${CLOUDRON_MYSQL_USERNAME}
        export RESGRID_DB_NAME=${CLOUDRON_MYSQL_DATABASE}
        export RESGRID_REDIS_HOST=${CLOUDRON_REDIS_HOST}
        export RESGRID_REDIS_PORT=${CLOUDRON_REDIS_PORT}
        export RESGRID_REDIS_PASSWORD=${CLOUDRON_REDIS_PASSWORD}
        export RESGRID_RABBITMQ_HOST=${CLOUDRON_RABBITMQ_HOST}
        export RESGRID_RABBITMQ_PORT=${CLOUDRON_RABBITMQ_PORT}
        export RESGRID_RABBITMQ_USER=${CLOUDRON_RABBITMQ_USERNAME}
        export RESGRID_RABBITMQ_PASSWORD=${CLOUDRON_RABBITMQ_PASSWORD}
        export RESGRID_RABBITMQ_VHOST=${CLOUDRON_RABBITMQ_VHOST}
        export RESGRID_BASE_URL="https://${CLOUDRON_APP_DOMAIN}"
        export RESGRID_API_URL="https://${CLOUDRON_APP_DOMAIN}/api"
        export RESGRID_EVENTS_URL="https://${CLOUDRON_APP_DOMAIN}/events"
        
        # OIDC Configuration for Cloudron
        export RESGRID_OIDC_ENABLED="true"
        export RESGRID_OIDC_CLIENT_ID=${CLOUDRON_OIDC_CLIENT_ID}
        export RESGRID_OIDC_CLIENT_SECRET=${CLOUDRON_OIDC_CLIENT_SECRET}
        export RESGRID_OIDC_AUTHORITY=${CLOUDRON_OIDC_ISSUER}
        export RESGRID_OIDC_CALLBACK_PATH="/api/v1/session/callback"
        
        # Process the template
        envsubst < /app/code/resgrid.env.template > /app/data/config/resgrid.env
        
        log "Initial configuration created successfully."
    fi
    
    # Mark as initialized
    touch /app/data/config/.initialized
    log "Initialization completed successfully."
fi

# Link configuration files to expected locations
ln -sf /app/data/config/resgrid.env /app/code/resgrid.env
ln -sf /app/code/nginx.conf /etc/nginx/sites-available/default

# Ensure uploads directory exists with correct permissions
mkdir -p /app/data/uploads
chmod 755 /app/data/uploads

# Wait for database to be ready
log "Waiting for MySQL database to be ready..."
until nc -z ${CLOUDRON_MYSQL_HOST} ${CLOUDRON_MYSQL_PORT}; do
    log "MySQL is unavailable - sleeping for 5 seconds"
    sleep 5
done
log "MySQL is available, continuing..."

# Wait for Redis to be ready
log "Waiting for Redis to be ready..."
until nc -z ${CLOUDRON_REDIS_HOST} ${CLOUDRON_REDIS_PORT}; do
    log "Redis is unavailable - sleeping for 5 seconds"
    sleep 5
done
log "Redis is available, continuing..."

# Wait for RabbitMQ to be ready
log "Waiting for RabbitMQ to be ready..."
until nc -z ${CLOUDRON_RABBITMQ_HOST} ${CLOUDRON_RABBITMQ_PORT}; do
    log "RabbitMQ is unavailable - sleeping for 5 seconds"
    sleep 5
done
log "RabbitMQ is available, continuing..."

# Pull Resgrid Docker images
log "Pulling Resgrid Docker images..."
docker pull resgridllc/resgridwebcore:${RESGRID_VERSION}
docker pull resgridllc/resgridwebservices:${RESGRID_VERSION}
docker pull resgridllc/resgridworkersconsole:${RESGRID_VERSION}
docker pull resgridllc/resgridwebevents:${RESGRID_VERSION}

# Create Docker network if it doesn't exist
docker network create resgrid-network 2>/dev/null || true

# Run the containers with environment variables from the config file
log "Starting Resgrid containers..."
source /app/data/config/resgrid.env

# Start API Service
docker run -d --name resgrid-api \
    --restart unless-stopped \
    --network resgrid-network \
    -p 8001:80 \
    --env-file /app/data/config/resgrid.env \
    resgridllc/resgridwebservices:${RESGRID_VERSION}

# Start Web Core
docker run -d --name resgrid-web \
    --restart unless-stopped \
    --network resgrid-network \
    -p 8002:80 \
    --env-file /app/data/config/resgrid.env \
    resgridllc/resgridwebcore:${RESGRID_VERSION}

# Start Events Service
docker run -d --name resgrid-events \
    --restart unless-stopped \
    --network resgrid-network \
    -p 8003:80 \
    --env-file /app/data/config/resgrid.env \
    resgridllc/resgridwebevents:${RESGRID_VERSION}

# Start Workers Console
docker run -d --name resgrid-workers \
    --restart unless-stopped \
    --network resgrid-network \
    --env-file /app/data/config/resgrid.env \
    resgridllc/resgridworkersconsole:${RESGRID_VERSION}

# Start supervisord to manage Nginx and other processes
log "Starting supervisord..."
exec /usr/bin/supervisord -c /app/code/supervisord.conf