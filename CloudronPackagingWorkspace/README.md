# Cloudron Packaging Workspace

This workspace contains development tools and upstream source repositories for Cloudron application packaging.

## 🏗️ Workspace Structure

```
CloudronPackagingWorkspace/
├── README.md                    # This file
├── Docker/ (gitignored)         # Upstream application sources (~56 apps)
├── NonDocker/ (gitignored)      # Non-Docker application sources  
├── UpstreamVendor-Clone.sh     # Clone all upstream repositories
└── UpstreamVendor-Update.sh    # Update existing repositories
```

## 🚀 Setup Instructions

### Initial Setup
```bash
cd CloudronPackagingWorkspace/

# Create Docker directory for upstream sources
mkdir -p Docker

# Make scripts executable
chmod +x *.sh

# Clone all upstream vendor repositories
./UpstreamVendor-Clone.sh
```

This will perform a clone of all upstream vendor software/Docker repositories for every application that KNEL is packaging for Cloudron deployment.

### Keeping Sources Updated
```bash
# Update all existing checkouts to latest versions
./UpstreamVendor-Update.sh
```

## 📦 Available Applications

The workspace contains ~56 upstream application repositories including:

### High Priority Applications
- **apisix** - Apache APISIX API Gateway
- **jenkins** - Jenkins CI/CD Platform
- **grist-core** - Grist Database/Spreadsheet
- **rundeck** - Rundeck Job Scheduler
- **reviewboard** - ReviewBoard Code Review
- **consuldemocracy** - Consul Democracy Platform

### Development & Infrastructure Tools
- **InvenTree** - Inventory Management System
- **elabftw** - Laboratory Management
- **netbox-docker** - Network Documentation
- **signoz** - Observability Platform
- **healthchecks** - Health Monitoring
- **fleet** - Device Management

### Productivity & Specialized Applications
- **huginn** - Web Automation
- **windmill** - Workflow Automation
- **docassemble** - Document Assembly
- **jamovi** - Statistical Analysis
- And many more...

## 🛠️ Development Workflow

### Using the Workspace

1. **Source Access**: All upstream sources are available in `Docker/[appname]/`
2. **Development**: Use the `tsys-cloudron-packaging` container for all work
3. **Package Creation**: Create packages in separate temporary directories
4. **Git Exclusion**: All upstream sources are gitignored to keep repository clean

### Container Development
```bash
# Access development container
docker exec -it tsys-cloudron-packaging bash

# Navigate to workspace
cd /workspace

# Access application source
cd CloudronPackagingWorkspace/Docker/[appname]/

# Create new package (outside of workspace)
cd /workspace
mkdir -p [appname]_package_new
```

## 📋 Workspace Management

### Adding New Applications
1. Update `UpstreamVendor-Clone.sh` with new repository URL
2. Run the clone script to fetch the new application
3. Add application to priority list in `TASKS.md`

### Removing Applications  
1. Remove directory from `Docker/`
2. Update clone script to prevent future re-cloning
3. Update task lists and documentation

### Repository Updates
- **Frequency**: Weekly or before starting new package development
- **Method**: Run `./UpstreamVendor-Update.sh`
- **Verification**: Check for breaking changes in upstream

## ⚠️ Important Notes

### Git Exclusions
- **Docker/**: All contents are gitignored
- **NonDocker/**: All contents are gitignored
- This keeps the main repository clean while preserving access to sources

### Repository Integrity
- Never commit upstream sources to the main repository
- Use temporary directories for package development
- Move final packages to `CloudronPackages/` when complete

### Source Licenses
- Each upstream repository maintains its own license
- Review license compatibility before packaging
- Include appropriate license information in final packages

## 🔧 Script Maintenance

### UpstreamVendor-Clone.sh
- Contains git clone commands for all upstream repositories
- Handles both GitHub and other git hosting platforms
- Includes error handling for failed clones

### UpstreamVendor-Update.sh
- Updates existing repositories to latest versions
- Skips missing directories gracefully
- Provides summary of update status

### Customization
Edit scripts as needed to:
- Add new repository sources
- Change clone depth or branch targets
- Modify update behavior
- Handle special cases

## 📊 Workspace Statistics

- **Total Applications**: 56 repositories
- **Repository Size**: ~2-3 GB total (varies by application)
- **Update Frequency**: Weekly recommended
- **Clone Time**: ~15-30 minutes for full clone

## 🤝 Team Usage

### For Developers
1. Use `./UpstreamVendor-Clone.sh` on first setup
2. Run `./UpstreamVendor-Update.sh` weekly or before new package work
3. Always work in the containerized environment
4. Never commit workspace contents to git

### For DevOps
1. Monitor disk space usage of workspace
2. Ensure container environment has access to workspace
3. Backup workspace if needed for disaster recovery
4. Update scripts when adding/removing applications

---

**Last Updated**: 2025-01-04  
**Maintained By**: KNEL/TSYS Development Team  
**Part of**: [KNEL Production Containers](../README.md) packaging project