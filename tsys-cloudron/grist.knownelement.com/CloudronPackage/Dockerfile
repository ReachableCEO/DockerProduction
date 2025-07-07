FROM cloudron/base:4.2.0

# Add Cloudron specific environment
ENV CLOUDRON=1 \
    HOME=/app/data \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    USER=cloudron \
    PORT=8080 \
    PYTHON_VERSION=3 \
    PYTHON_VERSION_ON_CREATION=3 \
    DEBUG=0

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        gnupg \
        supervisor \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        python3-venv \
        build-essential \
        pkg-config \
        xvfb \
        xauth \
        libcairo2-dev \
        libpango1.0-dev \
        libglib2.0-dev \
        nodejs \
        npm \
        git \
        sqlite3 \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create required directories
RUN mkdir -p /app/code /app/data /app/pkg /app/log && \
    mkdir -p /app/data/docs

# Clone Grist
WORKDIR /app/pkg
RUN git clone --depth 1 https://github.com/gristlabs/grist-core.git && \
    cd grist-core && \
    npm install && \
    npm run build && \
    cd /app/pkg

# Set up supervisor config
COPY supervisor.conf /etc/supervisor/conf.d/grist.conf
COPY nginx.conf /app/pkg/nginx.conf

# Nginx site configuration
COPY nginx-app.conf /etc/nginx/sites-available/grist
RUN ln -sf /etc/nginx/sites-available/grist /etc/nginx/sites-enabled/grist && \
    rm -f /etc/nginx/sites-enabled/default

# Add scripts
COPY start.sh /app/pkg/
RUN chmod +x /app/pkg/start.sh

# Set up initialization data
COPY --chown=cloudron:cloudron init_data/ /app/pkg/init_data/

# Set ownership
RUN chown -R cloudron:cloudron /app/code /app/data /app/pkg /app/log

# Set working directory
WORKDIR /app/pkg

# Run as cloudron user
USER cloudron

# Start application
CMD ["/app/pkg/start.sh"]