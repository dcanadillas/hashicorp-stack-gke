terraform {
  required_version = ">= 0.15.0"
  # backend "remote"{}
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.67.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.1.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.3"
    }
  }
}

data "google_client_config" "default" {
}

# Defer reading the cluster data until the GKE cluster exists.
data "google_container_cluster" "primary" {
  name = var.cluster_name
  location = var.gcp_zone
  depends_on = [module.gke]
}

provider "google" {
  project = var.gcp_project
  region = var.gcp_region
}
provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.primary.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
    )
  }
}
provider "kubernetes" {
  host  = "https://${data.google_container_cluster.primary.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}