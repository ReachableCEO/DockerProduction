FROM cloudron/base:4.2.0

# Add version specifics
ARG VERSION=latest
ARG DEBIAN_FRONTEND=noninteractive

# Update the system and install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    ca-certificates \
    wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up directory structure following Cloudron filesystem layout
RUN mkdir -p /app/code /app/data /tmp/data

# Set working directory
WORKDIR /app/code

# Download and install the latest Homebox release
RUN if [ "$VERSION" = "latest" ]; then \
        DOWNLOAD_URL=$(curl -s https://api.github.com/repos/sysadminsmedia/homebox/releases/latest | grep "browser_download_url.*linux_amd64" | cut -d '"' -f 4); \
    else \
        DOWNLOAD_URL="https://github.com/sysadminsmedia/homebox/releases/download/v${VERSION}/homebox_${VERSION}_linux_amd64.tar.gz"; \
    fi && \
    wget -O /tmp/homebox.tar.gz ${DOWNLOAD_URL} && \
    tar -xzf /tmp/homebox.tar.gz -C /app/code && \
    rm /tmp/homebox.tar.gz && \
    chmod +x /app/code/homebox

# Copy initialization template for /app/data
COPY data_init /tmp/data/

# Copy application scripts
COPY start.sh /app/code/
RUN chmod +x /app/code/start.sh

# Copy NGINX configuration
COPY nginx.conf /app/code/

# Set ownership to cloudron user
RUN chown -R cloudron:cloudron /app/code /tmp/data

# Set entrypoint
ENTRYPOINT ["/app/code/start.sh"]