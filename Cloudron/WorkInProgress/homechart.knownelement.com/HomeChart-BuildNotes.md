# HomeChart Cloudron Package - Build Notes

This document provides instructions for building, testing, and deploying the HomeChart Cloudron package.

## Prerequisites

1. A running Cloudron instance
2. Docker installed on your local machine
3. Cloudron CLI tool installed (`npm install -g cloudron`)
4. Git for cloning the repository

## Files Overview

- **CloudronManifest.json**: Contains metadata and configuration for the Cloudron app
- **Dockerfile**: Defines how to build the Docker image for HomeChart
- **start.sh**: Startup script that handles initialization and configuration
- **nginx.conf**: NGINX configuration for proxying requests
- **supervisor.conf**: Supervisor configuration for process management

## Building and Deploying

### Step 1: Clone the repository

```bash
git clone https://github.com/yourusername/homechart-cloudron.git
cd homechart-cloudron
```

### Step 2: Build the Docker image

```bash
# Login to Docker Hub if not already logged in
docker login

# Build the image
cloudron build
```

When prompted, enter a repository name in the format `username/homechart` where `username` is your Docker Hub username.

### Step 3: Install on your Cloudron

```bash
# Install the app
cloudron install —image username/homechart:latest
```

You’ll be prompted to select a subdomain for the app.

### Step 4: Configure the app

After installation, you’ll need to:

1. Log in using the default credentials provided in the post-install message
2. Change the default administrator password
3. Set up your household and invite family members

## Updating the App

To update the app after making changes:

```bash
# Rebuild the Docker image
cloudron build

# Update the installed app
cloudron update —app homechart
```

## Authentication

HomeChart is configured to use Cloudron’s OIDC provider for authentication. Users from your Cloudron instance can log in to HomeChart using their Cloudron credentials.

## Data Persistence

All HomeChart data is stored in:
- PostgreSQL database (managed by Cloudron)
- `/app/data` directory (backed up by Cloudron)

## Troubleshooting

### View logs

```bash
cloudron logs -f —app homechart
```

### Database access

To access the PostgreSQL database directly:

```bash
cloudron exec —app homechart
psql -U “$CLOUDRON_POSTGRESQL_USERNAME” -h “$CLOUDRON_POSTGRESQL_HOST” “$CLOUDRON_POSTGRESQL_DATABASE”
```

### Common Issues

- **OIDC configuration issues**: Ensure the Cloudron environment variables are correctly passed to the app
- **Database connection errors**: Check PostgreSQL connection details in the app config
- **Memory limits**: If the app crashes due to memory issues, increase the memory limit in the CloudronManifest.json

## Resources

- [HomeChart Documentation](https://homechart.app/docs/)
- [Cloudron Documentation](https://docs.cloudron.io/)
- [HomeChart GitHub Repository](https://github.com/candiddev/homechart)