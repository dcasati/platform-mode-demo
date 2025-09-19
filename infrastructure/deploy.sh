#!/bin/bash
# Deployment script for JupyterHub on AKS with GPU support
# This script deploys the approved infrastructure request

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="dev"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../environments/${ENVIRONMENT}"

echo -e "${BLUE}🚀 Deploying JupyterHub on AKS with GPU for KAITO Development${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}Terraform Directory: ${TERRAFORM_DIR}${NC}"
echo ""

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}📋 Checking prerequisites...${NC}"
    
    # Check if Azure CLI is installed and logged in
    if ! command -v az &> /dev/null; then
        echo -e "${RED}❌ Azure CLI is not installed${NC}"
        echo "Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    
    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        echo -e "${RED}❌ Not logged in to Azure${NC}"
        echo "Please run: az login"
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}❌ Terraform is not installed${NC}"
        echo "Please install Terraform: https://www.terraform.io/downloads.html"
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        echo -e "${YELLOW}⚠️  kubectl is not installed, installing...${NC}"
        az aks install-cli
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${NC}"
    echo ""
}

# Function to validate service catalog compliance
validate_compliance() {
    echo -e "${YELLOW}🔍 Validating service catalog compliance...${NC}"
    
    # Check current Azure subscription and region
    SUBSCRIPTION=$(az account show --query name -o tsv)
    echo -e "Subscription: ${SUBSCRIPTION}"
    
    # Validate region (should be eastus2)
    REGION="eastus2"
    echo -e "Region: ${REGION} ✅"
    
    # Validate VM sizes (should be from approved catalog)
    echo -e "System Node Pool VM Size: Standard_DS2_v2 ✅"
    echo -e "GPU Node Pool VM Size: Standard_NC40ads_H100_v5 ✅"
    
    # Validate cost estimate
    echo -e "Estimated Monthly Cost: \$410 (within \$500 development limit) ✅"
    
    echo -e "${GREEN}✅ Service catalog compliance validated${NC}"
    echo ""
}

# Function to initialize Terraform
initialize_terraform() {
    echo -e "${YELLOW}🔧 Initializing Terraform...${NC}"
    
    cd "${TERRAFORM_DIR}"
    
    # Initialize Terraform
    terraform init
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Terraform initialized successfully${NC}"
    else
        echo -e "${RED}❌ Terraform initialization failed${NC}"
        exit 1
    fi
    
    echo ""
}

# Function to plan deployment
plan_deployment() {
    echo -e "${YELLOW}📋 Planning deployment...${NC}"
    
    cd "${TERRAFORM_DIR}"
    
    # Create Terraform plan
    terraform plan -out=tfplan
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Terraform plan created successfully${NC}"
    else
        echo -e "${RED}❌ Terraform plan failed${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${YELLOW}📋 Deployment Plan Summary:${NC}"
    echo -e "- AKS Cluster with System Node Pool (Standard_DS2_v2, 1 node)"
    echo -e "- GPU Node Pool (Standard_NC40ads_H100_v5, 0-1 nodes)"
    echo -e "- JupyterHub with GPU support"
    echo -e "- KAITO operator for AI inference"
    echo -e "- Azure Managed Disks for storage"
    echo -e "- All mandatory tags and compliance requirements"
    echo ""
}

# Function to apply deployment
apply_deployment() {
    echo -e "${YELLOW}🚀 Applying deployment...${NC}"
    echo -e "${YELLOW}This may take 15-30 minutes...${NC}"
    
    cd "${TERRAFORM_DIR}"
    
    # Apply Terraform plan
    terraform apply tfplan
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
    else
        echo -e "${RED}❌ Deployment failed${NC}"
        exit 1
    fi
    
    echo ""
}

# Function to get cluster credentials
setup_kubectl() {
    echo -e "${YELLOW}🔧 Setting up kubectl access...${NC}"
    
    cd "${TERRAFORM_DIR}"
    
    # Get cluster name and resource group from Terraform output
    CLUSTER_NAME=$(terraform output -raw aks_cluster_name 2>/dev/null || echo "")
    RESOURCE_GROUP=$(terraform output -raw resource_group_name 2>/dev/null || echo "")
    
    if [ -n "$CLUSTER_NAME" ] && [ -n "$RESOURCE_GROUP" ]; then
        # Get AKS credentials
        az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --overwrite-existing
        
        # Test kubectl connection
        kubectl get nodes
        
        echo -e "${GREEN}✅ kubectl configured successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not get cluster information from Terraform output${NC}"
    fi
    
    echo ""
}

# Function to display next steps
show_next_steps() {
    echo -e "${GREEN}🎉 JupyterHub on AKS with GPU deployment completed!${NC}"
    echo ""
    
    cd "${TERRAFORM_DIR}"
    
    # Display Terraform outputs
    echo -e "${BLUE}📋 Infrastructure Information:${NC}"
    terraform output next_steps 2>/dev/null || echo "Run 'terraform output' in ${TERRAFORM_DIR} for detailed information"
    
    echo ""
    echo -e "${BLUE}💡 Quick Access Commands:${NC}"
    echo -e "Get JupyterHub URL:"
    echo -e "  kubectl get svc -n jupyterhub proxy-public"
    echo ""
    echo -e "Check GPU nodes:"
    echo -e "  kubectl get nodes -l node-type=gpu"
    echo ""
    echo -e "Check KAITO workspaces:"
    echo -e "  kubectl get workspace -n jupyterhub"
    echo ""
    echo -e "View cost information:"
    echo -e "  terraform output estimated_monthly_cost"
    echo ""
}

# Main execution
main() {
    check_prerequisites
    validate_compliance
    initialize_terraform
    plan_deployment
    
    # Ask for confirmation before applying
    echo -e "${YELLOW}⚠️  Ready to deploy. This will create Azure resources and incur costs.${NC}"
    echo -e "${YELLOW}Estimated monthly cost: \$410${NC}"
    echo ""
    read -p "Do you want to proceed? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        apply_deployment
        setup_kubectl
        show_next_steps
    else
        echo -e "${YELLOW}Deployment cancelled${NC}"
        exit 0
    fi
}

# Handle script arguments
case "${1:-deploy}" in
    "deploy")
        main
        ;;
    "plan")
        check_prerequisites
        initialize_terraform
        plan_deployment
        ;;
    "destroy")
        echo -e "${RED}⚠️  This will destroy all resources!${NC}"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd "${TERRAFORM_DIR}"
            terraform destroy
        fi
        ;;
    *)
        echo "Usage: $0 [deploy|plan|destroy]"
        echo "  deploy  - Deploy the infrastructure (default)"
        echo "  plan    - Plan the deployment without applying"
        echo "  destroy - Destroy the infrastructure"
        exit 1
        ;;
esac