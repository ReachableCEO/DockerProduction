FROM cloudron/base:4.2.0

# Install required packages
RUN apt-get update && apt-get install -y \
    acl \
    composer \
    fping \
    git \
    graphviz \
    imagemagick \
    mariadb-client \
    mtr-tiny \
    nginx \
    nmap \
    php8.2-cli \
    php8.2-curl \
    php8.2-fpm \
    php8.2-gd \
    php8.2-gmp \
    php8.2-mbstring \
    php8.2-mysql \
    php8.2-snmp \
    php8.2-xml \
    php8.2-zip \
    python3 \
    python3-pip \
    python3-pymysql \
    python3-redis \
    python3-dotenv \
    python3-systemd \
    rrdtool \
    snmp \
    snmp-mibs-downloader \
    unzip \
    whois \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Download MIBs
RUN download-mibs

# Clone LibreNMS repository
WORKDIR /app/code
RUN git clone --depth 1 https://github.com/librenms/librenms.git .

# Install PHP dependencies
RUN composer install --no-dev --no-interaction

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Create initial data directory structure
RUN mkdir -p /tmp/data/rrd \
             /tmp/data/logs \
             /tmp/data/config \
             /tmp/data/plugins \
             /app/data/rrd \
             /app/data/logs \
             /app/data/config \
             /app/data/plugins

# Copy configuration files
COPY nginx.conf /etc/nginx/sites-available/librenms
RUN ln -sf /etc/nginx/sites-available/librenms /etc/nginx/sites-enabled/default
COPY supervisord.conf /etc/supervisor/conf.d/librenms.conf
COPY start.sh /app/code/
COPY config.php /tmp/data/config/

# Set permissions
RUN chmod +x /app/code/start.sh \
    && chown -R cloudron:cloudron /app/code \
    && chown -R cloudron:cloudron /tmp/data \
    && chown -R cloudron:cloudron /app/data

WORKDIR /app/code

CMD ["/app/code/start.sh"]