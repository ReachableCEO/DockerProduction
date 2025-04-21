FROM cloudron/base:4.2.0

# Add Jenkins repository key and repository
RUN apt-get update && \
    apt-get install -y gnupg curl software-properties-common && \
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg && \
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list

# Install Jenkins and required dependencies
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk jenkins fontconfig && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install required plugins for Cloudron integration
RUN mkdir -p /tmp/data/plugins && \
    cd /tmp/data/plugins && \
    curl -L -o ldap.hpi https://updates.jenkins.io/latest/ldap.hpi && \
    curl -L -o oic-auth.hpi https://updates.jenkins.io/latest/oic-auth.hpi && \
    curl -L -o configuration-as-code.hpi https://updates.jenkins.io/latest/configuration-as-code.hpi && \
    curl -L -o credentials.hpi https://updates.jenkins.io/latest/credentials.hpi && \
    chmod 644 *.hpi

# Create template for casc.yaml
RUN mkdir -p /tmp/data/casc_configs
COPY casc_templates/ /tmp/data/casc_configs/

# Set up directory structure for Cloudron
RUN mkdir -p /app/data && \
    mkdir -p /tmp/data/jenkins_home 

# Copy startup script
COPY start.sh /app/code/
RUN chmod +x /app/code/start.sh

# Copy NGINX configuration
COPY nginx.conf /app/code/

# Copy supervisor configuration
COPY supervisor.conf /etc/supervisor/conf.d/

# Use the cloudron user for Jenkins
RUN usermod -a -G jenkins cloudron && \
    chown -R cloudron:cloudron /tmp/data

WORKDIR /app/data

# Entry point
CMD ["/app/code/start.sh"]