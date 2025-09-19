# Development Environment Configuration
# JupyterHub on AKS with GPU for KAITO Development

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Configure Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Configure Kubernetes Provider
provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = module.aks.client_certificate
  client_key             = module.aks.client_key
  cluster_ca_certificate = module.aks.cluster_ca_certificate
}

# Configure Helm Provider
provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = module.aks.client_certificate
    client_key             = module.aks.client_key
    cluster_ca_certificate = module.aks.cluster_ca_certificate
  }
}

# Local values for resource naming and configuration
locals {
  # Environment-specific settings
  environment = "Development"
  region      = "eastus2"

  # Project information from infrastructure request
  project_name = "end-to-end-deploy-manage-ai-workloads-aks-kaito"
  cost_center  = "CC-1234"
  owner        = "dcasati"
  created_by   = "dcasati"
  purpose      = "AI/ML development platform with KAITO"

  # Resource naming convention: {environment}-{service}-{purpose}-{random}
  resource_prefix = "dev-aks-kaito"

  # Mandatory tags as per platform policy
  mandatory_tags = {
    Environment = local.environment
    Project     = local.project_name
    CostCenter  = local.cost_center
    Owner       = local.owner
    CreatedBy   = local.created_by
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    Purpose     = local.purpose
  }

  # Additional tags from infrastructure request
  additional_tags = {
    Purpose      = "ai-ml-development"
    Department   = "data-science"
    Framework    = "jupyterhub"
    Operator     = "kaito"
    ContactEmail = "data-science@company.com"
  }

  # Combine all tags
  tags = merge(local.mandatory_tags, local.additional_tags)
}

# AKS Cluster Module
module "aks" {
  source = "../../modules/aks"

  # Cluster configuration
  cluster_name        = "${local.resource_prefix}-cluster"
  resource_group_name = "${local.resource_prefix}-rg"
  location            = local.region
  environment         = "development"
  kubernetes_version  = "1.28" # Latest as per development policy

  # System node pool (as per service catalog)
  system_vm_size    = "Standard_DS2_v2"
  system_node_count = 1
  system_min_count  = 1
  system_max_count  = 1

  # GPU node pool (as per infrastructure request)
  enable_gpu_node_pool = true
  gpu_vm_size          = "Standard_NC40ads_H100_v5"
  gpu_node_count       = 0 # Start with 0, scale up as needed
  gpu_min_count        = 0
  gpu_max_count        = 1

  # Tags
  tags = local.tags
}

# JupyterHub Module
module "jupyterhub" {
  source = "../../modules/jupyterhub"

  # Basic configuration
  namespace   = "jupyterhub"
  environment = "development"

  # GPU support configuration
  enable_gpu_support = true
  gpu_node_selector = {
    "accelerator" = "nvidia-h100"
    "node-type"   = "gpu"
  }

  # KAITO integration
  enable_kaito_integration = true

  # Resource limits for development environment
  cpu_limit    = "4"    # Generous for development
  memory_limit = "16Gi" # Generous for development
  gpu_limit    = "1"    # One GPU per user

  # Storage configuration
  hub_storage_size  = "10Gi"
  user_storage_size = "20Gi" # Larger for AI/ML datasets

  # Jupyter image with AI/ML tools
  jupyter_image = "jupyter/tensorflow-notebook:latest"

  depends_on = [module.aks]
}

# KAITO Operator Module
module "kaito" {
  source = "../../modules/kaito"

  # Configuration
  kaito_namespace     = "kaito-system"
  workspace_namespace = "jupyterhub"
  kaito_version       = "0.3.0"
  environment         = "development"

  # Create example workspace for testing
  create_example_workspace = true

  depends_on = [
    module.aks,
    module.jupyterhub
  ]
}