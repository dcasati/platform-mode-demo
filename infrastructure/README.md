# Sample Infrastructure as Code directory structure
# This would contain Terraform, Bicep, or other IaC templates

## Example structure:
# ```
# infrastructure/
# ├── modules/           # Reusable infrastructure modules
# │   ├── compute/
# │   ├── networking/
# │   └── storage/
# ├── environments/      # Environment-specific configurations
# │   ├── dev/
# │   ├── staging/
# │   └── prod/
# └── templates/         # Base templates for common resources
#     ├── vm-template.tf
#     ├── aks-template.tf
#     └── storage-template.tf
# ```

# Place your infrastructure code here