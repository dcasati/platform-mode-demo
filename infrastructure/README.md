# Infrastructure as Code - JupyterHub on AKS with GPU for KAITO Development

This directory contains Terraform infrastructure code for deploying JupyterHub on Azure Kubernetes Service (AKS) with GPU support for KAITO (Kubernetes AI Toolchain Operator) development.

## 🏗️ Infrastructure Overview

This implementation supports the approved infrastructure request [INFRA] JupyterHub on AKS with GPU for KAITO Development, providing:

- **AKS Cluster** with System and GPU node pools
- **JupyterHub** with Zero-to-JupyterHub for Kubernetes
- **KAITO Operator** for AI inference workloads  
- **GPU Support** for AI/ML development
- **Cost Optimization** with auto-scaling and auto-shutdown
- **Security** with network policies and RBAC
- **Compliance** with platform service catalog

## 📁 Directory Structure

```
infrastructure/
├── modules/                    # Reusable Terraform modules
│   ├── aks/                   # AKS cluster with system and GPU node pools
│   │   ├── main.tf            # AKS cluster configuration
│   │   ├── variables.tf       # Input variables
│   │   └── outputs.tf         # Output values
│   ├── jupyterhub/            # JupyterHub deployment
│   │   ├── main.tf            # JupyterHub Helm deployment
│   │   ├── variables.tf       # Configuration variables
│   │   ├── outputs.tf         # Service outputs
│   │   ├── jupyterhub-values.yaml  # Helm chart values
│   │   ├── scripts/           # Setup and configuration scripts
│   │   │   └── kaito-setup.sh # KAITO environment setup
│   │   └── examples/          # Example KAITO workspaces
│   │       └── example-inference.yaml
│   └── kaito/                 # KAITO operator deployment
│       ├── main.tf            # KAITO operator and GPU operator
│       ├── variables.tf       # Configuration variables
│       └── outputs.tf         # Operator outputs
├── environments/              # Environment-specific configurations
│   └── dev/                   # Development environment
│       ├── main.tf            # Main configuration for dev
│       ├── variables.tf       # Environment variables
│       └── outputs.tf         # Environment outputs
├── templates/                 # Template files and examples
└── deploy.sh                  # Deployment automation script
```

## 🚀 Quick Start

### Prerequisites

1. **Azure CLI** installed and logged in
2. **Terraform** >= 1.0 installed
3. **kubectl** installed (will be installed automatically if missing)
4. **Appropriate Azure permissions** for AKS, networking, and storage

### Deploy the Infrastructure

```bash
# Navigate to infrastructure directory
cd infrastructure/

# Deploy with automatic validation and compliance checking
./deploy.sh

# Or deploy step by step
./deploy.sh plan    # Plan only
./deploy.sh deploy  # Deploy infrastructure
```

The deployment script will:

1. ✅ Validate service catalog compliance
2. ✅ Check Azure permissions and region
3. ✅ Initialize Terraform
4. ✅ Create execution plan
5. ✅ Deploy AKS cluster with GPU support
6. ✅ Install JupyterHub with AI/ML tools
7. ✅ Deploy KAITO operator
8. ✅ Configure kubectl access

## 🔧 Configuration

### Service Catalog Compliance

This deployment is fully compliant with the platform service catalog:

| Component | Configuration | Compliance |
|-----------|---------------|------------|
| **Region** | eastus2 | ✅ Required |
| **System Node Pool** | Standard_DS2_v2, 1 node | ✅ Approved |
| **GPU Node Pool** | Standard_NC40ads_H100_v5, 0-1 nodes | ✅ Approved |
| **Auto-scaling** | Enabled | ✅ Required |
| **Network Plugin** | Azure CNI | ✅ Required |
| **Network Policy** | Calico | ✅ Required |
| **Load Balancer** | Standard SKU | ✅ Required |
| **Private Cluster** | No (Development) | ✅ Policy compliant |
| **Cost Limit** | $410/month < $500 limit | ✅ Within limits |

### Resource Tags

All resources include mandatory platform tags:

```hcl
Environment = "Development"
Project     = "end-to-end-deploy-manage-ai-workloads-aks-kaito"
CostCenter  = "CC-1234"
Owner       = "dcasati"
CreatedBy   = "dcasati"
Purpose     = "AI/ML development platform with KAITO"
```

## 💻 Usage

### Access JupyterHub

1. **Get the external IP:**
   ```bash
   kubectl get svc -n jupyterhub proxy-public
   ```

2. **Access JupyterHub in your browser:**
   - URL: `http://<EXTERNAL-IP>`
   - Username: Any username
   - Password: `jupyter` (development setup)

3. **Select GPU environment:**
   - Choose "GPU Environment (TensorFlow)" or "GPU Environment (PyTorch)"
   - Or "KAITO Development Environment" for AI inference work

### Use KAITO for AI Inference

1. **In JupyterHub, open a terminal:**
   ```bash
   # Run the KAITO setup script
   bash /opt/kaito-examples/kaito-setup.sh
   
   # Create an AI inference workspace
   python setup-model-inference.py phi-2
   ```

2. **Monitor KAITO workspaces:**
   ```bash
   kubectl get workspace -n jupyterhub
   kubectl describe workspace phi2-inference-example -n jupyterhub
   ```

### GPU Development

1. **Check GPU availability:**
   ```bash
   kubectl describe nodes -l node-type=gpu
   kubectl get pods -n gpu-operator
   ```

2. **In Jupyter notebooks:**
   ```python
   import tensorflow as tf
   print("GPU Available: ", tf.config.list_physical_devices('GPU'))
   
   # or for PyTorch
   import torch
   print("GPU Available: ", torch.cuda.is_available())
   ```

## 💰 Cost Management

### Estimated Costs

- **System Node Pool**: ~$100/month (1x Standard_DS2_v2)
- **GPU Node Pool**: ~$310/month (0-1x Standard_NC40ads_H100_v5)
- **Storage & Networking**: ~$10/month
- **Total**: ~$410/month (within $500 development limit)

### Cost Optimization Features

- **Auto-scaling**: GPU nodes scale from 0 to 1 based on demand
- **Auto-shutdown**: Development policy - shutdown at 7 PM and weekends
- **Storage optimization**: Premium SSD with right-sizing
- **Resource monitoring**: Azure Monitor integration

## 🛡️ Security

### Network Security

- **Network policies** restrict inter-pod communication
- **Calico CNI** provides microsegmentation
- **Azure CNI** for Azure-native networking
- **Standard Load Balancer** with security groups

### Access Control

- **RBAC** enabled for fine-grained permissions
- **Service accounts** for component communication
- **GPU node taints** prevent non-GPU workloads

### Compliance

- **Private endpoints** not required for development
- **Managed identities** for Azure service authentication
- **Audit logging** enabled via Azure Monitor

## 🔍 Monitoring

### Built-in Monitoring

- **Azure Monitor** with Log Analytics workspace
- **Container Insights** for AKS monitoring
- **GPU metrics** via NVIDIA DCGM exporter
- **JupyterHub metrics** and logging

### Access Monitoring

```bash
# Check cluster health
kubectl get nodes
kubectl top nodes

# Monitor JupyterHub
kubectl get pods -n jupyterhub
kubectl logs -n jupyterhub -l app=jupyterhub

# Monitor KAITO workspaces
kubectl get workspace -A
kubectl logs -n kaito-system -l control-plane=kaito-controller-manager
```

## 🧪 Testing

### Validate Deployment

```bash
# Check all components
kubectl get nodes
kubectl get pods -n jupyterhub
kubectl get pods -n kaito-system
kubectl get pods -n gpu-operator

# Test GPU scheduling
kubectl run gpu-test --image=nvidia/cuda:11.8-runtime-ubuntu20.04 --limits=nvidia.com/gpu=1 --rm -it --restart=Never -- nvidia-smi
```

### Verify KAITO Integration

```bash
# Check KAITO operator
kubectl get crd | grep kaito

# Create test workspace
kubectl apply -f modules/jupyterhub/examples/example-inference.yaml

# Verify workspace creation
kubectl get workspace -n jupyterhub
```

## 🗑️ Cleanup

### Destroy Infrastructure

```bash
./deploy.sh destroy
```

This will remove all Azure resources and stop cost accumulation.

## 📚 Documentation

- **[Service Catalog](../docs/service-catalog.md)** - Platform-approved services
- **[Zero to JupyterHub](https://z2jh.jupyter.org/)** - JupyterHub on Kubernetes
- **[KAITO Documentation](https://github.com/kaito-project/kaito)** - AI Toolchain Operator
- **[Azure AKS Documentation](https://docs.microsoft.com/azure/aks/)** - Kubernetes Service

## 🤝 Support

- **Platform Team**: Issues and requests via GitHub Issues
- **Emergency**: Contact platform team directly
- **Documentation**: See `/docs` directory for platform policies

## ⚡ Advanced Configuration

### Custom Jupyter Images

Modify `infrastructure/environments/dev/main.tf`:

```hcl
module "jupyterhub" {
  # ... other configuration ...
  jupyter_image = "your-custom-image:tag"
}
```

### Additional KAITO Models

Add new model presets in `modules/kaito/main.tf` or create custom workspaces.

### Scaling Configuration

Adjust node pool sizes in `environments/dev/main.tf`:

```hcl
module "aks" {
  # ... other configuration ...
  gpu_max_count = 2  # Scale up to 2 GPU nodes
}
```