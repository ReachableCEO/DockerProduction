FROM cloudron/base:4.2.0

# Install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 python3-pip python3-dev python3-venv \
    nginx supervisor \
    memcached libpq-dev \
    libldap2-dev libsasl2-dev \
    git-core subversion \
    libxml2-dev libxslt1-dev \
    libmagic-dev \
    gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create Python virtual environment
RUN python3 -m venv /app/code/venv
ENV PATH="/app/code/venv/bin:${PATH}"

# Install Review Board dependencies
RUN pip3 install --no-cache-dir --upgrade pip wheel setuptools && \
    pip3 install --no-cache-dir psycopg2-binary gunicorn django-storages

# Install Review Board
RUN pip3 install --no-cache-dir reviewboard

# Install OIDC authentication
RUN pip3 install --no-cache-dir mozilla-django-oidc

# Install LDAP authentication
RUN pip3 install --no-cache-dir django-auth-ldap

# Make the data directories ready
RUN mkdir -p /app/data/media /app/data/static /app/data/logs /app/data/conf /app/data/site

# Copy configuration files
COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /app/code/start.sh
RUN chmod +x /app/code/start.sh

# Set up the entry point
CMD ["/app/code/start.sh"]