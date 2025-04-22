FROM cloudron/base:4.2.0

# Environment variables
ENV RESGRID_VERSION="0.5.30" \
    DEBIAN_FRONTEND="noninteractive" \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg2 \
    apt-transport-https \
    software-properties-common \
    supervisor \
    nginx \
    vim \
    unzip \
    gettext-base \
    netcat-openbsd \
    locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Install .NET Core
RUN curl -SL --output packages-microsoft-prod.deb https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y dotnet-sdk-6.0 \
    && rm -f packages-microsoft-prod.deb \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Resgrid Docker setup files
WORKDIR /tmp
RUN wget -q https://github.com/Resgrid/Core/releases/download/v${RESGRID_VERSION}/resgrid.tgz \
    && mkdir -p /tmp/resgrid \
    && tar -xzf resgrid.tgz -C /tmp/resgrid \
    && rm resgrid.tgz

# Create directory structure
RUN mkdir -p /app/code \
    && mkdir -p /app/data/config \
    && mkdir -p /app/data/logs \
    && mkdir -p /app/data/uploads \
    && mkdir -p /app/data/backup

# Copy Resgrid components to the code directory
WORKDIR /app/code

# Setup configuration directory for first run
RUN mkdir -p /tmp/data/config

# Copy configuration files and setup scripts to temporary directory
COPY start.sh /app/code/
COPY nginx.conf /app/code/
COPY supervisord.conf /app/code/
COPY resgrid.env.template /app/code/

# Make start script executable
RUN chmod +x /app/code/start.sh

# Ensure all files have the correct permissions
RUN chown -R cloudron:cloudron /app

# Switch to the cloudron user
USER cloudron

# Expose the port defined in CloudronManifest.json
EXPOSE 8000

# Set the entrypoint to the start script
ENTRYPOINT ["/app/code/start.sh"]