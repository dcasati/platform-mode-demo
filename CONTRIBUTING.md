# Contributing to Platform Mode Demo

Welcome to the Platform Engineering team! This guide will help you understand how to contribute to our platform automation and IssueOps workflows.

## IssueOps Workflow

Our platform team uses IssueOps to manage infrastructure requests, deployments, and operational tasks. Here's how it works:

### 1. Creating Requests

- **Infrastructure Requests**: Use the "Infrastructure Request" template for new resources, modifications, or access requests
- **Deployment Requests**: Use the "Deployment Request" template for application or infrastructure deployments
- **Bug Reports**: Use the "Bug Report" template for platform issues

### 2. Approval Process

1. **Create Issue**: Submit your request using the appropriate template
2. **Initial Review**: Platform team reviews the request (usually within 4 hours)
3. **Approval**: Team member adds the `approved` label to trigger automation
4. **Execution**: GitHub Actions workflows automatically process the request
5. **Completion**: Issue is updated with results and automatically closed

### 3. Labels and Automation

| Label | Purpose | Action |
|-------|---------|--------|
| `approved` | Request has been reviewed and approved | Triggers deployment workflow |
| `production-approved` | Additional approval for production changes | Required for prod deployments |
| `in-progress` | Request is being processed | Added automatically |
| `completed` | Request has been fulfilled | Added when workflow completes |
| `blocked` | Request is blocked by dependencies | Manual intervention required |

## Development Guidelines

### Infrastructure as Code

- All infrastructure must be defined as code (Terraform, Bicep, ARM templates)
- Use the `infrastructure/` directory for IaC templates
- Follow naming conventions: `[environment]-[resource-type]-[purpose]`
- Include proper tags for cost allocation and management

### GitHub Actions Workflows

- Place workflows in `.github/workflows/`
- Use descriptive names and include proper documentation
- Implement proper error handling and notifications
- Use secrets and environment variables for sensitive data

### Security Best Practices

- Never commit secrets or sensitive data
- Use GitHub Secrets for API keys and credentials
- Implement proper RBAC for resource access
- Review all production deployments

## Documentation

- Update documentation when adding new features
- Include examples and use cases
- Keep the README.md up to date
- Document any breaking changes

## Deployment Process

### Development Environment
- Auto-deploy on PR merge to `main`
- No approval required
- Full automation enabled

### Staging Environment
- Manual trigger via IssueOps
- Platform team approval required
- Automated testing and validation

### Production Environment
- Manual trigger via IssueOps
- Senior platform engineer approval required
- Additional security scanning
- Rollback plan mandatory

## Getting Help

- **Slack**: #platform-engineering
- **Email**: platform-team@company.com
- **Emergency**: Use critical severity bug report

## Team Goals

1. **Self-Service**: Enable teams to provision infrastructure autonomously
2. **Standardization**: Consistent, repeatable infrastructure patterns
3. **Security**: Secure by default with proper governance
4. **Observability**: Full visibility into platform operations
5. **Cost Optimization**: Efficient resource utilization and cost management