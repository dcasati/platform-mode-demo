# JupyterHub on AKS with GPU for KAITO Development - Usage Guide

This guide provides step-by-step instructions for deploying and using the JupyterHub environment with GPU support for KAITO development.

## 🚀 Quick Start Deployment

### Prerequisites

1. **Azure CLI** with appropriate permissions
2. **Azure Subscription** with quota for GPU VMs
3. **Cost Center approval** for ~$410/month

### 1. Deploy Infrastructure

```bash
# Clone the repository
git clone https://github.com/dcasati/platform-mode-demo.git
cd platform-mode-demo/infrastructure

# Deploy with validation
./deploy.sh
```

The deployment process:
- ✅ Validates service catalog compliance
- ✅ Creates AKS cluster with GPU support
- ✅ Installs JupyterHub with AI/ML environments
- ✅ Deploys KAITO operator
- ✅ Configures GPU scheduling and networking

### 2. Access JupyterHub

```bash
# Get JupyterHub URL
kubectl get svc -n jupyterhub proxy-public

# Access in browser at the external IP
# Login: any username, password: jupyter
```

## 🔬 AI/ML Development Environments

JupyterHub provides multiple pre-configured environments:

### Standard Environment (CPU-only)
- **Image**: `jupyter/datascience-notebook`
- **Resources**: 2 CPU, 4GB RAM
- **Use case**: Basic data science, small datasets

### GPU Environment (TensorFlow)
- **Image**: `jupyter/tensorflow-notebook`
- **Resources**: 4 CPU, 16GB RAM, 1 GPU
- **Pre-installed**: TensorFlow, CUDA, cuDNN
- **Use case**: Deep learning training and inference

### GPU Environment (PyTorch)
- **Image**: `jupyter/pytorch-notebook`
- **Resources**: 4 CPU, 16GB RAM, 1 GPU
- **Pre-installed**: PyTorch, CUDA, cuDNN
- **Use case**: PyTorch model development

### KAITO Development Environment
- **Image**: `jupyter/base-notebook` + KAITO tools
- **Resources**: 4 CPU, 16GB RAM, 1 GPU
- **Pre-installed**: KAITO CLI, Kubernetes tools, examples
- **Use case**: AI inference workload development

## 🤖 KAITO AI Inference Development

### Getting Started with KAITO

1. **Select KAITO Development Environment** in JupyterHub
2. **Open terminal** in Jupyter
3. **Run setup script**:
   ```bash
   bash /opt/kaito-examples/kaito-setup.sh
   ```

### Create Your First AI Inference Workspace

```python
# In a Jupyter notebook
import subprocess
import yaml

# Create a phi-2 model inference workspace
subprocess.run(['python', 'setup-model-inference.py', 'phi-2'])

# Check workspace status
subprocess.run(['kubectl', 'get', 'workspace', '-n', 'jupyterhub'])
```

### Example: Deploy Phi-2 Model for Inference

```bash
# Apply the example workspace
kubectl apply -f /opt/kaito-examples/example-inference.yaml

# Monitor deployment
kubectl get workspace phi2-inference-example -n jupyterhub -w

# Test inference (once ready)
kubectl port-forward -n jupyterhub svc/phi2-inference-service 8080:80
```

Then test with:
```python
import requests

# Test the inference endpoint
response = requests.post(
    'http://localhost:8080/chat',
    json={'messages': [{'role': 'user', 'content': 'Hello, how are you?'}]}
)
print(response.json())
```

## 🧪 GPU Development Examples

### Verify GPU Access

```python
# TensorFlow GPU check
import tensorflow as tf
print(f"GPU Available: {tf.config.list_physical_devices('GPU')}")

# PyTorch GPU check
import torch
print(f"GPU Available: {torch.cuda.is_available()}")
print(f"GPU Count: {torch.cuda.device_count()}")
print(f"GPU Name: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'N/A'}")
```

### Simple GPU Training Example

```python
import tensorflow as tf

# Create a simple model
model = tf.keras.Sequential([
    tf.keras.layers.Dense(128, activation='relu', input_shape=(784,)),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(10, activation='softmax')
])

# Compile with GPU acceleration
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# Load data
(x_train, y_train), (x_test, y_test) = tf.keras.datasets.mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

# Train on GPU
model.fit(x_train.reshape(-1, 784), y_train, epochs=5, batch_size=128)
```

## 📊 Monitoring and Management

### Check Resource Usage

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -n jupyterhub

# GPU usage
kubectl describe nodes -l node-type=gpu
```

### Manage User Sessions

```bash
# List active user pods
kubectl get pods -n jupyterhub -l component=singleuser-server

# Stop a user session
kubectl delete pod <user-pod-name> -n jupyterhub

# Check hub logs
kubectl logs -n jupyterhub -l app=jupyterhub
```

### Scale GPU Nodes

```bash
# Scale up GPU nodes
kubectl scale --replicas=1 deployment gpu-node-pool

# Check scaling status
kubectl get nodes -l node-type=gpu
```

## 💰 Cost Management

### Monitor Costs

The infrastructure includes automatic cost tracking:
- **Estimated monthly cost**: $410
- **GPU nodes**: Auto-scale from 0 to 1 based on demand
- **Auto-shutdown**: Enabled for development (7 PM weekdays, weekends)

### Cost Optimization Tips

1. **Use CPU environments** for development and testing
2. **Reserve GPU environments** for actual training/inference
3. **Stop unused sessions** to free up resources
4. **Monitor node scaling** with `kubectl get nodes`

### View Cost Breakdown

```bash
cd infrastructure/environments/dev
terraform output estimated_monthly_cost
```

## 🔧 Troubleshooting

### Common Issues

#### GPU Not Available
```bash
# Check GPU operator status
kubectl get pods -n gpu-operator

# Check node labels
kubectl get nodes --show-labels | grep accelerator

# Verify GPU taints
kubectl describe nodes -l node-type=gpu | grep Taints
```

#### JupyterHub Access Issues
```bash
# Check proxy status
kubectl get pods -n jupyterhub -l component=proxy

# Check hub status
kubectl logs -n jupyterhub -l component=hub

# Get external IP
kubectl get svc -n jupyterhub proxy-public
```

#### KAITO Workspace Issues
```bash
# Check KAITO operator
kubectl get pods -n kaito-system

# Check workspace status
kubectl describe workspace <workspace-name> -n jupyterhub

# Check KAITO CRDs
kubectl get crd | grep kaito
```

### Support Contacts

- **Platform Team**: GitHub Issues in this repository
- **Emergency**: Contact platform team directly
- **Documentation**: See `/docs` directory for policies

## 📚 Additional Resources

### Learning Materials
- **[JupyterHub Documentation](https://jupyter.org/hub)**
- **[KAITO GitHub Repository](https://github.com/kaito-project/kaito)**
- **[Kubernetes GPU Guide](https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/)**
- **[Azure AKS Documentation](https://docs.microsoft.com/azure/aks/)**

### Example Notebooks
Located in your JupyterHub environment under `/home/jovyan/examples/`:
- `gpu-tensorflow-example.ipynb`
- `gpu-pytorch-example.ipynb`
- `kaito-inference-example.ipynb`

### Advanced Configuration
See `infrastructure/modules/` for customizing:
- GPU node pool sizes
- JupyterHub profiles
- KAITO model presets
- Resource limits and quotas