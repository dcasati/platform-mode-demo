#!/bin/bash
# KAITO Setup Script for JupyterHub Environment
# This script installs KAITO CLI tools and sets up the development environment

set -e

echo "🚀 Setting up KAITO development environment..."

# Install kubectl if not already present
if ! command -v kubectl &> /dev/null; then
    echo "📦 Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
fi

# Install helm if not already present
if ! command -v helm &> /dev/null; then
    echo "📦 Installing Helm..."
    curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz -o helm.tar.gz
    tar -zxvf helm.tar.gz
    sudo mv linux-amd64/helm /usr/local/bin/helm
    rm -rf linux-amd64 helm.tar.gz
fi

# Install Python packages for KAITO development
echo "🐍 Installing Python packages..."
pip install --user \
    kubernetes==27.2.0 \
    pyyaml==6.0.1 \
    requests==2.31.0 \
    jupyter==1.0.0 \
    tensorflow==2.13.0 \
    torch==2.0.1 \
    transformers==4.34.0 \
    accelerate==0.23.0

# Add user bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Create KAITO workspace directory
mkdir -p ~/kaito-workspace
cd ~/kaito-workspace

# Create a sample KAITO configuration
cat > kaito-config.yaml << 'EOF'
# Sample KAITO Configuration for JupyterHub Development
apiVersion: v1
kind: ConfigMap
metadata:
  name: kaito-dev-config
  namespace: jupyterhub
data:
  workspace: |
    apiVersion: kaito.sh/v1alpha1
    kind: Workspace
    metadata:
      name: sample-workspace
      namespace: jupyterhub
    spec:
      instance:
        image: "mcr.microsoft.com/aks/kaito/kaito-inference:latest"
        instanceType: "Standard_NC40ads_H100_v5"
      resource:
        count: 1
        instanceType: "Standard_NC40ads_H100_v5"
      inference:
        preset:
          name: "phi-2"
EOF

# Create helper scripts
cat > setup-model-inference.py << 'EOF'
#!/usr/bin/env python3
"""
Helper script to set up AI model inference with KAITO
"""

import yaml
import subprocess
import sys

def create_kaito_workspace(model_name, instance_type="Standard_NC40ads_H100_v5"):
    """Create a KAITO workspace for model inference"""
    
    workspace = {
        'apiVersion': 'kaito.sh/v1alpha1',
        'kind': 'Workspace',
        'metadata': {
            'name': f'{model_name}-workspace',
            'namespace': 'jupyterhub'
        },
        'spec': {
            'instance': {
                'image': 'mcr.microsoft.com/aks/kaito/kaito-inference:latest',
                'instanceType': instance_type
            },
            'resource': {
                'count': 1,
                'instanceType': instance_type
            },
            'inference': {
                'preset': {
                    'name': model_name
                }
            }
        }
    }
    
    # Write workspace to file
    with open(f'{model_name}-workspace.yaml', 'w') as f:
        yaml.dump(workspace, f, default_flow_style=False)
    
    print(f"✅ Created workspace configuration: {model_name}-workspace.yaml")
    
    # Apply to cluster
    try:
        result = subprocess.run(['kubectl', 'apply', '-f', f'{model_name}-workspace.yaml'], 
                              capture_output=True, text=True, check=True)
        print(f"✅ Applied workspace to cluster: {result.stdout}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to apply workspace: {e.stderr}")
        return False
    
    return True

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python setup-model-inference.py <model_name>")
        print("Available models: phi-2, llama-7b, mistral-7b")
        sys.exit(1)
    
    model_name = sys.argv[1]
    if create_kaito_workspace(model_name):
        print(f"🎉 Successfully set up {model_name} inference workspace!")
    else:
        print(f"❌ Failed to set up {model_name} workspace")
        sys.exit(1)
EOF

chmod +x setup-model-inference.py

echo "✅ KAITO development environment setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Restart your terminal or run: source ~/.bashrc"
echo "2. Check kubectl connection: kubectl get nodes"
echo "3. Try creating a model workspace: python setup-model-inference.py phi-2"
echo "4. Explore examples in ~/kaito-workspace/"
echo ""
echo "📚 Resources:"
echo "- KAITO Documentation: https://github.com/kaito-project/kaito"
echo "- Jupyter AI Examples: ~/kaito-workspace/"
echo "- Configuration Files: ~/kaito-workspace/*.yaml"