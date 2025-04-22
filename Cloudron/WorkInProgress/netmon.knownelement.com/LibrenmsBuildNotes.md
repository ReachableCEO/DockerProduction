# LibreNMS for Cloudron - Build Notes

This document provides instructions for building, testing, and deploying the LibreNMS package to your Cloudron instance.

## Package Contents

The LibreNMS Cloudron package includes:

- **CloudronManifest.json**: The main configuration file for the Cloudron application
- **Dockerfile**: Sets up the container with all required dependencies
- **start.sh**: The entry point script that initializes and configures LibreNMS
- **nginx.conf**: Web server configuration for LibreNMS
- **supervisord.conf**: Process management for multiple services
- **config.php**: Default LibreNMS configuration

## Building the Package

1. Create a new directory for the package:
   ```bash
   mkdir librenms-cloudron
   cd librenms-cloudron
   ```

2. Copy all files into this directory:
   - CloudronManifest.json
   - Dockerfile
   - start.sh
   - nginx.conf
   - supervisord.conf
   - config.php

3. Download the LibreNMS logo:
   ```bash
   curl -o logo.png https://raw.githubusercontent.com/librenms/librenms/master/html/images/librenms_logo_light.svg
   ```

4. Ensure proper file permissions:
   ```bash
   chmod +x start.sh
   ```

5. Build the Cloudron package:
   ```bash
   cloudron build
   ```

## Testing the Package

1. Install the app on your Cloudron for testing:
   ```bash
   cloudron install —app librenms
   ```

2. Access the LibreNMS web interface at the URL provided by Cloudron.

3. Log in with the default credentials:
   - Username: `admin`
   - Password: `admin`

4. Verify functionality by:
   - Adding a test device
   - Checking discovery and polling
   - Configuring alerts
   - Testing authentication (especially if using Cloudron SSO)

## Deploying to Production

1. Update the CloudronManifest.json with appropriate values:
   - Update `version` if needed
   - Adjust `memoryLimit` based on your production needs
   - Update `contactEmail` with your support email

2. Rebuild the package:
   ```bash
   cloudron build
   ```

3. Install on your production Cloudron:
   ```bash
   cloudron install —app librenms
   ```

## Authentication Configuration

### OIDC Authentication (Recommended)

The package automatically configures OIDC authentication when Cloudron SSO is enabled. This provides:

- Single sign-on with your Cloudron users
- Automatic user provisioning
- Group-based access control

### LDAP Authentication

If OIDC is not enabled, the package can use Cloudron’s LDAP server. This is configured automatically by the start.sh script.

### Manual Authentication

If neither OIDC nor LDAP is used, the package defaults to MySQL authentication with a local admin user.

## Data Persistence

The following data is stored in persistent volumes:

- **/app/data/rrd**: RRD files for graphing
- **/app/data/logs**: LibreNMS logs
- **/app/data/config**: Configuration files
- **/app/data/plugins**: Custom plugins

## Troubleshooting

If you encounter issues:

1. Check the logs:
   ```bash
   cloudron logs -f librenms
   ```

2. Verify database connection:
   ```bash
   cloudron exec —app librenms — mysql -h “$CLOUDRON_MYSQL_HOST” -P “$CLOUDRON_MYSQL_PORT” -u “$CLOUDRON_MYSQL_USERNAME” -p”$CLOUDRON_MYSQL_PASSWORD” -e “SHOW TABLES” “$CLOUDRON_MYSQL_DATABASE”
   ```

3. Check file permissions:
   ```bash
   cloudron exec —app librenms — ls -la /app/data
   ```

4. Restart the application:
   ```bash
   cloudron restart —app librenms
   ```

## Upgrading

To upgrade LibreNMS:

1. Update the git clone command in the Dockerfile to use the latest version tag
2. Update the version in CloudronManifest.json
3. Rebuild and upgrade the package:
   ```bash
   cloudron build
   cloudron update —app librenms
   ```

## Security Considerations

- The default admin password should be changed immediately after installation
- Consider using Cloudron SSO to leverage your existing authentication system
- SNMP port 161 is exposed for device monitoring - ensure proper network security

## Resource Usage

LibreNMS resource requirements depend on the number of monitored devices:

- For <100 devices: Default memory limit (734MB) should be sufficient
- For 100-500 devices: Consider increasing memory limit to 1GB or more
- For >500 devices: Consider distributed polling with multiple instances