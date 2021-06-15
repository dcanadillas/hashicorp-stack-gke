# Variables for GCP
variable "gcp_region" {
  description = "Cloud region"
}
variable "gcp_project" {
  description = "Cloud GCP project"
}
variable "node_type" {
  description = "Machine type for nodes"
  default = "n1-standard-2"
}
variable "gcp_zone" {
  description = "availability zones"
}
variable "cluster_name" {
  description = "Name of your cluster  "
}
variable "default_gke" {
  description = "Set it to true if you want to speed up GKE cluster creation by creating a default NodePool"
  default = false
}
variable "default_network" {
  description = "Set it to true if we want to use the default network in GCP where creating GKE clusters"
  default = false
}
variable "regional_k8s" {
  description = "Set this to true if you want regional cluster with a master per zone"
  default = false
}
variable "config_bucket" {
  description = "Cloud bucket to save config generated files"
  type = string
  default = null
}
variable "gcp_service_account" {
  description = "GCP service account to use for Vault auto-unseal KMS"
}

# Variable for Consul
variable "consul_enterprise" {
  description = "Usin Enterprise version if true"
  default = false
}
variable "consul_version" {
  description = "Consul version"
  default = "1.9.5"
}
variable "consul_dc" {
  description = "Datacenter name for Consul servers"
  default = "dc1"
}
variable "consul_license" {
  description = "License for Consul Enterprise"
  default = null
}
variable "consul_namespace" {
  description = "Name of namespace to deploy Consul"
}
# variable "envoy_version" {
#   description = "Envoy proxy version. Check supported matrix: https://www.consul.io/docs/connect/proxies/envoy#supported-versions"
#   default = "v1.14-latest"
# }
variable "chart_version" {
  description = "Consul Helm Chart version: https://www.consul.io/docs/k8s/upgrade/compatibility#supported-consul-versions"
  default = "0.31.1"
}
variable "nodes" {
  description = "Number of nodes/pods of the cluster"
}
variable "owner" {
  description = "Owner name to tag clusters"
}
variable "enable_consul" {
  description = "True if deploying Vault"
  default = true
}

# Variables for Vault
variable "enable_vault" {
  description = "True if deploying Vault"
  default = true
}
variable "vault_version" {
  description = "Version of Vault to be deployed"
  default = "1.7.0_ent"
}
variable "vault_ca" {
  description = "CA certificate for Vault"
  default = ""
}
variable "vault_cert" {
  description = "Issued cert for Vault"
  default = ""
}
variable "vault_key" {
  description = "Vault cert key"
  default = ""
}
variable "key_ring" {
  description = "GCP Key ring to use"
}
variable "crypto_key" {
  description = "GCP Key ring to use"
}

# Variables for Waypoint
variable "enable_waypoint" {
  description = "True if deploying Waypoint"
  default = true
}

variable "waypoint_version" {
  description = "Version of Waypoint to deploy"
  default = "latest"
}

variable "waypoint_namespace" {
  description = "Namespace for Waypoint deployment"
  default = "waypoint"
}