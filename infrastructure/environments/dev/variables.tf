# Development Environment Variables

# These variables can be customized when deploying to the development environment
# Default values are set to match the approved infrastructure request

variable "cluster_name_override" {
  description = "Override the default cluster name"
  type        = string
  default     = ""
}

variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown for cost optimization (development policy)"
  type        = bool
  default     = true
}

variable "shutdown_time" {
  description = "Time to shutdown resources (development policy: 19:00)"
  type        = string
  default     = "19:00"
}

variable "shutdown_weekends" {
  description = "Shutdown resources on weekends (development policy)"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}