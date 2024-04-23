locals {
  kubeconfig = templatefile("${path.root}/templates/kubeconfig.yaml", {
    cluster_name = var.create_gke ? module.gke[0].cluster_endpoint : data.google_container_cluster.primary[0].endpoint,
    endpoint =  var.create_gke ? module.gke[0].cluster_endpoint : data.google_container_cluster.primary[0].endpoint,
    user_name ="admin",
    cluster_ca = base64encode(local.ca_cert),
    client_cert = "",
    client_cert_key = "",
    # client_cert = data.google_container_cluster.primary.master_auth.0.client_certificate,
    # client_cert_key = data.google_container_cluster.primary.master_auth[0].client_key,
    user_password = "",
    oauth_token = nonsensitive(data.google_client_config.default.access_token)
  })
}

output "gke_endpoints" {
  # value = module.gke.cluster_endpoint
  value = var.create_gke ? module.gke[0].cluster_endpoint : data.google_container_cluster.primary[0].endpoint
}
output "consul_token" {
  value = module.consul.*.acl_token
}
output "consul_ui" {
  value = module.consul[0].consul_ui
}
output "vault-yaml" {
  value = module.vault != [] ? module.vault.*.vault-yaml[0] : null
}
output "consul-yaml" {
  value = module.consul != []  ? module.consul.*.consul-yaml[0] : null
}
output "vault_ca" {
  value = module.vault[*].vault_ca
  # sensitive = true
}
output "kubeconfig" {
  # value = var.config_bucket == "" ? nonsensitive(module.gke[0].kubeconfig) : "https://storage.cloud.google.com/${google_storage_bucket_object.kubeconfig[0].bucket}/${google_storage_bucket_object.kubeconfig[0].output_name}"
  value = var.config_bucket == "" ? local.kubeconfig : "https://storage.cloud.google.com/${google_storage_bucket_object.kubeconfig[0].bucket}/${google_storage_bucket_object.kubeconfig[0].output_name}"
}

# output "gcp_token" {
#   value = data.google_service_account_access_token.default.access_token
#   sensitive = true
# }

output "client_token" {
  value = data.google_client_config.default.access_token
  sensitive = true
}