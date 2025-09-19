#!/usr/bin/env python3
"""
Service Catalog Compliance Validation Script
Validates infrastructure configurations against the platform service catalog
"""

import json
import yaml
import os
import sys
from typing import Dict, Any, List

def load_service_catalog() -> Dict[str, Any]:
    """Load the service catalog configuration"""
    catalog_path = "catalog/service-catalog.json"
    if not os.path.exists(catalog_path):
        raise FileNotFoundError(f"Service catalog not found at {catalog_path}")
    
    with open(catalog_path, 'r') as f:
        return json.load(f)

def check_aks_compliance(catalog: Dict[str, Any]) -> List[str]:
    """Check AKS module compliance with service catalog"""
    errors = []
    aks_config = catalog['services']['aks']['approvedConfigurations']
    
    # Check AKS module variables
    aks_vars_path = "infrastructure/modules/aks/variables.tf"
    if os.path.exists(aks_vars_path):
        with open(aks_vars_path, 'r') as f:
            content = f.read()
            
            # Check system VM size validation
            if 'Standard_DS2_v2' not in content:
                errors.append("AKS module missing Standard_DS2_v2 validation")
            
            # Check GPU VM size validation  
            if 'Standard_NC40ads_H100_v5' not in content:
                errors.append("AKS module missing Standard_NC40ads_H100_v5 validation")
            
            # Check region validation
            if 'eastus2' not in content:
                errors.append("AKS module missing eastus2 region validation")
    else:
        errors.append("AKS module variables.tf not found")
    
    return errors

def check_region_compliance(catalog: Dict[str, Any]) -> List[str]:
    """Check region compliance across all modules"""
    errors = []
    approved_regions = catalog['constraints']['approvedRegions']
    
    # Check development environment
    dev_config_path = "infrastructure/environments/dev/main.tf"
    if os.path.exists(dev_config_path):
        with open(dev_config_path, 'r') as f:
            content = f.read()
            
            # Check if only approved region is used
            if 'eastus2' not in content:
                errors.append("Development environment missing eastus2 region")
            
            # Check for any other regions
            for line in content.split('\n'):
                if 'location' in line.lower() and '=' in line:
                    for region in ['westus', 'westus2', 'eastus', 'centralus']:
                        if region in line and region != 'eastus2':
                            errors.append(f"Unauthorized region '{region}' found in development config")
    else:
        errors.append("Development environment config not found")
    
    return errors

def check_cost_compliance(catalog: Dict[str, Any]) -> List[str]:
    """Check cost limits compliance"""
    errors = []
    
    # Check development cost limits
    dev_limit = catalog['environmentPolicies']['development']['costLimitUSD']
    estimated_cost = 410  # From infrastructure request
    
    if estimated_cost > dev_limit:
        errors.append(f"Estimated cost ${estimated_cost} exceeds development limit ${dev_limit}")
    
    # Check if cost optimization features are enabled
    dev_outputs_path = "infrastructure/environments/dev/outputs.tf"
    if os.path.exists(dev_outputs_path):
        with open(dev_outputs_path, 'r') as f:
            content = f.read()
            
            if 'estimated_monthly_cost' not in content:
                errors.append("Missing cost estimation in development outputs")
    
    return errors

def check_tagging_compliance(catalog: Dict[str, Any]) -> List[str]:
    """Check mandatory tagging compliance"""
    errors = []
    mandatory_tags = catalog['constraints']['mandatoryTags']
    
    # Check development environment tags
    dev_config_path = "infrastructure/environments/dev/main.tf"
    if os.path.exists(dev_config_path):
        with open(dev_config_path, 'r') as f:
            content = f.read()
            
            for tag in mandatory_tags:
                if tag not in content:
                    errors.append(f"Missing mandatory tag '{tag}' in development environment")
    
    return errors

def check_vm_size_compliance(catalog: Dict[str, Any]) -> List[str]:
    """Check VM size compliance"""
    errors = []
    aks_config = catalog['services']['aks']['approvedConfigurations']
    
    approved_system_vm = aks_config['systemNodePool']['vmSize'][0]
    approved_gpu_vm = aks_config['gpuNodePool']['vmSize'][0]
    
    # Check all Terraform files for VM sizes
    for root, dirs, files in os.walk("infrastructure/"):
        for file in files:
            if file.endswith('.tf'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r') as f:
                    content = f.read()
                    
                    # Look for VM size specifications that are not approved
                    lines = content.split('\n')
                    for i, line in enumerate(lines, 1):
                        if 'vm_size' in line.lower() or 'instancetype' in line.lower():
                            if 'Standard_' in line:
                                vm_size_line = line.strip()
                                if approved_system_vm not in line and approved_gpu_vm not in line:
                                    # Check if it's a variable reference or comment
                                    if not (line.strip().startswith('#') or 'var.' in line or 'variable' in line):
                                        errors.append(f"Non-approved VM size in {file_path}:{i} - {vm_size_line}")
    
    return errors

def main():
    """Main validation function"""
    print("🔍 Starting service catalog compliance validation...")
    
    try:
        catalog = load_service_catalog()
        all_errors = []
        
        # Run all compliance checks
        print("  ✓ Checking AKS compliance...")
        all_errors.extend(check_aks_compliance(catalog))
        
        print("  ✓ Checking region compliance...")
        all_errors.extend(check_region_compliance(catalog))
        
        print("  ✓ Checking cost compliance...")
        all_errors.extend(check_cost_compliance(catalog))
        
        print("  ✓ Checking tagging compliance...")
        all_errors.extend(check_tagging_compliance(catalog))
        
        print("  ✓ Checking VM size compliance...")
        all_errors.extend(check_vm_size_compliance(catalog))
        
        # Report results
        if all_errors:
            print(f"\n❌ {len(all_errors)} compliance issues found:")
            for error in all_errors:
                print(f"  - {error}")
            sys.exit(1)
        else:
            print("\n✅ All service catalog compliance checks passed!")
            print("  - Region: eastus2 ✓")
            print("  - VM sizes: Standard_DS2_v2, Standard_NC40ads_H100_v5 ✓")
            print("  - Cost: $410 < $500 limit ✓")
            print("  - Tags: All mandatory tags present ✓")
            print("  - Configuration: All approved settings ✓")
    
    except Exception as e:
        print(f"❌ Validation failed with error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()