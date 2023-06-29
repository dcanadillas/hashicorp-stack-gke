# data "google_client_config" "default" {
# }

# # # Defer reading the cluster data until the GKE cluster exists.
# data "google_container_cluster" "primary" {
#   name = var.cluster_name
#   location = var.gcp_zone
# }

# provider "google" {
#   project = var.gcp_project
#   region = var.gcp_region
# }
# provider "helm" {
#   kubernetes {
#     host  = "https://${data.google_container_cluster.primary.endpoint}"
#     token = data.google_client_config.default.access_token
#     cluster_ca_certificate = base64decode(
#       data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
#     )
#   }
# }
# provider "kubernetes" {
#   host  = "https://${data.google_container_cluster.primary.endpoint}"
#   token = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(
#     data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
#   )
# }