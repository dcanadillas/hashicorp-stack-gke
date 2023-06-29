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
variable "create_gke" {
  description = "Set it to true if you want to create the GKE cluster or false if using an existing cluster."
  default = true
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

variable "k8s_version" {
  description = "K8s version to deploy in the format 1.xx"
  default = "1.24"
}


# Variable for Consul
variable "consul_enterprise" {
  description = "Usin Enterprise version if true"
  default = false
}
variable "consul_version" {
  description = "Consul version. The Consul Compatibility Matrix should be checked."
  default = "1.15.3"
  validation {
    # Check that the version is > 1.14.0
    condition = replace(var.consul_version,".","") >= 1140
    error_message = "Consul Version needs to be 1.14.0 or newer. Please, check the Compatibility Matrix: https://www.consul.io/docs/k8s/upgrade/compatibility#supported-consul-versions"
  }
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
  default = "1.1.2"
  validation {
    # Check that the version is > 1.14.0
    condition = replace(var.chart_version,".","") >= 100
    error_message = "Consul Helm chart version needs to be 1.0.0. or newer. Please, check the Compatibility Matrix: https://www.consul.io/docs/k8s/upgrade/compatibility#supported-consul-versions"
  }
}
variable "nodes" {
  description = "Number of nodes/pods of the cluster"
}
variable "owner" {
  description = "Owner name to tag clusters"
}
variable "enable_consul" {
  description = "True if deploying Consul"
  default = true
}

# Variables for Vault
variable "enable_vault" {
  description = "True if deploying Vault"
  default = true
}
variable "vault_version" {
  description = "Version of Vault to be deployed"
  default = "1.12.0"
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
variable "vault_license" {
  description = "License for Vault Enterprise"
  default = null
}
variable "key_ring" {
  description = "GCP Key ring to use"
}
variable "crypto_key" {
  description = "GCP Key ring to use"
}
variable "vault_tls" {
  description = "TLS enabled or disabled for Vault"
  default = "disabled"
}
variable "own_certs" {
  description = "Set to \"true\" if providing own certificates in variables"
  default = false
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

# Variables for TLS generation
# variable "ca_org" {
#   description = "Org CA"
# }

# variable "common_name" {
#   description = "Common name to use with Certs"
# }

# variable "ca_common_name" {
#   description = "Common name to use with Certs"
# }

variable "domains" {
  description = "Domains to include in the certs"
}
variable "tls_algorithm" {
  description = "Domains to include in the certs"
  default = "RSA"
}
variable "gke_secure_boot" {
  description = "To enable GKE secure boot by default"
  default = false
}
variable "gke_private_nodes" {
  description = "Set this to true to enable Private GKE cluster nodes"
  default = false
}
variable "create_kms" {
  description = "Set this to false if the \"kms_keyring\" already exist and want to use it for the crypto_key."
  default = true
}