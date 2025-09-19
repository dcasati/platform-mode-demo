# AKS Template Configuration
# This template follows the approved service catalog for AKS deployments

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Variables for customization
variable "environment" {
  description = "Environment (development, staging, production)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "enable_gpu" {
  description = "Enable GPU node pool"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}

# Local values for naming and configuration
locals {
  # Naming convention: {environment}-{service}-{purpose}-{random}
  resource_prefix = "${lower(var.environment)}-aks-${random_id.suffix.hex}"

  # Environment-specific settings
  node_counts = {
    development = { system_min = 1, system_max = 1, gpu_min = 0, gpu_max = 1 }
    staging     = { system_min = 1, system_max = 3, gpu_min = 0, gpu_max = 2 }
    production  = { system_min = 2, system_max = 10, gpu_min = 0, gpu_max = 3 }
  }

  # Select configuration based on environment
  selected_config = local.node_counts[var.environment]
}

# Random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

# AKS module using approved configurations
module "aks" {
  source = "../modules/aks"

  # Basic configuration
  cluster_name        = "${local.resource_prefix}-cluster"
  resource_group_name = "${local.resource_prefix}-rg"
  location            = var.location
  environment         = var.environment

  # Node pool configuration (service catalog compliant)
  system_vm_size    = "Standard_DS2_v2" # Only approved VM size
  system_node_count = local.selected_config.system_min
  system_min_count  = local.selected_config.system_min
  system_max_count  = local.selected_config.system_max

  # GPU node pool (optional)
  enable_gpu_node_pool = var.enable_gpu
  gpu_vm_size          = "Standard_NC40ads_H100_v5" # Only approved GPU VM
  gpu_node_count       = 0                          # Start with 0 for cost optimization
  gpu_min_count        = local.selected_config.gpu_min
  gpu_max_count        = local.selected_config.gpu_max

  # Tags
  tags = var.tags
}

# Outputs
output "cluster_name" {
  value = module.aks.cluster_name
}

output "resource_group_name" {
  value = module.aks.resource_group_name
}

output "kubeconfig_command" {
  value = "az aks get-credentials --resource-group ${module.aks.resource_group_name} --name ${module.aks.cluster_name}"
}