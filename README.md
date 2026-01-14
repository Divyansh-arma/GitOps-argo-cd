# GitOps with Argo CD

A complete GitOps implementation for deploying an e-commerce application on DigitalOcean Kubernetes using Argo CD, Terraform, and GitHub Actions.

## 🏗️ Architecture Overview

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────────┐
│   Developer     │────▶│   GitHub Actions │────▶│  DigitalOcean       │
│   Push Code     │     │   CI Pipeline    │     │  Container Registry │
└─────────────────┘     └──────────────────┘     └─────────────────────┘
                                │                          │
                                ▼                          │
                        ┌──────────────────┐               │
                        │  Update Image    │               │
                        │  Tag in Manifest │               │
                        └──────────────────┘               │
                                │                          │
                                ▼                          ▼
                        ┌──────────────────┐     ┌─────────────────────┐
                        │   Argo CD        │────▶│  DigitalOcean       │
                        │   Sync & Deploy  │     │  Kubernetes Cluster │
                        └──────────────────┘     └─────────────────────┘
```

## 📁 Branch Structure

| Branch | Purpose |
|--------|---------|
| `main` | Application source code and CI/CD workflow |
| `app-manifests` | Kubernetes deployment manifests (monitored by Argo CD) |
| `app-infra` | Terraform infrastructure code for DigitalOcean |

## 🔄 GitOps Workflow

1. **Developer pushes code** to the `main` branch (under `ecommerce-app/` directory)
2. **GitHub Actions workflow** triggers automatically:
   - Builds Docker image
   - Pushes image to DigitalOcean Container Registry
   - Updates image tag in `app-manifests` branch
3. **Argo CD detects changes** in the `app-manifests` branch
4. **Argo CD syncs** the new deployment to the Kubernetes cluster

## 🛠️ Prerequisites

- [DigitalOcean Account](https://www.digitalocean.com/)
- [Terraform](https://www.terraform.io/downloads) installed locally
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed locally
- [doctl](https://docs.digitalocean.com/reference/doctl/how-to/install/) CLI installed
- GitHub repository with Actions enabled

## 🚀 Getting Started

### 1. Infrastructure Setup (app-infra branch)

```bash
# Switch to infrastructure branch
git checkout app-infra

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply infrastructure
terraform apply
```

This creates:
- DigitalOcean Kubernetes Cluster
- DigitalOcean Container Registry

### 2. Configure GitHub Secrets

Add the following secrets to your GitHub repository:

| Secret Name | Description |
|-------------|-------------|
| `DO_CONNECT_TOKEN` | DigitalOcean API token |
| `GITOPS_TOKEN` | GitHub PAT with repo write access |

### 3. Configure GitHub Variables

Add the following variables to your GitHub repository:

| Variable Name | Description |
|---------------|-------------|
| `DEPLOYMENT_NAME` | Name of the Kubernetes deployment |
| `REGISTRY` | DigitalOcean registry URL |
| `IMAGE_NAME` | Docker image name |
| `CONTAINER_NAME` | Container name in deployment |
| `DO_CLUSTER_NAME` | DigitalOcean Kubernetes cluster name |

### 4. Install Argo CD on Kubernetes

```bash
# Connect to your DigitalOcean cluster
doctl kubernetes cluster kubeconfig save <cluster-name>

# Create Argo CD namespace
kubectl create namespace argocd

# Install Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access Argo CD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 5. Configure Argo CD Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ecommerce-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Divyansh-arma/GitOps-argo-cd.git
    targetRevision: app-manifests
    path: Deployment
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## 📂 Project Structure

```
GitOps-Argo-CD/
├── main branch
│   ├── .github/
│   │   └── workflows/
│   │       └── Build-push.yml    # CI/CD pipeline
│   ├── ecommerce-app/            # Application source code
│   │   ├── Dockerfile
│   │   └── ...
│   └── README.md
│
├── app-manifests branch
│   └── Deployment/
│       └── deployment.yaml       # Kubernetes manifests
│
└── app-infra branch
    ├── main.tf                   # Terraform configuration
    ├── variables.tf
    └── outputs.tf
```

## 🔧 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/Build-push.yml`) performs:

1. **Checkout** source code
2. **Authenticate** with DigitalOcean
3. **Build** Docker image with run number tag
4. **Push** image to DigitalOcean Container Registry
5. **Update** deployment manifest in `app-manifests` branch
6. **Commit & Push** changes to trigger Argo CD sync

## 🔐 Security Considerations

- Store all sensitive data in GitHub Secrets
- Use least-privilege access for service accounts
- Enable RBAC in Kubernetes cluster
- Regularly rotate API tokens
- Use private container registry

## 🐛 Troubleshooting

### GitHub Actions Permission Error
If you see "Permission denied" when pushing to `app-manifests`:
- Ensure `GITOPS_TOKEN` has `repo` scope
- Verify the token is not expired

### Argo CD Not Syncing
```bash
# Check application status
kubectl get applications -n argocd

# View sync status
argocd app get ecommerce-app

# Force sync
argocd app sync ecommerce-app
```

### Image Pull Errors
```bash
# Verify registry secret exists
kubectl get secrets

# Check pod events
kubectl describe pod <pod-name>
```

## 📚 Resources

- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [DigitalOcean Kubernetes](https://docs.digitalocean.com/products/kubernetes/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Terraform DigitalOcean Provider](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)

## 📝 License

This project is licensed under the MIT License.

## 👤 Author

Divyansh Sharma

---

⭐ Star this repository if you found it helpful!