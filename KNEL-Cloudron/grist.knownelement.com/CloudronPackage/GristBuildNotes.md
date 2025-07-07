# Grist Cloudron Package Build Notes

## Overview

This document provides instructions for building, testing, and deploying the Grist Cloudron package. Grist is a modern, open-source spreadsheet application with database capabilities, Python formulas, and collaborative features.

## Package Components

The package includes the following files:

1. `CloudronManifest.json` - Configuration file for Cloudron
2. `Dockerfile` - Instructions for building the Docker image
3. `start.sh` - Initialization and startup script
4. `supervisor.conf` - Process management configuration
5. `nginx-app.conf` - NGINX site configuration
6. `nginx.conf` - NGINX main configuration
7. `logo.png` - Grist logo for Cloudron (needs to be added)

## Prerequisites

- Cloudron server (v7.0.0 or newer)
- Docker installed on your build machine
- Cloudron CLI installed on your build machine

## Build Instructions

1. **Prepare the package directory**

   Create a directory for your package and place all the files in it:

   ```bash
   mkdir -p grist-cloudron
   cd grist-cloudron
   # Copy all files into this directory
   ```

2. **Add the Grist logo**

   Download the Grist logo and save it as `logo.png` in the package directory:

   ```bash
   curl -o logo.png https://raw.githubusercontent.com/gristlabs/grist-core/main/static/favicon.png
   ```

3. **Create an initialization data directory**

   ```bash
   mkdir -p init_data
   ```

4. **Build the Docker image**

   ```bash
   cloudron build
   ```

## Testing the Package

1. **Install the package on your Cloudron for testing**

   ```bash
   cloudron install —image your-docker-image-name
   ```

2. **Verify the installation**

   Once installed, navigate to the app’s URL and verify that:
   - The login page appears correctly
   - You can log in using your Cloudron credentials
   - You can create and edit documents
   - Document imports and exports work properly
   - Python formulas are functioning correctly

3. **Test authentication**

   Verify that:
   - Authentication with Cloudron accounts works
   - User permissions are applied correctly
   - Logging out works properly

## Common Issues and Troubleshooting

1. **Authentication Issues**
   - Check that the OAuth configuration is correct in `CloudronManifest.json`
   - Verify environment variables in `start.sh` related to OIDC

2. **Database Connection Problems**
   - Verify PostgreSQL addon configuration
   - Check logs for database connection errors

3. **Grist Not Starting**
   - Check supervisord logs: `cloudron logs -f`
   - Verify that the required directories exist and have proper permissions

4. **File Upload Issues**
   - Verify the `client_max_body_size` setting in the NGINX configuration

## Deployment

1. **Prepare the package for production**

   ```bash
   cloudron build
   cloudron upload
   ```

2. **Install from the Cloudron App Store**

   After submission and approval, users can install directly from the Cloudron App Store.

## Maintenance

1. **Updating Grist**

   To update Grist to a newer version:
   - Update the git clone command in the `Dockerfile`
   - Update the version in `CloudronManifest.json`
   - Rebuild and redeploy

2. **Backing Up**

   Cloudron automatically backs up:
   - The PostgreSQL database
   - The `/app/data` directory containing all Grist documents

## Additional Resources

- [Grist Documentation](https://support.getgrist.com/)
- [Grist GitHub Repository](https://github.com/gristlabs/grist-core)
- [Cloudron Documentation](https://docs.cloudron.io/)
- [Grist Community Forum](https://community.getgrist.com/)