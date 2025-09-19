# JupyterHub Module Outputs

output "namespace" {
  description = "JupyterHub namespace"
  value       = kubernetes_namespace.jupyterhub.metadata[0].name
}

output "helm_release_name" {
  description = "Helm release name for JupyterHub"
  value       = helm_release.jupyterhub.name
}

output "helm_release_status" {
  description = "Helm release status"
  value       = helm_release.jupyterhub.status
}

output "jupyterhub_url" {
  description = "JupyterHub service URL (internal)"
  value       = "http://proxy-public.${kubernetes_namespace.jupyterhub.metadata[0].name}.svc.cluster.local"
}

output "storage_class_name" {
  description = "Storage class name for JupyterHub"
  value       = kubernetes_storage_class.jupyterhub_storage.metadata[0].name
}

output "kaito_service_account" {
  description = "Service account for KAITO integration"
  value       = var.enable_kaito_integration ? kubernetes_service_account.kaito_integration[0].metadata[0].name : null
}