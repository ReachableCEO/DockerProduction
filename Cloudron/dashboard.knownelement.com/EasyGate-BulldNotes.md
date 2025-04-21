# Easy-gate Build Notes for Cloudron

This document provides instructions for building, testing, and deploying Easy-gate to your Cloudron instance.

## Overview

Easy-gate is a simple web application designed to serve as the central hub for your self-hosted infrastructure. It allows you to organize and access all your self-hosted services from a single dashboard.

Key features:
- Real-time parsing of services and notes from a configuration file (JSON/YAML)
- Ability to assign items to specific user groups based on IP addresses
- Organization of services into categories
- Customizable theme and icons

## Building the Package

### Prerequisites

- A Linux environment with Docker installed
- Cloudron CLI tool installed (`npm install -g cloudron`)
- Authenticated with your Cloudron instance (`cloudron login`)

### Build Steps

1. Create a directory for your build and copy all files into it:

```bash
mkdir easy-gate-build
cd easy-gate-build
# Copy CloudronManifest.json, Dockerfile, start.sh, and easy-gate.json
```

2. Create a logo.png file for the icon or download one from the Easy-gate repository.

3. Build the package:

```bash
cloudron build
```

This command will create a package file (usually named `easy-gate-1.0.0.tar.gz`).

## Testing Locally

You can test the Docker container locally before deploying to Cloudron:

```bash
# Build the Docker image
docker build -t easy-gate-local .

# Run the container
docker run -p 8080:8080 -e EASY_GATE_BEHIND_PROXY=true easy-gate-local
```

Access the dashboard at http://localhost:8080 to verify it works correctly.

## Deploying to Cloudron

1. Upload the built package to your Cloudron:

```bash
cloudron install —app easy-gate.example.com
```

2. Or, if you want to update an existing installation:

```bash
cloudron update —app easy-gate.example.com
```

3. Configure your Easy-gate instance:

After installation, you’ll need to edit the configuration file to add your services. You can do this in two ways:

### Option 1: Using Cloudron File Manager

1. Go to your Cloudron dashboard
2. Click on the Easy-gate application
3. Go to “Files” tab
4. Navigate to `/app/data/`
5. Edit `easy-gate.json`

### Option 2: SSH Access

1. SSH into your Cloudron server
2. Access the app’s data directory:
```bash
cloudron exec —app easy-gate.example.com
```
3. Edit the configuration file:
```bash
nano /app/data/easy-gate.json
```

## Configuration File Structure

The configuration file uses the following structure:

```json
{
  “title”: “My Dashboard”,
  “theme”: {
    “background”: “#f8f9fa”,
    “foreground”: “#212529”,
    “custom_css”: “”
  },
  “groups”: [
    {
      “name”: “group-name”,
      “subnet”: “192.168.1.1/24”
    }
  ],
  “categories”: [
    {
      “name”: “Category Name”,
      “services”: [
        {
          “name”: “Service Name”,
          “url”: “https://service.example.com”,
          “description”: “Service Description”,
          “icon”: “”,
          “groups”: [“group-name”]
        }
      ]
    }
  ],
  “notes”: [
    {
      “name”: “Note Title”,
      “text”: “Note Content”,
      “groups”: [“group-name”]
    }
  ],
  “behind_proxy”: true
}
```

## Troubleshooting

- If you encounter “502 Bad Gateway” errors, check that the application is running inside the container: `cloudron logs -f —app easy-gate.example.com`
- Make sure the `behind_proxy` setting is set to `true` in your configuration file
- Verify that the user groups and subnets are configured correctly
- Check the logs for any specific error messages

## Maintenance

Easy-gate is designed to be low-maintenance. To update to a newer version, simply rebuild the package with the latest release and update your Cloudron app.