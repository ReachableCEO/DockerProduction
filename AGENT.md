# AI Coding Assistants for Cloudron Packaging

This document outlines how to effectively use AI coding assistants (OpenCode, Gemini CLI, Claude) for developing Cloudron packages in this project.

## 🤖 Available AI Assistants

### OpenCode
- **Purpose**: Local development assistance and code generation
- **Strengths**: Fast local responses, code completion, refactoring
- **Use Cases**: Writing Dockerfiles, bash scripts, configuration files

### Gemini CLI
- **Purpose**: Google's AI assistant via command line
- **Strengths**: Research, documentation analysis, multi-modal capabilities
- **Use Cases**: Understanding upstream applications, generating documentation

### Claude (Claude Code)
- **Purpose**: Advanced reasoning and systematic development
- **Strengths**: Complex problem solving, architectural decisions, comprehensive analysis
- **Use Cases**: Complete package development, workflow design, troubleshooting

## 📋 Packaging Workflow with AI Assistants

### Phase 1: Research & Planning
**Best Assistant**: Gemini CLI or Claude
```bash
# Use Gemini to research application requirements
gemini "Analyze the requirements and architecture of [ApplicationName] for containerization"

# Use Claude for systematic analysis
claude "Research [ApplicationName] and create a packaging plan including dependencies, configuration, and Cloudron integration requirements"
```

**Key Questions to Ask**:
- What are the system dependencies?
- What databases or services are required?
- What ports and networking are needed?
- What are the security considerations?
- What configuration files need customization?

### Phase 2: Package Development
**Best Assistant**: Claude Code or OpenCode

#### CloudronManifest.json Creation
```bash
claude "Create a CloudronManifest.json for [ApplicationName] with these requirements: [list requirements]"
```

#### Dockerfile Development
```bash
opencode "Generate a Dockerfile for [ApplicationName] using cloudron/base:4.2.0 that installs [dependencies] and follows Cloudron conventions"
```

#### Startup Script Creation
```bash
claude "Create a start.sh script for [ApplicationName] that handles Cloudron addon integration, initialization, and proper error handling"
```

### Phase 3: Configuration & Integration
**Best Assistant**: Claude Code

```bash
claude "Help me integrate [ApplicationName] with Cloudron's PostgreSQL and Redis addons, including proper environment variable handling"
```

### Phase 4: Documentation & Validation
**Best Assistant**: Any assistant

```bash
gemini "Generate comprehensive build notes for this [ApplicationName] Cloudron package"
```

## 🛠️ Assistant-Specific Usage Patterns

### OpenCode Usage
Best for rapid iteration and code completion:

```bash
# Quick Dockerfile generation
opencode "Create Dockerfile for Node.js app with nginx proxy"

# Configuration file templates
opencode "Generate nginx.conf for Cloudron app on port 8080"

# Script snippets
opencode "Write bash function to check if PostgreSQL is ready"
```

### Gemini CLI Usage
Best for research and analysis:

```bash
# Application research
gemini "What are the key components and dependencies of Apache APISIX?"

# Documentation analysis
gemini "Analyze this README.md and extract installation requirements"

# Troubleshooting
gemini "Explain this Docker build error: [paste error]"
```

### Claude Usage
Best for comprehensive development:

```bash
# Complete package development
claude "Package [ApplicationName] for Cloudron following our established patterns"

# Complex problem solving
claude "Debug this Cloudron package that fails to start properly"

# Architectural guidance
claude "Design the optimal approach for packaging this multi-service application"
```

## 📚 AI Assistant Integration with Our Workflow

### Template-Driven Development
Each assistant can use our package template:

```bash
# Share the template with any assistant
claude "Use the template in CloudronPackages/PackageTemplate/CloudronPackagePrompt.md to package [ApplicationName]"

gemini "Based on our packaging template, what specific considerations apply to [ApplicationName]?"
```

### Quality Assurance with AI
Before merging to integration:

```bash
# Code review
claude "Review this Cloudron package for security issues, best practices, and completeness"

# Documentation review
gemini "Check this build documentation for completeness and clarity"

# Testing guidance
opencode "Generate test commands to validate this Cloudron package"
```

## 🔄 Multi-Assistant Workflow

### Collaborative Approach
1. **Gemini**: Research application and requirements
2. **Claude**: Develop complete package structure
3. **OpenCode**: Refine and optimize code
4. **Claude**: Final review and documentation

### Context Sharing
When switching between assistants, provide:

```markdown
## Context
- Application: [Name]
- Progress: [Current phase]
- Requirements: [List key requirements]
- Issues: [Any current blockers]
- Files: [List relevant files created]
```

## 🎯 Best Practices

### Prompt Engineering for Packaging
Always include in prompts:
- **Target Platform**: "for Cloudron deployment"
- **Base Image**: "using cloudron/base:4.2.0"
- **Conventions**: "following our established patterns"
- **Quality Standards**: "with proper error handling and logging"

### Version Control Integration
Document AI assistance in commits:
```bash
git commit -m "feat(app): add Cloudron package

Generated with assistance from Claude Code for package structure
and Gemini CLI for application research.

🤖 Generated with [Claude Code](https://claude.ai/code)
Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Quality Gates with AI
Before each phase:
- [ ] Ask AI to validate requirements understanding
- [ ] Request security review of generated code
- [ ] Verify Cloudron convention compliance
- [ ] Generate test procedures

## 🔧 Assistant Configuration

### Environment Setup
```bash
# Ensure all assistants are available
which opencode gemini claude

# Set up consistent workspace
export CLOUDRON_PROJECT_ROOT=$(pwd)
export PACKAGING_CONTAINER="tsys-cloudron-packaging"
```

### Context Files
Create context files for each assistant:

**`.ai-context/project-context.md`**:
```markdown
# KNEL Cloudron Packaging Project
- Goal: Package 56 applications for Cloudron
- Current Phase: [update as needed]
- Standards: cloudron/base:4.2.0, proper addon integration
- Workflow: feature → integration → main (PR required)
```

## 📊 AI Assistant Effectiveness Metrics

### Development Velocity
- **Time per Package**: Track packaging time with/without AI assistance
- **Error Reduction**: Monitor build failures and fixes
- **Quality Consistency**: Measure compliance with standards

### Learning and Improvement
- Document which assistant works best for different tasks
- Build prompt libraries for common packaging scenarios
- Share effective prompt patterns across the team

## 🚨 Limitations and Considerations

### Security Review Required
- Never trust AI-generated secrets or credentials
- Always review security configurations manually
- Validate network configurations and exposure

### Testing Still Essential
- AI cannot replace actual testing
- Build and deploy every package manually
- Verify functionality beyond basic container startup

### Context Limitations
- Assistants may not understand latest Cloudron changes
- Always verify against official Cloudron documentation
- Update assistant knowledge with project-specific patterns

## 🎓 Learning Resources

### Improving AI Interactions
- Study effective prompt engineering techniques
- Learn to provide clear context and constraints
- Practice iterative refinement of AI outputs

### Cloudron-Specific Prompts
Build a library of proven prompts:
- Application analysis prompts
- Package generation templates
- Troubleshooting scenarios
- Documentation generation patterns

---

## 📝 Quick Reference

### Common Commands
```bash
# Research phase
gemini "Analyze [app] for Cloudron packaging"

# Development phase  
claude "Create complete Cloudron package for [app]"

# Optimization phase
opencode "Optimize this Dockerfile for size and security"

# Review phase
claude "Review this package for production readiness"
```

### Context Sharing Template
```markdown
## AI Assistant Context
- **Application**: [name]
- **Current Task**: [specific task]
- **Requirements**: [list]
- **Previous Work**: [what's already done]
- **Constraints**: [any limitations]
- **Expected Output**: [what you need]
```

---

**Last Updated**: 2025-01-04  
**Maintained By**: KNEL/TSYS Development Team  
**Part of**: [KNEL Production Containers](README.md) packaging project