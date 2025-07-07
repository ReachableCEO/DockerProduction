# Rundeck Cloudron Package Build Notes

## Overview
This package deploys Rundeck, an open-source automation and job scheduling tool, on Cloudron. It uses PostgreSQL for data storage and can be configured to use either Cloudron's LDAP or OIDC for authentication.

## Package Contents
- **CloudronManifest.json**: Defines the app for Cloudron
- **Dockerfile**: Builds the container with Rundeck and dependencies
- **start.sh**: Initializes the app and manages configuration
- **nginx.conf**: Configures web server to proxy requests to Rundeck
- **supervisord.conf**: Manages Rundeck and Nginx processes
- **Configuration files**:
  - framework.properties: Core Rundeck configuration
  - rundeck-config.properties: Database and server settings
  - jaas-ldap.conf: LDAP authentication configuration
  - jaas-oidc.conf: OAuth/OIDC authentication configuration
  - realm.properties: Default user credentials

## Building the Package

1. Create a new directory for your Cloudron package
2. Place all the files in this package in that directory
3. Download a Rundeck logo and save it as `logo.png` in the package directory
4. Build the package with the Cloudron CLI:
   ```
   cloudron build
   ```

## Testing

1. Install the package on a test Cloudron instance:
   ```
   cloudron install --image [your-image-name]
   ```
2. After installation, access the app at its Cloudron URL
3. Log in with the credentials shown in the post-install message
4. Test basic functionality:
   - Create a project
   - Define a simple job
   - Run the job and verify it executes correctly
   - Check that logs are saved correctly
5. Test authentication:
   - If LDAP is enabled, test login with a Cloudron user
   - If OIDC is enabled, test single sign-on functionality
   - Verify proper permissions mapping

## Deploying to Production

1. After successful testing, publish the package for your production Cloudron:
   ```
   cloudron install --app rundeck --image [your-image-name]
   ```
2. Configure backup schedules through the Cloudron UI
3. Update the admin password immediately after installation
4. Configure necessary projects and jobs

## Authentication Configuration

The package supports two authentication methods:

### OIDC/OAuth (Preferred)
- Automatically configured if Cloudron provides OAuth environment variables
- Uses Cloudron's identity provider for single sign-on
- User roles mapped from Cloudron groups
- No additional configuration needed

### LDAP
- Automatically configured if Cloudron provides LDAP environment variables
- Uses Cloudron's LDAP server for authentication
- Groups are mapped to Rundeck roles
- Works with all Cloudron user accounts

## Troubleshooting

- If the app fails to start, check the Cloudron logs:
  ```
  cloudron logs -f
  ```
- Common issues:
  - Database connection problems: Check the PostgreSQL addon status
  - Authentication issues: Verify LDAP/OIDC configuration
  - File permissions: Ensure files in /app/data are owned by cloudron:cloudron
  - Memory limits: If Rundeck is slow or crashing, consider increasing the memory limit

## Updating the Package

1. Update the app version in CloudronManifest.json
2. Update the Rundeck version in the Dockerfile
3. Make any necessary changes to configuration files
4. Rebuild and reinstall the package

## Backup and Restore

Cloudron automatically backs up the /app/data directory and PostgreSQL database. No additional configuration is required for backup functionality.

## Security Notes

- Rundeck stores sensitive data (credentials, private keys) in its database and file system
- All sensitive data is stored in the /app/data directory, which is backed up by Cloudron
- API keys and other secrets are encrypted using Jasypt encryption
- Always use HTTPS (provided by Cloudron) for secure access