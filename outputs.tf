locals {
  kubeconfig = var.create_gke ? nonsensitive(module.gke[0].kubeconfig) : "No kubeconfig for existing cluster"
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
  value = module.vault.*.vault_ca
}
output "kubeconfig" {
  # value = var.config_bucket == "" ? nonsensitive(module.gke[0].kubeconfig) : "https://storage.cloud.google.com/${google_storage_bucket_object.kubeconfig[0].bucket}/${google_storage_bucket_object.kubeconfig[0].output_name}"
  value = var.config_bucket == "" ? local.kubeconfig : "https://storage.cloud.google.com/${google_storage_bucket_object.kubeconfig[0].bucket}/${google_storage_bucket_object.kubeconfig[0].output_name}"

}

