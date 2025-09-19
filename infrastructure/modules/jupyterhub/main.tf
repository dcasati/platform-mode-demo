# JupyterHub on Kubernetes with GPU Support
# Based on Zero to JupyterHub for Kubernetes

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Create JupyterHub namespace
resource "kubernetes_namespace" "jupyterhub" {
  metadata {
    name = var.namespace
    labels = {
      name                                 = var.namespace
      "pod-security.kubernetes.io/enforce" = "restricted"
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }
  }
}

# Create storage class for Azure managed disks
resource "kubernetes_storage_class" "jupyterhub_storage" {
  metadata {
    name = "jupyterhub-storage"
  }

  storage_provisioner    = "disk.csi.azure.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    skuName = "Premium_LRS"
    kind    = "managed"
  }
}

# Create persistent volume claim for JupyterHub hub storage
resource "kubernetes_persistent_volume_claim" "jupyterhub_hub" {
  metadata {
    name      = "jupyterhub-hub-storage"
    namespace = kubernetes_namespace.jupyterhub.metadata[0].name
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.jupyterhub_storage.metadata[0].name
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

# Install JupyterHub using Helm
resource "helm_release" "jupyterhub" {
  name       = "jupyterhub"
  repository = "https://hub.jupyter.org/helm-chart/"
  chart      = "jupyterhub"
  version    = "3.2.1" # Latest stable version
  namespace  = kubernetes_namespace.jupyterhub.metadata[0].name

  # Use values file for complex configuration
  values = [
    templatefile("${path.module}/jupyterhub-values.yaml", {
      storage_class     = kubernetes_storage_class.jupyterhub_storage.metadata[0].name
      enable_gpu        = var.enable_gpu_support
      gpu_node_selector = var.gpu_node_selector
      environment       = var.environment
      cluster_domain    = var.cluster_domain
      hub_storage_size  = var.hub_storage_size
      user_storage_size = var.user_storage_size
      cpu_limit         = var.cpu_limit
      memory_limit      = var.memory_limit
      gpu_limit         = var.gpu_limit
      image_name        = var.jupyter_image
    })
  ]

  # Set timeout for large deployments
  timeout = 600

  depends_on = [
    kubernetes_namespace.jupyterhub,
    kubernetes_storage_class.jupyterhub_storage
  ]
}

# Create service account for KAITO operator integration
resource "kubernetes_service_account" "kaito_integration" {
  count = var.enable_kaito_integration ? 1 : 0

  metadata {
    name      = "kaito-integration"
    namespace = kubernetes_namespace.jupyterhub.metadata[0].name
  }

  automount_service_account_token = true
}

# Create cluster role for KAITO integration
resource "kubernetes_cluster_role" "kaito_integration" {
  count = var.enable_kaito_integration ? 1 : 0

  metadata {
    name = "kaito-integration"
  }

  rule {
    api_groups = ["kaito.sh"]
    resources  = ["*"]
    verbs      = ["get", "list", "create", "update", "patch", "delete"]
  }
}

# Create cluster role binding for KAITO integration
resource "kubernetes_cluster_role_binding" "kaito_integration" {
  count = var.enable_kaito_integration ? 1 : 0

  metadata {
    name = "kaito-integration"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kaito_integration[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kaito_integration[0].metadata[0].name
    namespace = kubernetes_namespace.jupyterhub.metadata[0].name
  }
}

# Create config map for KAITO tools and examples
resource "kubernetes_config_map" "kaito_examples" {
  count = var.enable_kaito_integration ? 1 : 0

  metadata {
    name      = "kaito-examples"
    namespace = kubernetes_namespace.jupyterhub.metadata[0].name
  }

  data = {
    "kaito-setup.sh"         = file("${path.module}/scripts/kaito-setup.sh")
    "example-inference.yaml" = file("${path.module}/examples/example-inference.yaml")
  }
}