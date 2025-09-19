# KAITO Module Outputs

output "kaito_namespace" {
  description = "KAITO operator namespace"
  value       = kubernetes_namespace.kaito_system.metadata[0].name
}

output "kaito_operator_status" {
  description = "KAITO operator Helm release status"
  value       = helm_release.kaito.status
}

output "gpu_operator_status" {
  description = "GPU operator Helm release status"
  value       = helm_release.gpu_operator.status
}

output "workspace_service_account" {
  description = "Service account for workspace management"
  value       = kubernetes_service_account.kaito_workspace_admin.metadata[0].name
}

output "example_workspace_name" {
  description = "Name of the example workspace"
  value       = var.create_example_workspace ? kubernetes_manifest.example_workspace[0].manifest.metadata.name : null
}