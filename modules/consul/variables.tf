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

variable "config_bucket" {
  description = "Cloud bucket to save config generated files"
  type = string
  default = null
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
