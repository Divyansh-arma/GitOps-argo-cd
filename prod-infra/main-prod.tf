terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.69.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create a new container registry
resource "digitalocean_container_registry" "prod-smoke" {
  name                   = "prod-smoke"
  subscription_tier_slug = "starter"
  region                 = var.region
}

resource "digitalocean_container_registry_docker_credentials" "example" {
  registry_name = digitalocean_container_registry.prod-smoke.name
}

# Create a Kubernetes cluster

resource "digitalocean_kubernetes_cluster" "py-app-prod" {
  name   = "py-app-prod"
  region = var.region

  version = "latest"

  node_pool {
    name       = "python-app-prod"
    size       = "s-1vcpu-2gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 2

  }
  registry_integration = true
}