FROM cloudron/base:4.2.0

# Adding non-free repo for any potential dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set up directory structure
RUN mkdir -p /app/code /app/data /tmp/data

# Default config file
COPY easy-gate.json /tmp/data/easy-gate.json

# Download and install the latest Easy-gate release
RUN mkdir -p /tmp/easy-gate && \
    cd /tmp/easy-gate && \
    LATEST_VERSION=$(wget -qO- https://api.github.com/repos/r7wx/easy-gate/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    wget -q https://github.com/r7wx/easy-gate/releases/download/${LATEST_VERSION}/easy-gate_${LATEST_VERSION#v}_linux_amd64.tar.gz && \
    tar -xzf easy-gate_${LATEST_VERSION#v}_linux_amd64.tar.gz && \
    mv easy-gate /app/code/ && \
    chmod +x /app/code/easy-gate && \
    rm -rf /tmp/easy-gate

# Prepare start script
COPY start.sh /app/code/
RUN chmod +x /app/code/start.sh

# Set proper permissions
RUN chown -R cloudron:cloudron /app/code /app/data /tmp/data

# Configure working directory and user
WORKDIR /app/code
USER cloudron

# Expose the port the app runs on
EXPOSE 8080

# Start the application
CMD ["/app/code/start.sh"]