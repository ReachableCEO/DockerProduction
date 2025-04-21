# Jenkins for Cloudron - Build Notes

This document provides instructions for building, testing, and deploying the Jenkins package to Cloudron.

## Prerequisites

- Cloudron server (version 5.4.0 or higher)
- Docker installed on your build machine
- Cloudron CLI tool installed (`npm install -g cloudron`)

## File Structure

```
jenkins-cloudron/
├── CloudronManifest.json     # Package definition
├── Dockerfile                # Docker image build instructions
├── start.sh                  # Initialization script
├── nginx.conf                # NGINX configuration
├── supervisor.conf           # Supervisor configuration for process management
├── logo.png                  # App icon (128x128 PNG)
├── casc_templates/           # Jenkins Configuration as Code templates
│   ├── default.yaml          # Default authentication config
│   ├── ldap.yaml             # LDAP authentication config
│   └── oauth.yaml            # OAuth/OIDC authentication config
```

## Building the Package

1. Create a directory for your package and place all files in the appropriate structure.

2. Download a Jenkins logo (128x128 PNG) and save it as `logo.png`

3. Build the Docker image:
   ```bash
   cloudron build
   ```

4. Test the package locally:
   ```bash
   cloudron install —image cloudron/jenkins
   ```

## Authentication Configuration

The package supports three authentication methods:

1. **Default (Local)**: Uses Jenkins’ built-in user database
2. **LDAP**: Uses Cloudron’s LDAP server for authentication
3. **OAuth/OIDC**: Uses Cloudron’s OAuth service for single sign-on

The authentication method is automatically configured based on the presence of environment variables provided by Cloudron.

## Testing

After installation, test the following:

1. **Basic functionality**:
   - Access Jenkins through your Cloudron dashboard
   - Verify the initial admin password works
   - Create a simple pipeline job

2. **Authentication**:
   - Test LDAP integration by enabling the LDAP addon
   - Test OAuth/OIDC integration by enabling the OAuth addon
   - Verify user permissions are correctly applied

3. **Persistence**:
   - Install plugins through the Jenkins UI
   - Restart the app to verify plugins persist
   - Check that job configurations are maintained

## Troubleshooting

- **Jenkins doesn’t start**: Check logs using `cloudron logs -f`
- **Authentication issues**: Verify the correct addons are enabled and configuration is applied
- **Permission problems**: Check the ownership and permissions of files in `/app/data`

## Updating Jenkins

When a new version of Jenkins is released, update the Dockerfile to pull the latest version and rebuild the package.

## Additional Notes

- The package uses Jenkins Configuration as Code (JCasC) to automate the setup process
- Jenkins runs as the `cloudron` user for proper permissions
- Files in `/app/data/jenkins_home` are persisted across restarts and updates
- Initial admin password is set to ‘adminpass’ for local authentication

## Deployment to Cloudron App Store

If you wish to publish your app to the Cloudron App Store:

1. Update the CloudronManifest.json with your details
2. Test thoroughly on your own Cloudron instance
3. Follow the Cloudron App Publishing guidelines

Happy CI/CD with Jenkins on Cloudron!