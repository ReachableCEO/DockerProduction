FROM cloudron/base:4.2.0

# Install required packages
RUN apt-get update && \
    apt-get install -y \
    php-cli \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-intl \
    php-mbstring \
    php-xml \
    php-zip \
    php-bcmath \
    nginx \
    supervisor \
    curl \
    zip \
    unzip \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Get the latest eLabFTW release
WORKDIR /app/code
RUN git clone https://github.com/elabftw/elabftw.git . && \
    composer install --no-dev --optimize-autoloader

# Configure NGINX
COPY nginx.conf /etc/nginx/sites-available/default

# Prepare directory structure
RUN mkdir -p /app/data/uploads /app/data/config /app/data/logs /run/php && \
    chown -R cloudron:cloudron /app/data /run/php

# Copy initialization data
RUN mkdir -p /tmp/data/config /tmp/data/uploads /tmp/data/logs && \
    cp -r /app/code/config-example.yml /tmp/data/config/config.yml && \
    chown -R cloudron:cloudron /tmp/data

# Copy start script and supervisor config
COPY start.sh /app/code/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /app/code/start.sh

# Configure PHP-FPM
RUN sed -i 's/www-data/cloudron/g' /etc/php/*/fpm/pool.d/www.conf && \
    sed -i 's/listen = \/run\/php\/php[0-9]\.[0-9]-fpm.sock/listen = \/run\/php\/php-fpm.sock/g' /etc/php/*/fpm/pool.d/www.conf && \
    echo 'catch_workers_output = yes' >> /etc/php/*/fpm/pool.d/www.conf

# Create logo image
RUN curl -o /app/code/logo.png https://raw.githubusercontent.com/elabftw/elabftw/master/src/ts/img/logo.png

WORKDIR /app/code

CMD ["/app/code/start.sh"]