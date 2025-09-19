# AKS Module Variables
# Based on approved service catalog configurations

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus2"

  validation {
    condition     = var.location == "eastus2"
    error_message = "Only East US 2 (eastus2) region is approved per platform policy."
  }
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = "1.28"
}

# System Node Pool Variables
variable "system_vm_size" {
  description = "VM size for system node pool"
  type        = string
  default     = "Standard_DS2_v2"

  validation {
    condition     = var.system_vm_size == "Standard_DS2_v2"
    error_message = "Only Standard_DS2_v2 VM size is approved for system node pool per service catalog."
  }
}

variable "system_node_count" {
  description = "Initial number of nodes in system pool"
  type        = number
  default     = 1

  validation {
    condition     = var.system_node_count >= 1 && var.system_node_count <= 10
    error_message = "System node count must be between 1 and 10."
  }
}

variable "system_min_count" {
  description = "Minimum number of nodes in system pool"
  type        = number
  default     = 1

  validation {
    condition     = var.system_min_count >= 1 && var.system_min_count <= 10
    error_message = "System minimum node count must be between 1 and 10."
  }
}

variable "system_max_count" {
  description = "Maximum number of nodes in system pool"
  type        = number
  default     = 1

  validation {
    condition     = var.system_max_count >= 1 && var.system_max_count <= 10
    error_message = "System maximum node count must be between 1 and 10."
  }
}

# GPU Node Pool Variables
variable "enable_gpu_node_pool" {
  description = "Whether to create GPU node pool"
  type        = bool
  default     = true
}

variable "gpu_vm_size" {
  description = "VM size for GPU node pool"
  type        = string
  default     = "Standard_NC40ads_H100_v5"

  validation {
    condition     = var.gpu_vm_size == "Standard_NC40ads_H100_v5"
    error_message = "Only Standard_NC40ads_H100_v5 VM size is approved for GPU node pool per service catalog."
  }
}

variable "gpu_node_count" {
  description = "Initial number of nodes in GPU pool"
  type        = number
  default     = 0

  validation {
    condition     = var.gpu_node_count >= 0 && var.gpu_node_count <= 3
    error_message = "GPU node count must be between 0 and 3."
  }
}

variable "gpu_min_count" {
  description = "Minimum number of nodes in GPU pool"
  type        = number
  default     = 0

  validation {
    condition     = var.gpu_min_count >= 0 && var.gpu_min_count <= 3
    error_message = "GPU minimum node count must be between 0 and 3."
  }
}

variable "gpu_max_count" {
  description = "Maximum number of nodes in GPU pool"
  type        = number
  default     = 1

  validation {
    condition     = var.gpu_max_count >= 0 && var.gpu_max_count <= 3
    error_message = "GPU maximum node count must be between 0 and 3."
  }
}

# Tagging Variables
variable "tags" {
  description = "Resource tags including mandatory platform tags"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      contains(keys(var.tags), "Environment"),
      contains(keys(var.tags), "Project"),
      contains(keys(var.tags), "CostCenter"),
      contains(keys(var.tags), "Owner"),
      contains(keys(var.tags), "CreatedBy"),
      contains(keys(var.tags), "Purpose")
    ])
    error_message = "All mandatory tags must be provided: Environment, Project, CostCenter, Owner, CreatedBy, Purpose."
  }
}