# Git Workflow for Cloudron Packaging

## 🌿 Branch Strategy

### Branch Hierarchy & Workflow Pattern
```
main (production-ready packages)
  ↑ PR (requires YOUR approval)
integration (staging for multiple packages)  
  ↑ merge feature branch directly (no PR needed)
feature/package-[appname] (individual development)
  ↑ create from integration
```

**One Package = One Branch Pattern**:
1. Create `feature/package-[appname]` from `integration`
2. Develop complete package in feature branch  
3. Merge feature branch to `integration` (direct merge)
4. When multiple packages ready, create PR `integration` → `main` (requires your approval)

### Branch Purposes

#### `main` - Production Branch
- **Purpose**: Stable, tested, production-ready packages
- **Protection**: ALL commits must come via Pull Request from `integration`
- **Approval Required**: Project maintainer approval mandatory
- **Quality Gate**: Full validation and approval before merge
- **Branch Protection**: Direct pushes blocked, PR reviews required

#### `integration` - Staging Branch  
- **Purpose**: Collection point for completed packages before production
- **Source**: Direct merges from individual `feature/package-*` branches (no PR needed)
- **Protection**: Open for direct pushes from feature branches
- **Testing**: Integration testing and cross-package validation
- **Duration**: Accumulates packages until batch ready for production release

#### `feature/package-[appname]` - Development Branches
- **Purpose**: Individual application packaging development
- **Naming**: `feature/package-jenkins`, `feature/package-apisix`, etc.
- **Lifespan**: Created from `main`, merged to `integration`, then deleted
- **Scope**: Single application focus, complete package development

#### `hotfix/[appname]-[issue]` - Emergency Fixes
- **Purpose**: Critical fixes to existing packages
- **Source**: Created from `main`
- **Target**: Merge directly to `main` after testing
- **Examples**: `hotfix/jenkins-security-update`

---

## 🔄 Development Workflow

### 1. Starting New Package Development

```bash
# Start from integration branch (not main)
git checkout integration
git pull origin integration

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

### 4. Merge to Integration Branch

```bash
# Push final changes to feature branch
git push origin feature/package-[appname]

# Switch to integration and merge feature branch directly
git checkout integration
git pull origin integration

# Merge feature branch (no PR needed for integration)
git merge feature/package-[appname]

# Push to integration
git push origin integration

# Clean up feature branch
git branch -d feature/package-[appname]
git push origin --delete feature/package-[appname]
```

### 5. Production Release via Pull Request

```bash
# When ready for production (multiple packages in integration)
git checkout integration
git pull origin integration

# Create PR from integration to main using tea CLI
tea pr create \
  --title "release: $(date +%Y-%m-%d) package release" \
  --body "$(cat <<'EOF'
## Release Summary
Production release containing validated packages ready for deployment.

## Packages Included
- [AppName1]: [brief description]
- [AppName2]: [brief description]
- [AppName3]: [brief description]

## Validation Completed
- [x] All packages build successfully
- [x] Integration testing completed
- [x] No conflicts between packages
- [x] Documentation updated
- [x] Quality standards met

## Impact
- Ready for production deployment
- No breaking changes
- All packages follow established patterns

**Requires maintainer approval before merge**
EOF
)" \
  --base main \
  --head integration

# Wait for maintainer approval and merge
# After merge, tag the release
git checkout main
git pull origin main
git tag -a v$(date +%Y.%m.%d) -m "Release $(date +%Y-%m-%d): [package list]"
git push origin main --tags
```

---

## 🍵 Gitea & Tea CLI Integration

### Tea CLI Setup
```bash
# Install tea CLI (if not already installed)
# Visit: https://gitea.com/gitea/tea#installation

# Configure tea for your Gitea instance
tea login add --name knel --url https://git.knownelement.com --token [your-token]

# Verify configuration
tea whoami
```

### PR Templates with Tea

#### Feature Package PR Template
```bash
# Template for individual package PRs to integration
tea pr create \
  --title "feat(${app_name}): add Cloudron package" \
  --body "$(cat <<EOF
## 📦 Package: ${app_name}

### Summary
Implements ${app_name} Cloudron package with proper addon integration and follows established patterns.

### 🔧 Technical Details
- **Base Image**: cloudron/base:4.2.0
- **Addons Required**: ${addons_list}
- **Memory Limit**: ${memory_limit}MB
- **Health Check**: ${health_check_path}
- **Complexity**: ${complexity}

### 📋 Changes
- ✅ CloudronManifest.json with proper addon configuration
- ✅ Dockerfile following Cloudron conventions  
- ✅ start.sh with initialization and error handling
- ✅ Configuration files and templates
- ✅ Build notes documentation

### 🧪 Testing Checklist
- [x] Docker build successful
- [x] Basic functionality verified
- [x] Health check endpoint working
- [x] Addon integration tested
- [ ] Full Cloudron deployment test (if available)

### 📚 Documentation
- [x] Build notes complete
- [x] Configuration documented
- [x] Known limitations noted
- [x] TASKS.md updated

**Auto-merge after CI passes ✅**
EOF
)" \
  --base integration \
  --head feature/package-${app_name}
```

#### Production Release PR Template
```bash
# Template for integration → main PRs (requires approval)
tea pr create \
  --title "release: $(date +%Y-%m-%d) production package release" \
  --body "$(cat <<EOF
## 🚀 Production Release: $(date +%B %d, %Y)

### 📦 Packages Ready for Production
$(git log --oneline integration ^main --grep="feat(" | sed 's/.*feat(\([^)]*\)).*/- **\1**: Ready for deployment/')

### ✅ Validation Summary
- [x] All packages build successfully without errors
- [x] Integration testing completed across packages  
- [x] No resource conflicts or port collisions
- [x] Documentation complete and up-to-date
- [x] Quality standards met for all packages
- [x] Security review completed

### 🔍 Quality Gates Passed
- **Build Success Rate**: 100%
- **Test Coverage**: All packages validated
- **Documentation**: Complete
- **Standards Compliance**: ✅

### 📊 Impact Assessment  
- **New Packages**: $(git log --oneline integration ^main --grep="feat(" | wc -l)
- **Breaking Changes**: None
- **Deployment Risk**: Low
- **Rollback Plan**: Available

### 🎯 Post-Merge Actions
- [ ] Tag release: v$(date +%Y.%m.%d)
- [ ] Update deployment documentation
- [ ] Notify deployment team
- [ ] Monitor initial deployments

**⚠️ REQUIRES MAINTAINER APPROVAL ⚠️**
EOF
)" \
  --base main \
  --head integration
```

### Tea CLI Common Commands
```bash
# List open PRs
tea pr list

# Check PR status
tea pr view [pr-number]

# Close/merge PR (for maintainers)
tea pr merge [pr-number]

# Create draft PR
tea pr create --draft

# Add reviewers to PR
tea pr create --reviewer @maintainer

# Link PR to issue
tea pr create --body "Closes #123"
```

### Automated Workflow Helpers
```bash
# Quick PR creation function (add to ~/.bashrc)
create_package_pr() {
  local app_name=$1
  local complexity=${2:-"Medium"}
  local addons=${3:-"localstorage, postgresql"}
  
  tea pr create \
    --title "feat(${app_name}): add Cloudron package" \
    --body "Implements ${app_name} package. Complexity: ${complexity}. Addons: ${addons}" \
    --base integration \
    --head feature/package-${app_name}
}

# Usage: create_package_pr "jenkins" "High" "localstorage, postgresql, redis"
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
- **Friday**: Merge to main and tag release

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
# Before main merge - production readiness
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
- **Quality Gate**: All tests pass before main merge

### Release Stability
- **Target**: <5% of releases require hotfixes
- **Measurement**: Hotfix commits per release
- **Quality Gate**: Production stability maintained

---

## 🚨 Emergency Procedures

### Critical Package Issue
1. Create `hotfix/[appname]-[issue]` from `main`
2. Implement minimal fix
3. Test fix thoroughly
4. Merge directly to `main` with approval
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