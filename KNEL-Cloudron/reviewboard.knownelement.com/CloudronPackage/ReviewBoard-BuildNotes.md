# Review Board - Cloudron Build Notes

This document provides instructions for building, testing, and deploying the Review Board Cloudron package.

## Package Overview

Review Board is a powerful web-based code review tool that helps teams review code, documents, and images before they are committed. This package configures Review Board to run on Cloudron with the following features:

- PostgreSQL database for data storage
- Memcached for caching
- Nginx as the web server
- Gunicorn as the WSGI server
- Support for Cloudron’s OIDC and LDAP authentication
- Proper data separation following Cloudron’s filesystem layout

## Prerequisites

1. Cloudron CLI tool installed (`npm install -g cloudron`)
2. Docker installed and running
3. Cloudron account with administrative access

## Files Included in the Package

1. **CloudronManifest.json** - Defines the application for Cloudron
2. **Dockerfile** - Instructions for building the Docker image
3. **start.sh** - Initialization and startup script
4. **supervisord.conf** - Process management configuration
5. **nginx.conf** - Web server configuration

## Building the Package

1. Create a new directory for your package files:
   ```bash
   mkdir reviewboard-cloudron
   cd reviewboard-cloudron
   ```

2. Create all the package files in this directory.

3. Download the Review Board icon and save it as `icon.png`:
   ```bash
   curl -L “https://raw.githubusercontent.com/reviewboard/reviewboard/master/reviewboard/static/rb/images/logo.png” -o icon.png
   ```

4. Build the package:
   ```bash
   cloudron build
   ```

## Testing Locally (Optional)

1. Run the Docker image locally to test basic functionality:
   ```bash
   docker run -p 8000:8000 cloudron/reviewboard-app:1.0.0
   ```

2. Access the application at http://localhost:8000 to check if it starts correctly.

## Deploying to Cloudron

1. Install the package on your Cloudron:
   ```bash
   cloudron install —image cloudron/reviewboard-app:1.0.0
   ```

2. Or, to update an existing installation:
   ```bash
   cloudron update —image cloudron/reviewboard-app:1.0.0 —app reviewboard.yourdomain.com
   ```

## Post-Installation

1. Access your Review Board instance at the URL assigned by Cloudron.
2. Log in using the initial admin credentials:
   - Username: `admin`
   - Password: Check the file `/app/data/admin_password.txt` inside the app container:
     ```bash
     cloudron exec —app reviewboard.yourdomain.com cat /app/data/admin_password.txt
     ```

3. Configure your repository connections in the Review Board admin interface at `/admin/`.

## Authentication Details

### OIDC Authentication (Default)

The package is configured to use Cloudron’s OIDC provider when available. Users logging in via OIDC will be automatically provisioned in Review Board.

### LDAP Authentication (Alternative)

If OIDC is not available, the package will fall back to using Cloudron’s LDAP server for authentication.

## Repository Support

Review Board supports the following repository types:
- Git
- SVN
- Mercurial
- Perforce
- Bazaar
- CVS
- IBM Rational ClearCase
- And more

Configure these in the Admin > Repositories section after login.

## Troubleshooting

1. Check application logs:
   ```bash
   cloudron logs —app reviewboard.yourdomain.com
   ```

2. Access the container directly to troubleshoot:
   ```bash
   cloudron exec —app reviewboard.yourdomain.com bash
   ```

3. Validate database connectivity:
   ```bash
   cloudron exec —app reviewboard.yourdomain.com psql “$CLOUDRON_POSTGRESQL_URL”
   ```

4. If Review Board shows errors about missing repositories, ensure they are accessible from the Cloudron container.

## Backup and Restore

Cloudron automatically backs up the `/app/data` directory, which includes:
- Database (via PostgreSQL addon)
- Media files (uploaded files, screenshots, etc.)
- Configuration files
- Repository cache

No additional backup configuration is necessary.

## Upgrading Review Board

When a new version of Review Board is released:

1. Update the Dockerfile to install the new version
2. Rebuild the Docker image
3. Update the Cloudron app using the `cloudron update` command

## Additional Resources

- [Review Board Documentation](https://www.reviewboard.org/docs/)
- [Cloudron Documentation](https://docs.cloudron.io/)