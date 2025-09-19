# AKS Module Outputs

output "cluster_id" {
  description = "The Kubernetes managed cluster ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "The Kubernetes managed cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kube_config" {
  description = "Raw Kubernetes config for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kubelet_identity" {
  description = "The Kubelet Identity used by the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.aks.name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = azurerm_resource_group.aks.id
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.aks.id
}

output "cluster_fqdn" {
  description = "The FQDN of the Azure Kubernetes managed cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "node_resource_group" {
  description = "The auto-generated Resource Group which contains the resources for this managed Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "system_node_pool_id" {
  description = "System node pool ID"
  value       = azurerm_kubernetes_cluster.aks.default_node_pool[0].id
}

output "gpu_node_pool_id" {
  description = "GPU node pool ID"
  value       = var.enable_gpu_node_pool ? azurerm_kubernetes_cluster_node_pool.gpu[0].id : null
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster"
  value       = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  sensitive   = true
}

output "host" {
  description = "The Kubernetes cluster server host"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive   = true
}

output "client_certificate" {
  description = "Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster"
  value       = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  sensitive   = true
}

output "client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the Kubernetes cluster"
  value       = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  sensitive   = true
}