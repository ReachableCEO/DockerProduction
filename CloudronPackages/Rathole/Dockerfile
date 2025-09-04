FROM cloudron/base:4.2.0

# Install necessary tools for downloading and unzipping
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Rathole
ARG RATHOLE_VERSION=v0.5.0
ARG ARCH=x86_64-unknown-linux-gnu
ARG FILENAME=rathole-${ARCH}.zip
ARG DOWNLOAD_URL=https://github.com/rathole-org/rathole/releases/download/${RATHOLE_VERSION}/${FILENAME}

RUN curl -L ${DOWNLOAD_URL} -o /tmp/${FILENAME} && \
    unzip /tmp/${FILENAME} -d /tmp/rathole && \
    mv /tmp/rathole/rathole /usr/local/bin/rathole && \
    rm -rf /tmp/${FILENAME} /tmp/rathole

# Create a directory for configuration
RUN mkdir -p /app/data

# Set permissions
RUN chmod +x /usr/local/bin/rathole

WORKDIR /app/data

# Expose the default Rathole server port
EXPOSE 2333

CMD ["/usr/local/bin/rathole", "-c", "/app/data/rathole.toml"]
