# Git Workflow for Cloudron Packaging

## 🌿 Branch Strategy

### Branch Hierarchy
```
master (production-ready packages)
  ↑ merge after validation
integration (staging for multiple packages)  
  ↑ merge after individual testing
feature/package-[appname] (individual development)
  ↑ create from master
```

### Branch Purposes

#### `master` - Production Branch
- **Purpose**: Stable, tested, production-ready packages
- **Protection**: All commits must come via pull request from `integration`
- **Quality Gate**: Packages must be fully tested and validated
- **Release Cadence**: Weekly merges from integration after validation

#### `integration` - Staging Branch  
- **Purpose**: Integration testing of multiple packages together
- **Source**: Merges from individual `feature/package-*` branches
- **Testing**: Cross-package compatibility and integration testing
- **Duration**: Packages stay here for 1-3 days for validation

#### `feature/package-[appname]` - Development Branches
- **Purpose**: Individual application packaging development
- **Naming**: `feature/package-jenkins`, `feature/package-apisix`, etc.
- **Lifespan**: Created from `master`, merged to `integration`, then deleted
- **Scope**: Single application focus, complete package development

#### `hotfix/[appname]-[issue]` - Emergency Fixes
- **Purpose**: Critical fixes to existing packages
- **Source**: Created from `master`
- **Target**: Merge directly to `master` after testing
- **Examples**: `hotfix/jenkins-security-update`

---

## 🔄 Development Workflow

### 1. Starting New Package Development

```bash
# Ensure master is up-to-date
git checkout master
git pull origin master

# Create feature branch
git checkout -b feature/package-[appname]

# Push branch to remote
git push -u origin feature/package-[appname]
```

### 2. Development Process

```bash
# Work in containerized environment
docker exec -it tsys-cloudron-packaging bash
cd /workspace

# Create package
mkdir -p [appname]_package_new
cd [appname]_package_new
# ... develop package files ...

# Test package
docker build -t test/[appname]:dev .
docker run --rm test/[appname]:dev

# Move to final location when ready
mv /workspace/[appname]_package_new ./CloudronPackages/[AppName]/
```

### 3. Committing Changes

```bash
# Add package files
git add CloudronPackages/[AppName]/

# Update task tracking
git add TASKS.md WORKLOG.md

# Commit with proper message
git commit -m "feat([appname]): add Cloudron package

- Implements [AppName] packaging for Cloudron platform
- Includes proper addon integration and health checks
- Tested with build and basic functionality
- Estimated complexity: [Low/Medium/High]

🤖 Generated with [Claude Code](https://claude.ai/code)
Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to remote
git push origin feature/package-[appname]
```

### 4. Integration Process

```bash
# Switch to integration branch
git checkout integration
git pull origin integration

# Merge feature branch
git merge feature/package-[appname]

# Test integration
# ... run integration tests ...

# Push to integration
git push origin integration

# Clean up feature branch
git branch -d feature/package-[appname]
git push origin --delete feature/package-[appname]
```

### 5. Production Release

```bash
# After integration validation (1-3 days)
git checkout master
git pull origin master

# Merge from integration
git merge integration

# Tag release
git tag -a v$(date +%Y.%m.%d) -m "Release $(date +%Y-%m-%d): [package list]"

# Push with tags
git push origin master --tags
```

---

## 📋 Commit Message Standards

### Commit Types
- **feat(app)**: New package implementation
- **fix(app)**: Bug fix in existing package
- **docs**: Documentation updates
- **chore**: Maintenance tasks
- **test**: Testing improvements
- **refactor(app)**: Package improvements without functional changes

### Message Format
```
type(scope): brief description

Detailed description of changes:
- Key changes made
- Testing performed  
- Any breaking changes or considerations

🤖 Generated with [Claude Code](https://claude.ai/code)
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Examples
```bash
feat(jenkins): add Jenkins CI/CD Cloudron package

- Implements complete Jenkins packaging with persistent storage
- Includes supervisor configuration for multi-process management
- Integrates with PostgreSQL addon for build history
- Tested with basic job creation and execution

🤖 Generated with [Claude Code](https://claude.ai/code)
Co-Authored-By: Claude <noreply@anthropic.com>
```

```bash
fix(apisix): resolve etcd connection timeout issue

- Increases etcd connection timeout from 5s to 30s
- Adds proper wait-for-etcd startup logic
- Improves error logging for debugging
- Tested with cold start scenarios

🤖 Generated with [Claude Code](https://claude.ai/code)
Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## 🛡️ Branch Protection Rules

### Master Branch Protection
- **Require pull request reviews**: 1 approver minimum
- **Dismiss stale reviews**: When new commits pushed
- **Require status checks**: All CI/CD passes
- **Require branches up to date**: Before merging
- **Include administrators**: Apply rules to admins

### Integration Branch Protection
- **Require pull request reviews**: 1 approver (can be self-approved)
- **Allow force pushes**: For integration management
- **Delete head branches**: Automatic cleanup

---

## 🔄 Release Management

### Weekly Release Cycle
- **Monday**: Integration branch validation begins
- **Wednesday**: Final validation and testing
- **Friday**: Merge to master and tag release

### Release Versioning
- **Format**: `v2025.01.15` (date-based)
- **Tags**: Annotated tags with package list
- **Notes**: Generated from commit messages

### Release Content
Each release includes:
- List of new packages added
- List of packages updated  
- Known issues or limitations
- Upgrade instructions if needed

---

## 🧪 Testing Strategy

### Individual Package Testing
```bash
# In feature branch - basic functionality
docker build -t test/[appname]:feature .
docker run --rm -p 8080:8080 test/[appname]:feature

# Local Cloudron testing (if available)
cloudron install --image test/[appname]:feature
```

### Integration Testing  
```bash
# In integration branch - cross-package testing
# Test multiple packages don't conflict
# Verify resource usage within limits
# Check for port conflicts or naming issues
```

### Production Validation
```bash
# Before master merge - production readiness
# Full Cloudron deployment testing
# Performance and stability validation
# Documentation completeness check
```

---

## 📊 Workflow Metrics

### Development Velocity
- **Target**: 2-3 packages per week
- **Measurement**: Feature branch creation to integration merge
- **Quality Gate**: Zero critical issues in integration

### Integration Success Rate
- **Target**: >95% of packages pass integration testing
- **Measurement**: Packages requiring hotfixes after integration
- **Quality Gate**: All tests pass before master merge

### Release Stability
- **Target**: <5% of releases require hotfixes
- **Measurement**: Hotfix commits per release
- **Quality Gate**: Production stability maintained

---

## 🚨 Emergency Procedures

### Critical Package Issue
1. Create `hotfix/[appname]-[issue]` from `master`
2. Implement minimal fix
3. Test fix thoroughly
4. Merge directly to `master` with approval
5. Cherry-pick to `integration` if needed
6. Update affected downstream deployments

### Integration Branch Issues
1. Identify problematic package
2. Revert specific merge if possible
3. Return package to feature branch for fixes
4. Re-test integration after fix

### Repository Corruption
1. Backup current state
2. Identify last known good state
3. Reset affected branches
4. Reapply recent changes manually if needed
5. Communicate impact to team

---

## 🔧 Git Configuration

### Recommended Git Config
```bash
# Helpful aliases
git config --global alias.co checkout
git config --global alias.br branch  
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

# Better logging
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Push settings
git config --global push.default simple
git config --global pull.rebase true
```

### Team Settings
```bash
# Consistent line endings
git config --global core.autocrlf input

# Editor setup
git config --global core.editor "code --wait"

# Name and email (team members)
git config --global user.name "Your Name"
git config --global user.email "your.email@knel.com"
```

---

**Last Updated**: 2025-01-04  
**Next Review**: 2025-02-01  
**Maintained By**: KNEL/TSYS Development Team