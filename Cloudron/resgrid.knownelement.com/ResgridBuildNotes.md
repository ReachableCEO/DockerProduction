# Resgrid Cloudron Package Build Notes

This document provides instructions for building, testing, and deploying the Resgrid Cloudron package.

## Package Overview

Resgrid is an open-source Computer Aided Dispatch (CAD), Personnel, Shift Management, Automatic Vehicle Location (AVL), and Emergency Management Platform. This Cloudron package installs Resgrid with the following components:

- Resgrid Web Core (user interface)
- Resgrid Web Services (API backend)
- Resgrid Workers Console (background processing)
- Resgrid Events Service (real-time notifications using SignalR)

## Prerequisites

- Cloudron server (version 7.2.0 or higher)
- Docker installed on your build machine
- Git installed on your build machine
- About 2GB+ of RAM available on your Cloudron server
- MySQL, Redis, and RabbitMQ addons available on your Cloudron server

## Build Instructions

1. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/yourusername/cloudron-resgrid.git
   cd cloudron-resgrid
   ```

2. Download the Resgrid logo and save it as `logo.png` in the package directory:
   ```bash
   curl -o logo.png https://resgrid.com/images/logo.png
   ```

3. Build the Cloudron package:
   ```bash
   cloudron build
   ```

4. If successful, the package file will be created in the current directory with a `.tar.gz` extension.

## Deployment Instructions

### Method 1: Direct Installation from Package

1. Install the package on your Cloudron server:
   ```bash
   cloudron install —image resgrid.tar.gz
   ```

2. Follow the on-screen instructions to complete the installation.

### Method 2: Using the Cloudron App Store (if published)

1. Log into your Cloudron dashboard
2. Go to App Store
3. Search for “Resgrid”
4. Click “Install”
5. Follow the on-screen instructions

## Post-Installation Configuration

After installation, you should:

1. Log in with the default admin credentials:
   - Username: admin@example.com
   - Password: (Auto-generated, check Cloudron post-install message)

2. Change the default admin password

3. Configure your department settings:
   - Set the department name
   - Configure time zone
   - Set up groups and roles

4. If using Cloudron SSO (recommended):
   - The app is already configured to use Cloudron’s OIDC provider
   - Users who log in via SSO will be created in Resgrid automatically
   - You’ll need to assign appropriate roles to these users in the Resgrid admin interface

## Troubleshooting

### Database Connection Issues

If you encounter database connection issues:

1. Check the logs via the Cloudron dashboard
2. Verify the MySQL addon is running
3. Ensure the database credentials are correctly configured

### Redis or RabbitMQ Issues

1. Check the logs for connection errors
2. Verify the addons are running
3. Restart the app if necessary: `cloudron restart —app resgrid.yourdomain.com`

### Container Startup Problems

If one or more containers fail to start:

1. SSH into the app: `cloudron exec —app resgrid.yourdomain.com`
2. Check Docker container status: `docker ps -a | grep resgrid`
3. View container logs: `docker logs resgrid-web` (or replace with the problematic container name)

## Backup and Restore

The Cloudron platform automatically backs up all Resgrid data stored in:
- MySQL database (via the MySQL addon)
- Redis (via the Redis addon)
- RabbitMQ (via the RabbitMQ addon)
- Local files in `/app/data` (file uploads, configuration, etc.)

To manually create a backup:
```bash
cloudron backup create —app resgrid.yourdomain.com
```

To restore from a backup:
```bash
cloudron restore —app resgrid.yourdomain.com —backup backup_id
```

## Updating

When a new version of the Resgrid Cloudron package is available:

1. Download the new package version
2. Update your existing installation:
   ```bash
   cloudron update —app resgrid.yourdomain.com —image new-resgrid.tar.gz
   ```

## Additional Resources

- [Resgrid Documentation](https://resgrid-core.readthedocs.io/)
- [Cloudron Documentation](https://docs.cloudron.io/)
- [Resgrid GitHub Repository](https://github.com/Resgrid/Core)