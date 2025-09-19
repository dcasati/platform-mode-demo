# KAITO Module Variables

variable "kaito_namespace" {
  description = "Namespace for KAITO operator"
  type        = string
  default     = "kaito-system"
}

variable "workspace_namespace" {
  description = "Namespace where KAITO workspaces will be created"
  type        = string
  default     = "jupyterhub"
}

variable "kaito_version" {
  description = "KAITO operator version"
  type        = string
  default     = "0.3.0"
}

variable "create_example_workspace" {
  description = "Create an example workspace for testing"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}