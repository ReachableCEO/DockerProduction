# TSYS Cloudron Packages

This directory contains **finalized, tested packages** ready for deployment to Cloudron. Each package represents a complete application that has been:

- ✅ **Developed** using the containerized workflow
- ✅ **Tested** with build and basic functionality validation  
- ✅ **Documented** with comprehensive build notes
- ✅ **Validated** through our quality assurance process

## 📋 Package Structure

Each application package contains:

### Required Files
- **`CloudronManifest.json`** - App metadata, resource requirements, addon dependencies
- **`Dockerfile`** - Container build instructions following Cloudron conventions
- **`start.sh`** - Application startup script with proper initialization
- **`[AppName]-BuildNotes.md`** - Complete build and deployment instructions

### Common Optional Files
- **`nginx.conf`** - Web server configuration
- **`supervisord.conf`** - Multi-process management configuration
- **`config.yaml`** - Application-specific configuration template
- **`logo.png`** - Application icon for Cloudron dashboard

## 📦 Available Packages

| Package | Status | Version | Complexity | Notes |
|---------|--------|---------|------------|--------|
| [EasyGate](EasyGate/) | ✅ Complete | 1.0.0 | Low | Simple infrastructure dashboard |
| [PackageTemplate](PackageTemplate/) | 📖 Template | - | - | Template and LLM prompts |

## 🚀 Using These Packages

### Prerequisites
- Docker for building containers
- Cloudron CLI: `npm install -g cloudron`
- Access to container registry for image storage

### Build Process
```bash
cd CloudronPackages/[AppName]/

# Build the container
docker build -t your-registry/[appname]:version .

# Push to registry  
docker push your-registry/[appname]:version

# Deploy to Cloudron
cloudron install --image your-registry/[appname]:version
```

### Testing Locally
```bash
# Basic functionality test
docker run --rm -p 8080:8080 your-registry/[appname]:version

# Check logs
docker logs [container-id]
```

## 🔧 Development Process

### From Development to Final Package
1. **Development**: Work in `[appname]_package_new/` using `tsys-cloudron-packaging` container
2. **Testing**: Build and validate package functionality
3. **Finalization**: Move completed package to `CloudronPackages/[AppName]/`
4. **Documentation**: Ensure all required files and build notes are complete
5. **Git Workflow**: Commit via feature branch → integration → main

### Quality Standards
All packages in this directory must meet:
- ✅ Use `cloudron/base:4.2.0` base image
- ✅ Proper Cloudron filesystem structure (`/app/code`, `/app/data`)
- ✅ Integration with Cloudron addons via environment variables
- ✅ Comprehensive health checks and logging to stdout/stderr
- ✅ Security best practices (no hardcoded secrets)
- ✅ Complete and tested build documentation

## 📚 Resources

- **[Development Guide](../README.md)** - Complete development workflow
- **[Package Template](PackageTemplate/)** - Baseline template and LLM prompts
- **[Git Workflow](../GIT_WORKFLOW.md)** - Branching and release process
- **[Task List](../TASKS.md)** - Current packaging priorities

## 🤝 Contributing

### Adding New Packages
1. Follow the development workflow in the main [README](../README.md)
2. Use the feature branch pattern: `feature/package-[appname]`
3. Ensure all quality standards are met
4. Include comprehensive build notes and testing instructions
5. Update the package table above when adding new entries

### Updating Existing Packages
1. Create hotfix branch: `hotfix/[appname]-[issue]`
2. Make minimal necessary changes
3. Test thoroughly before merging
4. Update version numbers and documentation

---

**Maintained By**: KNEL/TSYS Development Team  
**Last Updated**: 2025-01-04  
**Part of**: [KNEL Production Containers](../README.md) packaging project