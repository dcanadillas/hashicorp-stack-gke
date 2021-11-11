locals {
  waypointvalues = templatefile("${path.root}/templates/waypoint.yaml",{
    waypoint_version = var.waypoint_version,
    })
}


resource "kubernetes_namespace" "waypoint" {
  metadata {
    name = var.waypoint_namespace
    
  }
}

resource "helm_release" "waypoint" {
  name = "waypoint"
  repository = "https://helm.releases.hashicorp.com"
  chart  = "waypoint"
  create_namespace = false
  namespace = kubernetes_namespace.waypoint.metadata.0.name
  force_update = false

  values = [
      local.waypointvalues
  ]
}


# THE FOLLOWING IS TO INSTALL WITHOUT HELM (before version 0.6.0)
# resource "kubernetes_service" "waypoint" {
#   metadata {
#     name = "waypoint"
#     namespace = kubernetes_namespace.waypoint.metadata.0.name
#     labels = {
#       app = "waypoint-server"
#     }
#   }
#   spec {
#     selector = {
#       app = "waypoint-server"
#     }

#     port {
#       name = "https"
#       port = 9702
#       target_port = 9702
#     }
#     port {
#       name = "grpc"
#       port = 9701
#       target_port = 9701
#     }

#     type = "LoadBalancer"
#   }
# }

# resource "kubernetes_stateful_set" "waypoint" {
#   metadata {
#     labels = {
#       app = kubernetes_service.waypoint.metadata.0.labels.app
#     }

#     name = "waypoint-server"
#     namespace = kubernetes_namespace.waypoint.metadata.0.name
#   }

#   spec {
#     replicas = 1

#     selector {
#       match_labels = {
#         app = kubernetes_service.waypoint.metadata.0.labels.app
#       }
#     }

#     service_name = kubernetes_service.waypoint.metadata.0.name

#     template {
#       metadata {
#         labels = {
#           app = kubernetes_service.waypoint.metadata.0.labels.app
#         }

#         annotations = {}
#       }

#       spec {

#         container {
#           name = "server"
#           image = "hashicorp/waypoint:${var.waypoint_version}"
#           image_pull_policy = "Always"

#           env {
#             name = "HOME"
#             value = "/data"
#           }

#           args = [
#             "server",
#             "run",
#             "-accept-tos",
#             "-vvv",
#             "-db=/data/data.db",
#             "-listen-grpc=0.0.0.0:9701",
#             "-listen-http=0.0.0.0:9702"
#           ]

#           volume_mount {
#             name       = "data"
#             mount_path = "/data"
#           }

#           liveness_probe {
#             http_get {
#               path   = "/"
#               port   = "http"
#               scheme = "HTTPS"
#             }

#             initial_delay_seconds = 30
#             timeout_seconds       = 1
#           }

#           resources {
#             requests = {
#               cpu    = "100m"
#               memory = "256Mi"
#             }
#           }
#           termination_message_path = "/dev/termination-log"
#           termination_message_policy = "File"
#         }
#         dns_policy = "ClusterFirst"
#         image_pull_secrets {
#           name = "github"
#         }
#         restart_policy = "Always"
#         security_context {
#           # run_as_user = 0
#           fs_group = 1000
#         }

#         termination_grace_period_seconds = 300
        
#       }
#     }

#     update_strategy {
#       type = "RollingUpdate"

#       rolling_update {
#         partition = 0
#       }
#     }

#     volume_claim_template {
#       metadata {
#         name = "data"
#       }

#       spec {
#         access_modes       = ["ReadWriteOnce"]
#         storage_class_name = "standard"

#         resources {
#           requests = {
#             storage = "1Gi"
#           }
#         }
#       }
#     }
#   }
# }