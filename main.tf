locals {
  # config_bucket = data.google_storage_bucket.yamls.self_link != null ? data.google_storage_bucket.yamls.name : google_storage_bucket.yaml_values.0.name
  config_bucket = var.config_bucket == "" ? var.config_bucket : google_storage_bucket.yaml_values.0.name 
}

resource "random_id" "kubeconfig" {
  byte_length = 4
  prefix = "kubeconfig-"
}

data "google_service_account" "owner_project" {
  account_id = var.gcp_service_account
}

data "google_service_account_access_token" "default" {
  target_service_account = data.google_service_account.owner_project.email
  scopes                 = ["userinfo-email", "cloud-platform"]
  lifetime               = "300s"
}

module "gke" {
  count = var.create_gke ? 1 : 0
  source = "./modules/gke"
  gcp_project = var.gcp_project
  gcp_region = var.gcp_region
  gcp_zone = var.gcp_zone
  gke_cluster = var.cluster_name
  default_gke = var.default_gke
  default_network = var. default_network
  regional_k8s = var.regional_k8s
  numnodes = var.nodes
  owner = var.owner
  k8s_version = var.k8s_version
  secure_boot = var.gke_secure_boot
  private_nodes = var.gke_private_nodes
  service_account = var.gcp_service_account
}

module "tls" {
    source = "./modules/tls-certs"

    algorithm = var.tls_algorithm
    # ca_common_name = var.ca_common_name
    # ca_organization = var.ca_org
    # common_name = var.common_name
    vaulthost = var.domains
    # compute_address = 
    servers = var.nodes

}

module "consul" {
  depends_on = [
    module.gke,
    data.google_container_cluster.primary,
    data.google_client_config.default
  ]
  count = var.enable_consul ? 1 : 0
  source = "./modules/consul"
  gcp_project = var.gcp_project
  gcp_region = var.gcp_region
  gcp_zone = var.gcp_zone
  nodes = var.nodes
  consul_namespace = "consul"
  owner = var.owner
  cluster_name = var.cluster_name
  consul_license = var.consul_license
  config_bucket = local.config_bucket
  consul_enterprise = var.consul_enterprise
  consul_version=var.consul_version
  chart_version = var.chart_version
    
}

module "vault" {
  depends_on = [
    module.gke,
    data.google_container_cluster.primary
  ]
  count = var.enable_vault ? 1 : 0
  source = "./modules/vault"
  gcp_project = var.gcp_project
  gcp_region = var.gcp_region
  location = var.gcp_zone
  nodes = var.nodes
  vault_namespace = "vault"
  vault_version = var.vault_version
  cluster_endpoint = var.create_gke ? module.gke[0].cluster_endpoint : data.google_container_cluster.primary[0].endpoint
  cluster_name = var.cluster_name
  # ca_certificate = module.gke.ca_certificate
  ca_certificate = var.create_gke ? module.gke[0].ca_certificate : data.google_container_cluster.primary[0].master_auth.0.cluster_ca_certificate
  config_bucket = local.config_bucket
  gcp_service_account = var.gcp_service_account
  key_ring = var.key_ring
  vault_cert = var.own_certs ? var.vault_cert : module.tls.vault_crt
  vault_ca = var.own_certs ? var.vault_ca : module.tls.vault_ca
  vault_key = var.own_certs ? var.vault_key : module.tls.vault_key
  create_kms = var.create_kms
  crypto_key = var.crypto_key
  tls = var.tls
  vault_license = var.vault_license
}

module "waypoint" {
  depends_on = [
    module.gke
  ]
  count = var.enable_waypoint ? 1 : 0
  source = "./modules/waypoint"
  waypoint_namespace = var.waypoint_namespace
  waypoint_version = var.waypoint_version
}


# data "google_storage_bucket" "yamls" {
#   name = var.config_bucket
# }

resource "google_storage_bucket" "yaml_values" {
  count = var.config_bucket == ""   ? 0 : 1
  name          = "${var.cluster_name}-${var.config_bucket}"
  location      = "EUROPE-WEST1"
  uniform_bucket_level_access = true
  force_destroy = true

  # lifecycle_rule {
  #   condition {
  #     age = 3
  #   }
  #   action {
  #     type = "Delete"
  #   }
  # }
}

resource "google_storage_bucket_object" "kubeconfig" {
  depends_on = [module.gke]
  count = var.config_bucket != "" ? 1 : 0
  name   = "${var.cluster_name}-${random_id.kubeconfig.dec}.yml"
#   content = nonsensitive(module.gke.kubeconfig)
  content = templatefile("${path.root}/templates/kubeconfig.yaml", {
    cluster_name = var.create_gke ? module.gke[0].cluster_endpoint : data.google_container_cluster.primary[0].endpoint,
    endpoint =  var.create_gke ? module.gke[0].cluster_endpoint : data.google_container_cluster.primary[0].endpoint,
    user_name ="admin",
    cluster_ca = base64encode(local.ca_cert),
    client_cert = "...",
    client_cert_key = "...",
    # client_cert = data.google_container_cluster.primary.master_auth.0.client_certificate,
    # client_cert_key = data.google_container_cluster.primary.master_auth.0.client_key,
    user_password = "",
    oauth_token = nonsensitive(data.google_client_config.default.access_token)
  })
  bucket = local.config_bucket
}