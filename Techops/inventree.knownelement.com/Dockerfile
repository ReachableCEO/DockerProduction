FROM cloudron/base:4.2.0

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    INVENTREE_HOME=/app/data \
    INVENTREE_MEDIA_ROOT=/app/data/media \
    INVENTREE_STATIC_ROOT=/app/data/static \
    INVENTREE_SECRET_KEY_FILE=/app/data/secret_key.txt \
    INVENTREE_PLUGINS_ENABLED=true \
    INVENTREE_PLUGINS_DIR=/app/data/plugins \
    INVENTREE_ADMIN_USER=admin \
    INVENTREE_ADMIN_PASSWORD=admin \
    INVENTREE_ADMIN_EMAIL=admin@example.com

# Install required packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    build-essential \
    libpq-dev \
    git \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Setup nginx for Cloudron
RUN rm /etc/nginx/sites-enabled/* \
    && sed -e 's,^ErrorLog.*,ErrorLog "/dev/stderr",' -i /etc/nginx/nginx.conf \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

# Create InvenTree directories
RUN mkdir -p /app/code \
    && mkdir -p /tmp/data/media \
    && mkdir -p /tmp/data/static \
    && mkdir -p /tmp/data/plugins \
    && mkdir -p /tmp/data/env \
    && mkdir -p /tmp/data/config

# Create Python virtual environment
RUN python3 -m venv /app/code/env

# Clone InvenTree source code
RUN git clone --depth 1 https://github.com/inventree/InvenTree.git /app/code/inventree

# Install InvenTree requirements
WORKDIR /app/code/inventree
RUN /app/code/env/bin/pip install --upgrade pip \
    && /app/code/env/bin/pip install wheel \
    && /app/code/env/bin/pip install --no-cache-dir -r requirements.txt \
    && /app/code/env/bin/pip install psycopg2 gunicorn

# Create default configuration files
COPY config.yaml /tmp/data/config/config.yaml
COPY nginx.conf /etc/nginx/sites-available/inventree
RUN ln -s /etc/nginx/sites-available/inventree /etc/nginx/sites-enabled/

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add startup script
COPY start.sh /app/code/start.sh
RUN chmod +x /app/code/start.sh

# Setup NGINX runtime directory
RUN mkdir -p /run/nginx \
    && chown -R cloudron:cloudron /run/nginx

# Expose port
EXPOSE 8000

CMD ["/app/code/start.sh"]