# eLabFTW Cloudron Package Build Notes

This document provides instructions for building, testing, and deploying the eLabFTW Cloudron package.

## Package Overview

This package deploys eLabFTW, an open-source electronic laboratory notebook (ELN) for researchers, on Cloudron. The package:

- Uses the MySQL addon for database storage
- Uses the localstorage addon for file storage
- Includes NGINX and PHP-FPM configuration
- Supports optional LDAP authentication through Cloudron

## Building the Package

1. Create a new directory for your package:
   ```bash
   mkdir elabftw-cloudron
   cd elabftw-cloudron
   ```

2. Save all the provided files to this directory:
   - CloudronManifest.json
   - Dockerfile
   - start.sh
   - nginx.conf
   - supervisord.conf

3. Make the start.sh file executable:
   ```bash
   chmod +x start.sh
   ```

4. Download the eLabFTW logo for the package icon:
   ```bash
   curl -o logo.png https://raw.githubusercontent.com/elabftw/elabftw/master/src/ts/img/logo.png
   ```

5. Build the package:
   ```bash
   cloudron build
   ```

## Testing the Package

1. Install the package on your Cloudron for testing:
   ```bash
   cloudron install —location elabftw.example.com
   ```

2. After installation, visit the application URL and complete the initial setup:
   - Create the Sysadmin account
   - Configure your teams and user groups
   - Set up any initial templates or protocols

3. Test the following functionality:
   - User authentication (local accounts)
   - File uploads (should be stored in /app/data/uploads)
   - Database connection (should be using Cloudron MySQL)
   - LDAP authentication (if enabled)
   - General application functionality

## Deploying to Production

1. Once testing is complete, you can deploy to production:
   ```bash
   cloudron install —location elabftw.yourdomain.com
   ```

2. For production use, consider:
   - Setting up regular backups of the Cloudron app
   - Configuring LDAP authentication if needed (via Cloudron UI)
   - Adjusting memory limits in CloudronManifest.json if necessary based on usage

## Post-Installation

After installation, you’ll need to:

1. Create a Sysadmin account when first accessing the application
2. Configure teams and user groups
3. Set up experiment templates and protocols as needed
4. Consider enabling and configuring LDAP authentication for easier user management

## Troubleshooting

- Check logs with `cloudron logs -f elabftw`
- If database issues occur, verify the MySQL addon is properly configured
- For file storage issues, check permissions on /app/data directories
- For authentication issues, verify LDAP configuration (if using LDAP)

## Updates

When a new version of eLabFTW is released:

1. Update the git clone command in the Dockerfile to point to the latest release (or specific tag)
2. Rebuild and update your package:
   ```bash
   cloudron build
   cloudron update —app elabftw.yourdomain.com
   ```

## Customization

You can customize the package by:

1. Modifying the config.yml template in /tmp/data/config to set default values
2. Adjusting PHP settings in the Dockerfile or php.ini
3. Modifying NGINX configuration for special requirements
4. Adjusting memory limits in CloudronManifest.json based on usage patterns