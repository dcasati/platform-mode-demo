# AKS Cluster with System and GPU Node Pools
# Compliant with platform service catalog specifications

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Log Analytics Workspace for AKS monitoring
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.cluster_name}-logs"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "production" ? 730 : (var.environment == "staging" ? 90 : 30)

  tags = var.tags
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  # System node pool (required)
  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = var.system_vm_size
    os_disk_size_gb     = 128
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = var.system_min_count
    max_count           = var.system_max_count
    zones               = ["1", "2", "3"]

    tags = var.tags
  }

  # Identity configuration
  identity {
    type = "SystemAssigned"
  }

  # Network configuration
  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    service_cidr      = "10.0.0.0/16"
    dns_service_ip    = "10.0.0.10"
  }

  # Monitoring and logging
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  # Azure Policy Add-on
  azure_policy_enabled = true

  # Auto-upgrade
  automatic_channel_upgrade = var.environment == "development" ? "stable" : "none"

  # Private cluster setting based on environment
  private_cluster_enabled = var.environment == "production" ? true : false

  tags = var.tags
}

# GPU Node Pool (optional)
resource "azurerm_kubernetes_cluster_node_pool" "gpu" {
  count = var.enable_gpu_node_pool ? 1 : 0

  name                  = "gpu"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.gpu_vm_size
  os_disk_size_gb       = 256
  node_count            = var.gpu_node_count
  enable_auto_scaling   = true
  min_count             = var.gpu_min_count
  max_count             = var.gpu_max_count
  zones                 = ["1", "2", "3"]

  # GPU-specific taints to ensure only GPU workloads are scheduled
  node_taints = ["nvidia.com/gpu=true:NoSchedule"]

  # Node labels for GPU scheduling
  node_labels = {
    "accelerator" = "nvidia-h100"
    "node-type"   = "gpu"
  }

  tags = var.tags
}

# Install NVIDIA GPU Operator via DaemonSet (if GPU node pool is enabled)
resource "kubernetes_namespace" "gpu_operator" {
  count = var.enable_gpu_node_pool ? 1 : 0

  metadata {
    name = "gpu-operator"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}