# Service Catalog Quick Reference

This is a quick reference guide for the approved Azure services in our platform catalog.

## Quick Service Selection

| Service | Development | Staging | Production |
|---------|-------------|---------|------------|
| **AKS** | Standard_DS2_v2 nodes | Standard_DS2_v2 nodes | Standard_DS2_v2 + Private |
| **GPU Nodes** | Standard_NC40ads_H100_v5 | Standard_NC40ads_H100_v5 | Standard_NC40ads_H100_v5 |
| **Key Vault** | Standard SKU | Standard SKU | Premium SKU |
| **ACR** | Basic SKU | Standard SKU | Premium SKU |
| **Monitor** | 30 days retention | 90 days retention | 2 years retention |
| **Log Analytics** | Pay-as-go | Pay-as-go | 100GB commitment |

## Region Constraint
- **Approved Region**: East US 2 (`eastus2`) only
- All services must be deployed to East US 2

## Cost Limits
- **Development**: $500/month
- **Staging**: $1,000/month  
- **Production**: No limit (requires approval)

## AKS Node Pool Specifications

### System Node Pool
- **VM Size**: Standard_DS2_v2 (2 vCPU, 7 GB RAM)
- **OS Disk**: 128 GB SSD
- **Min Nodes**: 1
- **Max Nodes**: 10
- **Auto-scaling**: Enabled

### GPU Node Pool (Optional)
- **VM Size**: Standard_NC40ads_H100_v5 (40 vCPU, 440 GB RAM, H100 GPU)
- **OS Disk**: 256 GB SSD
- **Min Nodes**: 0
- **Max Nodes**: 3
- **Auto-scaling**: Enabled
- **Use Case**: ML/AI workloads, GPU computing

## Required Tags
All resources must include:
- `Environment`: dev/staging/prod
- `Project`: Your project name
- `CostCenter`: Billing code
- `Owner`: Team responsible
- `CreatedBy`: Requester email
- `Purpose`: Brief description

## Request Process
1. Use [Infrastructure Request](../../issues/new?template=infrastructure-request.yml) template
2. Select service from approved catalog
3. Specify configuration using approved options
4. Provide business justification
5. Wait for automated validation
6. Platform team approval (if required)
7. Automated deployment

## Common Rejection Reasons
- Region other than East US 2
- VM sizes not in approved list
- Missing mandatory tags
- Over cost limits without approval
- Security policy violations

For detailed information, see the [complete service catalog](service-catalog.md).