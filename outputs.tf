output "gke_endpoints" {
  value = module.gke.cluster_endpoint
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
  value = var.config_bucket == "" ? nonsensitive(module.gke.kubeconfig) : "https://storage.cloud.google.com/${google_storage_bucket_object.kubeconfig[0].bucket}/${google_storage_bucket_object.kubeconfig[0].output_name}"
}

