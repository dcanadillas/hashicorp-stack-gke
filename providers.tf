terraform {
  required_version = ">= 0.15.0"
  # backend "remote"{}
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.63.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.9.0"
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
  # name = var.create_gke ? module.gke[0].cluster_name : var.cluster_name
  name = var.cluster_name
  location = var.gcp_zone
  # depends_on = [module.gke]
}

provider "google" {
  project = var.gcp_project
  region = var.gcp_region
}
provider "helm" {
  kubernetes {
    # host  = "https://${data.google_container_cluster.primary.endpoint}"
    # host = "https://${module.gke[0].cluster_endpoint}"
    host = local.host
    token = data.google_client_config.default.access_token
    # token = data.google_service_account_access_token.default.access_token

    # cluster_ca_certificate = base64decode(
    #   data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
    # )
    cluster_ca_certificate = local.ca_cert
  }
}

provider "kubernetes" {
  # host  = "https://${data.google_container_cluster.primary.endpoint}"
  # host = "https://${module.gke[0].cluster_endpoint}"
  host = local.host
  token = data.google_client_config.default.access_token
  # token = data.google_service_account_access_token.default.access_token
  # cluster_ca_certificate = base64decode(
  #   data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  # )
  cluster_ca_certificate = local.ca_cert
}