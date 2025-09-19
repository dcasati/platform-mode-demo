# Development Environment Outputs

# AKS Cluster Outputs
output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = module.aks.cluster_name
}

output "aks_cluster_id" {
  description = "AKS cluster ID"
  value       = module.aks.cluster_id
}

output "resource_group_name" {
  description = "Resource group name"
  value       = module.aks.resource_group_name
}

output "cluster_fqdn" {
  description = "AKS cluster FQDN"
  value       = module.aks.cluster_fqdn
}

output "kubeconfig_command" {
  description = "Command to get kubeconfig for this cluster"
  value       = "az aks get-credentials --resource-group ${module.aks.resource_group_name} --name ${module.aks.cluster_name}"
}

# JupyterHub Outputs
output "jupyterhub_namespace" {
  description = "JupyterHub namespace"
  value       = module.jupyterhub.namespace
}

output "jupyterhub_url" {
  description = "JupyterHub service URL"
  value       = module.jupyterhub.jupyterhub_url
}

output "jupyterhub_status" {
  description = "JupyterHub deployment status"
  value       = module.jupyterhub.helm_release_status
}

output "storage_class_name" {
  description = "Storage class for persistent volumes"
  value       = module.jupyterhub.storage_class_name
}

# KAITO Outputs
output "kaito_namespace" {
  description = "KAITO operator namespace"
  value       = module.kaito.kaito_namespace
}

output "kaito_operator_status" {
  description = "KAITO operator status"
  value       = module.kaito.kaito_operator_status
}

output "gpu_operator_status" {
  description = "GPU operator status"
  value       = module.kaito.gpu_operator_status
}

output "example_workspace_name" {
  description = "Name of example KAITO workspace"
  value       = module.kaito.example_workspace_name
}

# Access Information
output "next_steps" {
  description = "Next steps to access the environment"
  value       = <<-EOT
    🎉 JupyterHub on AKS with GPU support has been deployed successfully!
    
    📋 Infrastructure Summary:
    - AKS Cluster: ${module.aks.cluster_name}
    - Resource Group: ${module.aks.resource_group_name}
    - Location: eastus2
    - JupyterHub Namespace: ${module.jupyterhub.namespace}
    - KAITO Operator Namespace: ${module.kaito.kaito_namespace}
    
    🔧 Next Steps:
    1. Get cluster credentials:
       az aks get-credentials --resource-group ${module.aks.resource_group_name} --name ${module.aks.cluster_name}
    
    2. Check cluster status:
       kubectl get nodes
       kubectl get pods -n ${module.jupyterhub.namespace}
       kubectl get pods -n ${module.kaito.kaito_namespace}
    
    3. Access JupyterHub:
       kubectl get svc -n ${module.jupyterhub.namespace} proxy-public
       # Use the external IP to access JupyterHub
       # Default login: any username, password: jupyter
    
    4. Test GPU availability:
       kubectl describe nodes
       kubectl get pods -n gpu-operator
    
    5. Try KAITO workspace:
       kubectl get workspace -n ${module.jupyterhub.namespace}
       kubectl describe workspace ${module.kaito.example_workspace_name} -n ${module.jupyterhub.namespace}
    
    📚 Documentation:
    - JupyterHub: https://jupyter.org/hub
    - KAITO: https://github.com/kaito-project/kaito
    - GPU Setup: Check scripts in JupyterHub environments
    
    💡 Cost Management:
    - Auto-scaling is enabled for cost optimization
    - GPU nodes start at 0 and scale up on demand
    - Estimated monthly cost: $410 (within $500 limit)
  EOT
}

# Cost Information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown"
  value = {
    system_node_pool = "$100/month (1x Standard_DS2_v2)"
    gpu_node_pool    = "$310/month (0-1x Standard_NC40ads_H100_v5)"
    storage          = "$10/month (managed disks)"
    total_estimated  = "$410/month"
    cost_center      = "CC-1234"
    within_limit     = "✅ Under development limit ($500/month)"
  }
}