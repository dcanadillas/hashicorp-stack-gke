

output "acl_token" {
  value = nonsensitive(kubernetes_secret.bootstrap.data)
}
output "consul_ui" {
  value = ""
}
output "consul-yaml" {
  value = var.config_bucket == "" ? "No bucket define to upload the values.yaml" : "https://storage.cloud.google.com/${google_storage_bucket_object.consul-config.0.bucket}/${google_storage_bucket_object.consul-config.0.output_name}"
}