output "vault-yaml" {
  value = var.config_bucket == "" ? "No bucket define to upload the values.yaml" : "https://storage.cloud.google.com/${google_storage_bucket_object.vault-config.0.bucket}/${google_storage_bucket_object.vault-config.0.output_name}"
}
output "vault_ca" {
  value = nonsensitive(kubernetes_secret.certs.data)
}