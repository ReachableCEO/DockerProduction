# KNEL Production Containers - Cloudron Packaging Repository

This repository contains the infrastructure and tooling for packaging applications for [Cloudron](https://cloudron.io), KNEL's self-hosted application platform. We're systematically packaging ~100 applications for internal deployment and potential contribution to the Cloudron app store.

## 🏗️ Repository Structure

```
KNELProductionContainers/
├── [README.md](README.md)                          # This file
├── [PLAN.md](PLAN.md)                           # Overall packaging strategy and roadmap  
├── [TASKS.md](TASKS.md)                          # Application checklist and status
├── [WORKLOG.md](WORKLOG.md)                        # Development progress log
├── [.gitignore](.gitignore)                        # Git exclusions for workspace
│
├── [CloudronPackages/](CloudronPackages/)                 # ✅ Final tested packages (tracked in git)
│   ├── [PackageTemplate/](CloudronPackages/PackageTemplate/)             # Template and LLM prompts
│   ├── [EasyGate/](CloudronPackages/EasyGate/)                    # Completed packages
│   └── [AppName]/                   # Individual app packages
│
├── [CloudronPackagingWorkspace/](CloudronPackagingWorkspace/)      # 🚧 Development workspace  
│   ├── Docker/ (gitignored)         # ~100 cloned upstream repositories
│   ├── NonDocker/ (gitignored)      # Non-Docker applications
│   ├── [UpstreamVendor-Clone.sh](CloudronPackagingWorkspace/UpstreamVendor-Clone.sh)     # Script to clone upstream sources
│   └── [UpstreamVendor-Update.sh](CloudronPackagingWorkspace/UpstreamVendor-Update.sh)    # Script to update upstream sources
│
├── [KNEL-Cloudron/](KNEL-Cloudron/)                   # 🏢 KNEL-specific deployment configs
└── [KNEL-NonCloudron/](KNEL-NonCloudron/)               # Non-Cloudron container configs
```

## 🚀 Quick Start

### Prerequisites
- Docker (for containerized packaging)
- Cloudron CLI: `npm install -g cloudron`
- Git access to upstream repositories

### Setup Development Environment
```bash
# Clone this repository
git clone [repository-url]
cd KNELProductionContainers

# Set up packaging container (persistent across sessions)
docker run -d --name tsys-cloudron-packaging \
  -v $(pwd):/workspace \
  -w /workspace \
  python:3.11-slim tail -f /dev/null

# Install tools in container
docker exec tsys-cloudron-packaging sh -c "
  apt-get update && apt-get install -y git curl build-essential nodejs npm
"

# Clone upstream application sources
chmod +x CloudronPackagingWorkspace/*.sh
./CloudronPackagingWorkspace/UpstreamVendor-Clone.sh
```

## 📋 Packaging Workflow

### 1. Choose Application
- Check [TASKS.md](TASKS.md) for priority applications
- Verify upstream source is available in [CloudronPackagingWorkspace/Docker/](CloudronPackagingWorkspace/Docker/)

### 2. Create Feature Branch
```bash
# Start from integration branch (not main!)
git checkout integration
git pull origin integration
git checkout -b feature/package-[appname]
```

### 3. Package Development
```bash
# Work in the persistent container
docker exec -it tsys-cloudron-packaging bash

# Create package structure
cd /workspace
mkdir -p [appname]_package_new
cd [appname]_package_new

# Create required files:
# - CloudronManifest.json
# - Dockerfile  
# - start.sh
# - [config files]
```

### 4. Build and Test
```bash
# Build container
docker build -t registry/[appname]:version .

# Test locally if possible
docker run --rm -p 8080:8080 registry/[appname]:version

# Deploy to test Cloudron instance
cloudron install --image registry/[appname]:version
```

### 5. Finalize Package
```bash
# Move to final location
mv /workspace/[appname]_package_new ./CloudronPackages/[AppName]/

# Update documentation
# - Add entry to [TASKS.md](TASKS.md)
# - Update [WORKLOG.md](WORKLOG.md)
# - Document any special requirements
```

### 6. Create Pull Request
```bash
git add CloudronPackages/[AppName]/
git add [TASKS.md](TASKS.md) [WORKLOG.md](WORKLOG.md)
git commit -m "Add [AppName] Cloudron package"
git push origin feature/package-[appname]
# Create PR to integration branch
```

## 🏷️ Git Workflow

### Branch Strategy
- **`main`**: Stable, production-ready packages
- **`integration`**: Integration branch for testing multiple packages
- **`feature/package-[appname]`**: Individual application packaging
- **`hotfix/[appname]-[issue]`**: Critical fixes

### Commit Convention
```
type(scope): description

feat(apache): add Apache HTTP Server package
fix(nginx): resolve configuration template issue
docs: update packaging workflow documentation
chore: update upstream source repositories
```

## 🛠️ Package Components

Each Cloudron package requires:

### Required Files
- **`CloudronManifest.json`**: App metadata, resources, addons
- **`Dockerfile`**: Container build instructions  
- **`start.sh`**: Application startup script
- **`[AppName]-BuildNotes.md`**: Build and deployment instructions

### Optional Files
- **`nginx.conf`**: Web server configuration
- **`supervisord.conf`**: Process management
- **`config.yaml`**: Application configuration template
- **`logo.png`**: Application icon

### Key Requirements
- Use `cloudron/base:4.2.0` base image
- Follow `/app/code` (read-only) and `/app/data` (persistent) structure
- Integrate with Cloudron addons via environment variables
- Implement proper health checks and logging
- Security: no hardcoded secrets, proper permissions

## 🔧 Tools and Resources

### Development Container
- **Name**: `tsys-cloudron-packaging`
- **Purpose**: Isolated development environment for all packaging work
- **Mounted**: Repository at `/workspace`
- **Persistent**: Survives across development sessions

### AI Coding Assistants
- **[AGENT.md](AGENT.md)**: Comprehensive guide for using OpenCode, Gemini CLI, and Claude
- **[GEMINI.md](GEMINI.md)**: → Symbolic link to AGENT.md
- **[CLAUDE.md](CLAUDE.md)**: → Symbolic link to AGENT.md
- **Usage**: Accelerate development with AI-assisted packaging

### Helper Scripts
- **[UpstreamVendor-Clone.sh](CloudronPackagingWorkspace/UpstreamVendor-Clone.sh)**: Clone all upstream repositories
- **[UpstreamVendor-Update.sh](CloudronPackagingWorkspace/UpstreamVendor-Update.sh)**: Update existing checkouts
- **Template Prompt**: [CloudronPackagePrompt.md](CloudronPackages/PackageTemplate/CloudronPackagePrompt.md)

### Cloudron Resources
- [Official Packaging Tutorial](https://docs.cloudron.io/packaging/tutorial/)
- [Packaging Cheat Sheet](https://docs.cloudron.io/packaging/cheat-sheet/)
- [Cloudron Base Image](https://hub.docker.com/r/cloudron/base)

## 📊 Progress Tracking

- **Overall Progress**: See [TASKS.md](TASKS.md)
- **Daily Progress**: See [WORKLOG.md](WORKLOG.md)  
- **Strategy & Roadmap**: See [PLAN.md](PLAN.md)

### Current Status
- ✅ Repository structure established
- ✅ Development workflow documented
- ✅ Packaging container ready
- ✅ Template and examples available
- 🚧 Individual application packaging in progress

## 🤝 Contributing

### For KNEL Team Members
1. Review [PLAN.md](PLAN.md) for current priorities
2. Check [TASKS.md](TASKS.md) for available applications
3. Follow the packaging workflow above
4. Update documentation as you work
5. Create feature branches for each application

### Code Review Checklist
- [ ] Dockerfile follows Cloudron conventions
- [ ] All required files present and properly configured
- [ ] Health checks implemented
- [ ] Logging configured to stdout/stderr
- [ ] Security best practices followed
- [ ] Documentation updated
- [ ] Build notes include testing steps

## 🐛 Troubleshooting

### Common Issues
- **Container won't start**: Check logs with `cloudron logs --app [appname]`
- **Database connection fails**: Verify addon environment variables
- **Static files not served**: Check nginx configuration and file permissions
- **Health check fails**: Verify health check endpoint returns 200 OK

### Getting Help
- Check build notes in `CloudronPackages/[AppName]/`
- Review Cloudron documentation
- Examine working examples (EasyGate, InvenTree)
- Use `cloudron debug --app [appname]` for interactive debugging

## 📝 License

See [LICENSE](LICENSE) file for details.

---

**Last Updated**: 2025-01-04  
**Maintainers**: KNEL/TSYS Development Team