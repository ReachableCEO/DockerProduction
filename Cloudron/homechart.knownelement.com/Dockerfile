FROM cloudron/base:4.2.0

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    supervisor \
    nginx \
    tzdata \
    gosu && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create the application directory structure
RUN mkdir -p /app/code /app/data /run/nginx

# Create homechart data directories structure
RUN mkdir -p /tmp/data

# Download the latest HomeChart release
RUN curl -L -o /app/code/homechart.tar.gz https://github.com/candiddev/homechart/releases/latest/download/homechart_linux_amd64.tar.gz && \
    tar -xzf /app/code/homechart.tar.gz -C /app/code && \
    rm /app/code/homechart.tar.gz && \
    mv /app/code/homechart_linux_amd64 /app/code/homechart && \
    chmod +x /app/code/homechart

# Add NGINX configuration
COPY nginx.conf /etc/nginx/sites-enabled/homechart.conf
RUN rm -f /etc/nginx/sites-enabled/default

# Add Supervisor configuration
COPY supervisor.conf /etc/supervisor/conf.d/homechart.conf

# Add the startup script
COPY start.sh /app/code/
RUN chmod +x /app/code/start.sh

# Set permissions
RUN chown -R cloudron:cloudron /app/code /app/data /run/nginx

# Expose the port (should match the httpPort in the CloudronManifest.json)
EXPOSE 3000

CMD ["/app/code/start.sh"]