terraform {
  required_version = ">= 1.1.0"
  # backend "remote"{}
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.0.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.15.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.5.1"
    }
  }
}

locals {
  host = var.create_gke ? "https://${module.gke[0].cluster_endpoint}" : "https://${data.google_container_cluster.primary[0].endpoint}"
  ca_cert = var.create_gke ? module.gke[0].ca_certificate : base64decode(data.google_container_cluster.primary[0].master_auth[0].cluster_ca_certificate,)
}


data "google_client_config" "default" {
}

# Defer reading the cluster data until the GKE cluster exists.
data "google_container_cluster" "primary" {
  count = var.create_gke ? 0 : 1
  name = var.cluster_name
  location = var.gcp_zone
}

provider "google" {
  project = var.gcp_project
  region = var.gcp_region
}
provider "helm" {
  kubernetes {
    host = local.host
    token = data.google_client_config.default.access_token
    # token = data.google_service_account_access_token.default.access_token
    cluster_ca_certificate = local.ca_cert
  }
}

provider "kubernetes" {
  host = local.host
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = local.ca_cert
}