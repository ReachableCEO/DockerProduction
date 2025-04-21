FROM cloudron/base:4.2.0

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-11-jre-headless \
    curl \
    supervisor \
    nginx \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Set Environment Variables
ENV RDECK_BASE=/app/data \
    RUNDECK_SERVER_DATASTORE_DRIVER="org.postgresql.Driver" \
    RUNDECK_GRAILS_URL="https://{{ cloudron_app_domain }}" \
    RUNDECK_SERVER_CONTEXTPATH="/" \
    RUNDECK_SERVER_FORWARDED=true \
    RUNDECK_LOGGING_STRATEGY=CONSOLE \
    SERVER_SERVLET_CONTEXT_PATH="/" \
    RUNDECK_JAASLOGIN=true \
    RUNDECK_SERVER_ADDRESS=127.0.0.1 \
    RUNDECK_SERVER_PORT=4440

# Create necessary directories
RUN mkdir -p /app/code /app/data \
    /app/data/etc \
    /app/data/server/data \
    /app/data/var/logs \
    /app/data/projects \
    /app/data/libext \
    /app/data/.ssh \
    /tmp/data/etc \
    /tmp/data/server/data \
    /tmp/data/var/logs \
    /tmp/data/projects \
    /tmp/data/libext

# Download and install Rundeck
WORKDIR /tmp
RUN curl -Lo rundeck.war "https://repo1.maven.org/maven2/org/rundeck/rundeck/4.17.0/rundeck-4.17.0.war" && \
    mkdir -p /app/code/rundeck/webapps && \
    mv rundeck.war /app/code/rundeck/webapps/rundeck.war

# Copy configuration files
COPY start.sh /app/code/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/sites-available/rundeck
COPY realm.properties /tmp/data/etc/
COPY framework.properties /tmp/data/etc/
COPY rundeck-config.properties /tmp/data/etc/
COPY jaas-ldap.conf /tmp/data/etc/
COPY jaas-oidc.conf /tmp/data/etc/

# Configure NGINX
RUN rm -f /etc/nginx/sites-enabled/default && \
    ln -sf /etc/nginx/sites-available/rundeck /etc/nginx/sites-enabled/rundeck

# Set permissions
RUN chmod +x /app/code/start.sh && \
    chown -R cloudron:cloudron /app/code /app/data /tmp/data

WORKDIR /app/code

CMD ["/app/code/start.sh"]