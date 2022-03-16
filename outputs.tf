locals {
  kubeconfig = templatefile("${path.root}/templates/kubeconfig.yaml", {
    cluster_name = data.google_container_cluster.primary.endpoint,
    endpoint =  data.google_container_cluster.primary.endpoint,
    user_name ="admin",
    cluster_ca = data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate,
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
  value = data.google_container_cluster.primary.endpoint
}
output "consul_token" {
  value = module.consul.*.acl_token
}
output "consul_ui" {
  value = ""
}
output "vault-yaml" {
  value = module.vault.*.vault-yaml
}
output "consul-yaml" {
  value = module.consul.*.consul-yaml
}
output "vault_ca" {
  value = module.vault[*].vault_ca
  # sensitive = true
}
output "kubeconfig" {
  # value = var.config_bucket == "" ? nonsensitive(module.gke[0].kubeconfig) : "https://storage.cloud.google.com/${google_storage_bucket_object.kubeconfig[0].bucket}/${google_storage_bucket_object.kubeconfig[0].output_name}"
  value = var.config_bucket == "" ? local.kubeconfig : "https://storage.cloud.google.com/${google_storage_bucket_object.kubeconfig[0].bucket}/${google_storage_bucket_object.kubeconfig[0].output_name}"
}

