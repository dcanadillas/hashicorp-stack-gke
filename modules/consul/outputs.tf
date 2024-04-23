

output "acl_token" {
  value = nonsensitive(kubernetes_secret.bootstrap.data["${local.consul_token_key}"])
}
output "consul_ui" {
  value = "https://${data.kubernetes_resource.consul_ui_service.object.status.loadBalancer.ingress[0].ip}:${data.kubernetes_resource.consul_ui_service.object.spec.ports[0].port}"
}
output "consul-yaml" {
  value = var.config_bucket == "" ? "No bucket define to upload the values.yaml" : "https://storage.cloud.google.com/${google_storage_bucket_object.consul-config.0.bucket}/${google_storage_bucket_object.consul-config.0.output_name}"
}
