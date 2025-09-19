# Azure Platform Service Catalog

This document defines the approved services, configurations, and constraints for our Azure platform.

## Global Constraints

- **Approved Region**: East US 2 (eastus2) only
- **Resource Naming**: Must follow pattern: `{environment}-{service}-{purpose}-{random}`
- **Tagging**: All resources must include mandatory tags (see below)

## Approved Services

### 1. Azure Kubernetes Service (AKS)

**Service ID**: `aks`  
**Description**: Managed Kubernetes cluster for container workloads

#### Approved Node Pool Configurations:

##### System Node Pool
- **VM Size**: Standard_DS2_v2 only
- **OS Disk Size**: 128 GB
- **Min Nodes**: 1
- **Max Nodes**: 10
- **Auto-scaling**: Enabled

##### GPU Node Pool (Optional)
- **VM Size**: Standard_NC40ads_H100_v5 only
- **OS Disk Size**: 256 GB  
- **Min Nodes**: 0
- **Max Nodes**: 3
- **Auto-scaling**: Enabled
- **Use Cases**: ML/AI workloads, GPU-accelerated computing

#### Kubernetes Version Policy:
- **Production**: N-1 version (one version behind latest)
- **Development/Staging**: Latest supported version

#### Network Configuration:
- **Network Plugin**: Azure CNI
- **Network Policy**: Calico
- **Load Balancer**: Standard SKU
- **Private Cluster**: Required for Production

---

### 2. Azure Key Vault

**Service ID**: `keyvault`  
**Description**: Secure secrets, keys, and certificates management

#### Approved SKUs:
- **Development**: Standard
- **Staging**: Standard  
- **Production**: Premium (HSM-backed)

#### Access Policies:
- **RBAC**: Azure Role-Based Access Control (preferred)
- **Vault Access Policy**: Legacy support only
- **Network Access**: Private endpoint required for Production

#### Supported Secret Types:
- Application secrets
- Database connection strings
- API keys
- TLS certificates
- SSH keys

---

### 3. Azure Container Registry (ACR)

**Service ID**: `acr`  
**Description**: Private container image registry

#### Approved SKUs:
- **Development**: Basic
- **Staging**: Standard
- **Production**: Premium

#### Features:
- **Geo-replication**: Available for Premium SKU
- **Content Trust**: Enabled for Production
- **Vulnerability Scanning**: Enabled for Standard and Premium
- **Private Endpoint**: Required for Production

#### Repository Policies:
- **Retention**: 30 days for dev, 90 days for staging, 365 days for prod
- **Immutable Images**: Enabled for Production

---

### 4. Azure Monitor

**Service ID**: `monitor`  
**Description**: Application performance monitoring and alerting

#### Components:
- **Application Insights**: Application performance monitoring
- **Metrics**: Platform and custom metrics collection
- **Alerts**: Proactive monitoring and notifications
- **Dashboards**: Custom monitoring dashboards

#### Data Retention:
- **Development**: 30 days
- **Staging**: 90 days
- **Production**: 2 years

#### Alert Rules:
- **Critical**: SMS + Email + Teams
- **Warning**: Email + Teams
- **Informational**: Teams only

---

### 5. Log Analytics Workspace

**Service ID**: `loganalytics`  
**Description**: Centralized logging and log query platform

#### Approved Pricing Tiers:
- **Development**: Pay-as-you-go
- **Staging**: Pay-as-you-go
- **Production**: Commitment Tier (100GB/day minimum)

#### Data Retention:
- **Development**: 30 days (free tier)
- **Staging**: 90 days
- **Production**: 2 years

#### Data Sources:
- Azure Activity Logs
- Resource Diagnostic Logs  
- Application Logs (via agents)
- Custom Logs (via API)
- Security Events

---

## Mandatory Resource Tags

All resources must include the following tags:

| Tag Name | Description | Example |
|----------|-------------|---------|
| `Environment` | Target environment | `dev`, `staging`, `prod` |
| `Project` | Project or application name | `ecommerce`, `analytics` |
| `CostCenter` | Billing/cost center code | `CC-12345` |
| `Owner` | Team or individual responsible | `platform-team` |
| `CreatedBy` | Who requested the resource | `john.doe@company.com` |
| `CreatedDate` | When resource was created | `2025-09-19` |
| `Purpose` | Brief description of use | `web-frontend`, `data-processing` |

## Cost Guidelines

### Spending Limits by Environment:
- **Development**: $500/month per project
- **Staging**: $1,000/month per project  
- **Production**: No limit (requires approval)

### Cost Optimization:
- **Auto-shutdown**: Development resources shut down at 7 PM, weekends
- **Right-sizing**: Regular review of resource utilization
- **Reserved Instances**: Production workloads use reserved capacity when applicable

## Security Requirements

### Network Security:
- **Production**: Private endpoints required for PaaS services
- **NSG Rules**: Restrictive rules, documented exceptions only
- **VNet Integration**: All services in approved VNets

### Identity & Access:
- **Managed Identity**: Required for service-to-service authentication
- **RBAC**: Principle of least privilege
- **MFA**: Required for all human access

### Compliance:
- **Encryption**: Data encryption at rest and in transit
- **Auditing**: All administrative actions logged
- **Backup**: Production data backed up daily

## Request Process

1. **Create Issue**: Use "Infrastructure Request" template
2. **Select Service**: Choose from approved catalog services
3. **Specify Configuration**: Use only approved configurations
4. **Provide Justification**: Business case and cost approval
5. **Review & Approval**: Platform team validates against catalog
6. **Automated Deployment**: Compliant requests auto-deployed

## Unsupported Configurations

The following are **NOT SUPPORTED** and requests will be automatically rejected:

- Regions other than East US 2
- VM sizes not listed in approved configurations
- Custom VM images (use marketplace images only)
- Public endpoints for Production resources
- Resources without proper tagging
- Shared resources across environments

## Support & Exceptions

- **Standard Requests**: Use IssueOps templates
- **Exception Requests**: Require architecture review
- **Emergency Changes**: Contact platform team directly
- **Catalog Updates**: Monthly review cycle