data "google_container_cluster" "gke_cluster" {
  depends_on = [
    google_container_node_pool.primary_nodes,
  ]
  name = google_container_cluster.primary.name
  location = google_container_cluster.primary.location
}

output "ca_certificate" {
  value = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
}
output "cluster_endpoint" {
  value = data.google_container_cluster.gke_cluster.endpoint
  # value = data.google_container_cluster.gke_cluster.endpoint
}
output "cluster_name" {
  depends_on = [
    google_container_node_pool.primary_nodes,
  ]
  # value = google_container_cluster.primary.name
  value = data.google_container_cluster.gke_cluster.name
}
output "kubeconfig" {
  value = templatefile("${path.root}/templates/kubeconfig.yaml", {
    cluster_name = data.google_container_cluster.gke_cluster.endpoint,
    endpoint =  data.google_container_cluster.gke_cluster.endpoint,
    user_name ="admin",
    cluster_ca = data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate,
    client_cert = data.google_container_cluster.gke_cluster.master_auth.0.client_certificate,
    client_cert_key = data.google_container_cluster.gke_cluster.master_auth.0.client_key,
    user_password = data.google_container_cluster.gke_cluster.master_auth.0.password,
    oauth_token = nonsensitive(data.google_client_config.current.access_token)
  })
  sensitive = true
}
  