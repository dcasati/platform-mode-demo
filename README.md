# Platform Mode Demo

Welcome to the Platform Engineering team repository. This repository serves as the central hub for infrastructure automation, resource deployment, and operational workflows using platform mode approaches.

## 🎯 Purpose

This repository enables:

- **IssueOps**: Use GitHub Issues to request infrastructure resources and deployments
- **Service Catalog**: Standardized, pre-approved Azure services and configurations
- **Automated Deployments**: GitHub Actions workflows for consistent, secure deployments  
- **Infrastructure as Code**: Version-controlled infrastructure definitions
- **Team Collaboration**: Centralized platform engineering workflows

## 🗂️ Service Catalog

Our platform provides a curated catalog of approved Azure services:

- **Azure Kubernetes Service (AKS)** - Managed Kubernetes with approved node types
- **Azure Key Vault** - Secure secrets and certificate management
- **Azure Container Registry (ACR)** - Private container image storage
- **Azure Monitor** - Application performance monitoring
- **Log Analytics Workspace** - Centralized logging platform

📚 **Documentation**: 
- [Complete Service Catalog](docs/service-catalog.md) - Detailed specifications and policies
- [Quick Reference](docs/quick-reference.md) - Fast lookup for common configurations

## 🚀 Getting Started

### For Infrastructure Requests

1. Navigate to the [Issues tab](../../issues)
2. Click "New Issue" 
3. Select **"Infrastructure Request"** template
4. Choose your service from the approved catalog
5. Specify configuration using only approved options
6. Provide business justification and cost approval
7. Submit and wait for automated validation

### Approved Services Quick Reference

| Service | Dev VM Size | Prod VM Size | Region |
|---------|-------------|--------------|--------|
| **AKS System** | Standard_DS2_v2 | Standard_DS2_v2 | eastus2 |
| **AKS GPU** | Standard_NC40ads_H100_v5 | Standard_NC40ads_H100_v5 | eastus2 |
| **Key Vault** | Standard SKU | Premium SKU | eastus2 |
| **ACR** | Basic SKU | Premium SKU | eastus2 |

### Issue Templates

- **🏗️ Infrastructure Request**: Request approved catalog services
- **🚀 Deployment Request**: Deploy applications or infrastructure
- **🐛 Bug Report**: Report platform infrastructure issues

## 🔄 How IssueOps Works

1. **Create Request** → Use structured issue templates
2. **Auto-Validation** → Automated compliance checking against catalog
3. **Team Review** → Platform team approves compliant requests
4. **Auto-Deploy** → GitHub Actions deploys approved resources
5. **Completion** → Issue updated with deployment results

## ⚡ Platform Constraints

- **📍 Region**: East US 2 (`eastus2`) only
- **💰 Cost Limits**: $500 (dev), $1000 (staging), unlimited (prod with approval)  
- **🔒 Security**: Private endpoints required for production PaaS services
- **🏷️ Tagging**: All resources must include mandatory tags

## 🔐 Security & Compliance

- All deployments require approval through issue review process
- Secrets are managed through GitHub Secrets and Azure Key Vault
- All infrastructure changes are logged and auditable
- Resource access follows principle of least privilege
- Production resources require additional security review

## 🆘 Support

For questions or issues:
1. Check existing [issues](../../issues) and [documentation](docs/)
2. Create a new issue using the appropriate template
3. Review the [Service Catalog](docs/service-catalog.md) for approved configurations
4. Reach out to the platform engineering team on Slack

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this repository.

---

**🎯 Platform Goal**: Enable self-service infrastructure provisioning while maintaining security, compliance, and cost control through standardized service catalog and automated workflows.