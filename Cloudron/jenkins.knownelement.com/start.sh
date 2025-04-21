#!/bin/bash
set -e

# Jenkins home directory
JENKINS_HOME=/app/data/jenkins_home

# Create necessary directories if they don't exist
if [[ ! -d "${JENKINS_HOME}" ]]; then
    echo "Initializing Jenkins home directory"
    mkdir -p "${JENKINS_HOME}"
    cp -r /tmp/data/jenkins_home/* "${JENKINS_HOME}/" || true
    # Copy plugins
    mkdir -p "${JENKINS_HOME}/plugins"
    cp -r /tmp/data/plugins/* "${JENKINS_HOME}/plugins/" || true
    # Create directory for JCasC
    mkdir -p "${JENKINS_HOME}/casc_configs"
fi

# Apply proper permissions
chown -R cloudron:cloudron "${JENKINS_HOME}"

# Set up Jenkins environment variables
export JENKINS_HOME
export JENKINS_OPTS="--httpPort=8080"

# Disable setup wizard
export JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Setup JCasC configuration based on environment
if [[ -n "${CLOUDRON_OAUTH_CLIENT_ID}" ]]; then
    echo "Setting up OAuth authentication"
    envsubst < /tmp/data/casc_configs/oauth.yaml > "${JENKINS_HOME}/casc_configs/oauth.yaml"
    export CASC_JENKINS_CONFIG="${JENKINS_HOME}/casc_configs/oauth.yaml"
elif [[ -n "${CLOUDRON_LDAP_SERVER}" ]]; then
    echo "Setting up LDAP authentication"
    envsubst < /tmp/data/casc_configs/ldap.yaml > "${JENKINS_HOME}/casc_configs/ldap.yaml"
    export CASC_JENKINS_CONFIG="${JENKINS_HOME}/casc_configs/ldap.yaml"
else
    echo "Using default authentication"
    envsubst < /tmp/data/casc_configs/default.yaml > "${JENKINS_HOME}/casc_configs/default.yaml"
    export CASC_JENKINS_CONFIG="${JENKINS_HOME}/casc_configs/default.yaml"
fi

# Configure Jenkins URL
JENKINS_URL="${CLOUDRON_APP_ORIGIN}"
echo "Setting Jenkins URL to ${JENKINS_URL}"
export JENKINS_URL

# Start supervisord, which will start NGINX and Jenkins
exec /usr/bin/supervisord --nodaemon -c /etc/supervisor/supervisord.conf