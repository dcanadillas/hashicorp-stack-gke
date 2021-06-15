module "gke" {
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
}

module "consul" {
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
    config_bucket = var.config_bucket
    consul_enterprise = var.consul_enterprise
    consul_version=var.consul_version
    chart_version = var.chart_version
    
}

module "vault" {
    count = var.enable_vault ? 1 : 0
    source = "./modules/vault"
    gcp_project = var.gcp_project
    gcp_region = var.gcp_region
    location = var.gcp_zone
    nodes = var.nodes
    vault_namespace = "vault"
    vault_version = var.vault_version
    cluster_endpoint = data.google_container_cluster.primary.endpoint
    cluster_name = var.cluster_name
    ca_certificate = module.gke.ca_certificate
    config_bucket = var.config_bucket
    gcp_service_account = var.gcp_service_account
    key_ring = var.key_ring
    vault_cert = var.vault_cert
    vault_ca = var.vault_ca
    vault_key = var.vault_key
    crypto_key = var.crypto_key
    tls = "disabled"
}

module "waypoint" {
    count = var.enable_waypoint ? 1 : 0
    source = "./modules/waypoint"
    waypoint_namespace = var.waypoint_namespace
    waypoint_version = var.waypoint_version
}


resource "google_storage_bucket_object" "kubeconfig" {
  count = var.config_bucket != "" ? 1 : 0
  name   = "${var.cluster_name}-kubeconfig-${formatdate("YYMMDD_HHmm",timestamp())}.yml"
  content = nonsensitive(module.gke.kubeconfig)
  bucket = var.config_bucket
}