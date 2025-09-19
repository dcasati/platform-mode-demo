# KAITO (Kubernetes AI Toolchain Operator) Module
# Deploys the KAITO operator for AI inference workloads

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

# Create KAITO system namespace
resource "kubernetes_namespace" "kaito_system" {
  metadata {
    name = var.kaito_namespace
    labels = {
      name            = var.kaito_namespace
      "control-plane" = "kaito-controller-manager"
    }
  }
}

# Install NVIDIA GPU Operator (prerequisite for KAITO)
resource "helm_release" "gpu_operator" {
  name       = "gpu-operator"
  repository = "https://helm.ngc.nvidia.com/nvidia"
  chart      = "gpu-operator"
  version    = "23.9.1"
  namespace  = "gpu-operator"

  create_namespace = true

  values = [
    yamlencode({
      operator = {
        defaultRuntime = "containerd"
      }
      driver = {
        enabled = true
        version = "535.129.03"
      }
      toolkit = {
        enabled = true
      }
      devicePlugin = {
        enabled = true
      }
      dcgmExporter = {
        enabled = true
      }
      gfd = {
        enabled = true
      }
      migManager = {
        enabled = false
      }
      nodeStatusExporter = {
        enabled = true
      }
      gds = {
        enabled = false
      }
      vfioManager = {
        enabled = false
      }
      sandboxWorkloads = {
        enabled = false
      }
    })
  ]

  timeout = 900 # GPU operator can take a while to deploy
}

# Install KAITO operator using Helm
resource "helm_release" "kaito" {
  name       = "kaito-workspace"
  repository = "https://kaito-project.github.io/kaito"
  chart      = "kaito-workspace"
  version    = var.kaito_version
  namespace  = kubernetes_namespace.kaito_system.metadata[0].name

  values = [
    yamlencode({
      # Controller configuration
      controller = {
        image = {
          repository = "mcr.microsoft.com/aks/kaito/kaito-workspace"
          tag        = var.kaito_version
        }
        replicas = 1
        resources = {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }
      }

      # Webhook configuration
      webhook = {
        enabled = true
        port    = 9443
      }

      # RBAC configuration
      rbac = {
        create = true
      }

      # Service account configuration
      serviceAccount = {
        create      = true
        annotations = {}
      }

      # Node selector for controller placement
      nodeSelector = {}

      # Tolerations for controller
      tolerations = []

      # Affinity for controller
      affinity = {}
    })
  ]

  timeout = 600

  depends_on = [
    kubernetes_namespace.kaito_system,
    helm_release.gpu_operator
  ]
}

# Create cluster role for KAITO workspace management
resource "kubernetes_cluster_role" "kaito_workspace_admin" {
  metadata {
    name = "kaito-workspace-admin"
  }

  rule {
    api_groups = ["kaito.sh"]
    resources  = ["workspaces"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["*"]
  }

  rule {
    api_groups = [""]
    resources  = ["services", "configmaps", "secrets", "persistentvolumeclaims"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies", "ingresses"]
    verbs      = ["*"]
  }
}

# Create service account for workspace management
resource "kubernetes_service_account" "kaito_workspace_admin" {
  metadata {
    name      = "kaito-workspace-admin"
    namespace = var.workspace_namespace
  }

  automount_service_account_token = true
}

# Bind cluster role to service account
resource "kubernetes_cluster_role_binding" "kaito_workspace_admin" {
  metadata {
    name = "kaito-workspace-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kaito_workspace_admin.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kaito_workspace_admin.metadata[0].name
    namespace = var.workspace_namespace
  }
}

# Create example workspace for development
resource "kubernetes_manifest" "example_workspace" {
  count = var.create_example_workspace ? 1 : 0

  manifest = {
    apiVersion = "kaito.sh/v1alpha1"
    kind       = "Workspace"
    metadata = {
      name      = "example-phi2"
      namespace = var.workspace_namespace
    }
    spec = {
      instance = {
        image        = "mcr.microsoft.com/aks/kaito/kaito-inference:latest"
        instanceType = "Standard_NC40ads_H100_v5"
      }
      resource = {
        count        = 1
        instanceType = "Standard_NC40ads_H100_v5"
      }
      inference = {
        preset = {
          name = "phi-2"
        }
      }
    }
  }

  depends_on = [helm_release.kaito]
}