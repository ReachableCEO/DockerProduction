# Consul Democracy - Cloudron Build Notes

## Overview

Consul Democracy is an open-source citizen participation and open government platform, originally developed for the Madrid City government. This package enables easy deployment on the Cloudron platform with full integration of Cloudron’s authentication, database, and email systems.

## Prerequisites

- A running Cloudron instance (version 7.0.0 or later)
- Basic familiarity with Cloudron’s CLI for package development
- Git installed on your local machine

## Building the Package

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/cloudron-consuldemocracy.git
   cd cloudron-consuldemocracy
   ```

2. Install the Cloudron CLI if you haven’t already:
   ```bash
   npm install -g cloudron
   ```

3. Login to your Cloudron:
   ```bash
   cloudron login https://my.example.com
   ```

4. Build and install the package:
   ```bash
   cloudron build
   cloudron install —image consuldemocracy
   ```

## Configuration

### Post-Installation

After installation, the app will be available at your configured domain. The initial admin credentials are:

- Username: admin@example.org
- Password: password

**Important:** Change these credentials immediately after logging in.

### LDAP Integration

The package is configured to use Cloudron’s LDAP server for authentication. Users who have access to the app through Cloudron’s access control panel will be able to log in using their Cloudron credentials.

### OIDC Integration

For enhanced security, the package also supports Cloudron’s OIDC provider. This is automatically configured during installation.

### Email Configuration

The package is configured to use Cloudron’s SMTP server for sending emails. No additional configuration is needed.

## Customization

### Environment Variables

You can customize the app by setting environment variables in the Cloudron app configuration:

- `CONSUL_CUSTOM_LOGO`: URL to a custom logo
- `CONSUL_ORGANIZATION_NAME`: Name of your organization
- `CONSUL_THEME_COLOR`: Primary theme color (hex code)

### Filesystem Structure

- `/app/data/files`: Persistent storage for uploaded files
- `/app/data/images`: Persistent storage for uploaded images
- `/app/data/log`: Application logs
- `/app/data/tmp`: Temporary files

## Troubleshooting

### Common Issues

1. **Database Migration Errors**:
   Check the app logs for specific error messages:
   ```bash
   cloudron logs -f
   ```

2. **Authentication Issues**:
   Ensure that the LDAP configuration is correct and that users have been granted access to the app in Cloudron’s access control panel.

3. **Email Delivery Problems**:
   Verify that the Cloudron mail addon is properly configured.

### Support

For issues specific to this package:
- Create an issue in the GitHub repository
- Contact the maintainer at: your-email@example.com

For issues with Consul Democracy itself:
- Visit the [Consul Democracy documentation](https://docs.consuldemocracy.org/)
- Check the [GitHub issues](https://github.com/consuldemocracy/consuldemocracy/issues)

## Updates and Maintenance

To update the app:

1. Pull the latest changes from the repository
2. Rebuild the package:
   ```bash
   cloudron build
   cloudron update —app consuldemocracy
   ```

Regular database backups are automatically handled by Cloudron’s backup system.