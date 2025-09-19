# JupyterHub Module Variables

variable "namespace" {
  description = "Kubernetes namespace for JupyterHub"
  type        = string
  default     = "jupyterhub"
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
}

variable "cluster_domain" {
  description = "Kubernetes cluster domain"
  type        = string
  default     = "cluster.local"
}

variable "enable_gpu_support" {
  description = "Enable GPU support for JupyterHub user pods"
  type        = bool
  default     = true
}

variable "gpu_node_selector" {
  description = "Node selector for GPU nodes"
  type        = map(string)
  default = {
    "accelerator" = "nvidia-h100"
    "node-type"   = "gpu"
  }
}

variable "enable_kaito_integration" {
  description = "Enable KAITO operator integration"
  type        = bool
  default     = true
}

# Storage configuration
variable "hub_storage_size" {
  description = "Storage size for JupyterHub hub"
  type        = string
  default     = "10Gi"
}

variable "user_storage_size" {
  description = "Storage size for each user"
  type        = string
  default     = "10Gi"
}

# Resource limits
variable "cpu_limit" {
  description = "CPU limit for user pods"
  type        = string
  default     = "2"
}

variable "memory_limit" {
  description = "Memory limit for user pods"
  type        = string
  default     = "8Gi"
}

variable "gpu_limit" {
  description = "GPU limit for user pods"
  type        = string
  default     = "1"
}

# Jupyter configuration
variable "jupyter_image" {
  description = "Jupyter image with AI/ML tools"
  type        = string
  default     = "jupyter/tensorflow-notebook:latest"
}