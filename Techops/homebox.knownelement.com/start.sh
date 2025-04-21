#!/bin/bash
set -e

# Ensure proper directory structure in /app/data
if [ ! -d "/app/data/.database" ]; then
    echo "Initializing data directory structure..."
    mkdir -p /app/data/.database
    mkdir -p /app/data/uploads
    
    # Copy initialization files if provided
    if [ -d "/tmp/data" ]; then
        cp -r /tmp/data/* /app/data/
    fi
    
    # Fix permissions
    chown -R cloudron:cloudron /app/data
    chmod -R 750 /app/data
fi

# Set environment variables for Homebox
export HBOX_MODE=production
export HBOX_STORAGE_DATA=/app/data
export HBOX_DATABASE_DRIVER=sqlite3
export HBOX_DATABASE_SQLITE_PATH="/app/data/.database/homebox.db"
export HBOX_WEB_PORT=7745
export HBOX_WEB_HOST=127.0.0.1
export HBOX_LOG_LEVEL=info
export HBOX_LOG_FORMAT=text
export HBOX_WEB_MAX_FILE_UPLOAD=50

# Check if registration should be disabled by default
# If this is a fresh install, we'll allow registration for first user
if [ ! -f "/app/data/.database/homebox.db" ]; then
    export HBOX_OPTIONS_ALLOW_REGISTRATION=true
else
    export HBOX_OPTIONS_ALLOW_REGISTRATION=false
fi

# Configure NGINX
echo "Configuring NGINX..."
mkdir -p /run/nginx
cat > /app/data/nginx.conf <<EOF
worker_processes auto;
daemon off;
pid /run/nginx/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    client_max_body_size 50M;
    
    # Logging to stdout for Cloudron to capture
    access_log /dev/stdout;
    error_log /dev/stderr;

    server {
        listen 8000;
        server_name localhost;

        location / {
            proxy_pass http://127.0.0.1:7745;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF

# Start Supervisor which will manage our processes
echo "Starting supervisor..."
cat > /etc/supervisor/conf.d/homebox.conf <<EOF
[supervisord]
nodaemon=true
logfile=/dev/null
logfile_maxbytes=0

[program:homebox]
command=/app/code/homebox
directory=/app/code
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
user=cloudron
autostart=true
autorestart=true
priority=10

[program:nginx]
command=nginx -c /app/data/nginx.conf
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
autostart=true
autorestart=true
priority=20
EOF

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf