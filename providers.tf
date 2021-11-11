terraform {
  required_version = ">= 0.15.0"
  # backend "remote"{}
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.67.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.1.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.5.1"
    }
  }
}

data "google_client_config" "default" {
  # depends_on = [
  #   module.gke
  # ]
}

# Defer reading the cluster data until the GKE cluster exists.
data "google_container_cluster" "primary" {
  name = var.create_gke ? module.gke[0].cluster_name : var.cluster_name
  # name = var.cluster_name
  location = var.gcp_zone
  depends_on = [module.gke]
}

provider "google" {
  project = var.gcp_project
  region = var.gcp_region
}
provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.primary.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
    )
  }
}
# provider "helm" {
#   kubernetes {
#   host = "https://35.233.64.119:443"
#   token = "ya29.a0ARrdaM-vOtjSD-ZEszzF1zxIHDbpW4WIkPI988HQeiAHFJOgGGaIv7B9A93nN8cDRwkmUdqj7way5fzvE2CsxEQMtTepzl4wYTXAu7PL7g7QPHlSaBxwxAp2bz4V8he7q5f8EIFA1tlpxAHYw1j_5-2eYnmC4wKyMruWbg"
#   cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLakNDQWhLZ0F3SUJBZ0lRQW1FTU54ZmRUTytjSW1sODFDdHg3ekFOQmdrcWhraUc5dzBCQVFzRkFEQXYKTVMwd0t3WURWUVFERXlSaFlqQTBZV0ZoWXkwNFpHTXhMVFJrT1RrdFltRXhOQzB3WkRNMU1ETTFNMlUxTURFdwpIaGNOTWpFd056STJNRGt6TURNMldoY05Nall3TnpJMU1UQXpNRE0yV2pBdk1TMHdLd1lEVlFRREV5UmhZakEwCllXRmhZeTA0WkdNeExUUmtPVGt0WW1FeE5DMHdaRE0xTURNMU0yVTFNREV3Z2dFaU1BMEdDU3FHU0liM0RRRUIKQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUUM2NW1lN1RyZVZQUm5rSzNKUkxtUkQ1ZERLZzBhcXVuWGlZYTV3TGpCVApQWWovcEN0ZjRjWVFITnduemdUQ0syenJxbHF4aEdwZHB3OEZ0ZGMybWY2TCtFSzdyYnNGc1p3cUJhd0Ztem43CmlMREFvKy84K2kra3hDWkltUFd5QmNoWUF2bm9qeE9pSThvTTFsWmRDMGhwQnhkSTJzQ3VFQlBIdjM2MmdadFAKMko1SFo3aHdCWW8xY1FCUU1xcS81WkE2TTlxNVp1UnY3YlRvQlNNbXEwbzAwQ0pOZ0hQaGtnbUZxS0tCeDM3NwpiazFaSzlBZTlzMnNNOENQSXFoWG0zbUNTY1FCWVQrSjZKSW9HRlhiK0M3TGwxQytDUVRYdkdBTWNXR0VLWmRxCldROUIvZ1c1NXI5b0VQY1lLV0p1b0lHZThoQUxHVGs1RjYvRGZKVHlxdDN6QWdNQkFBR2pRakJBTUE0R0ExVWQKRHdFQi93UUVBd0lDQkRBUEJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJRYjJFb2wwM1lsQjA0Sgppb1VhVzBBdytzSTQ5akFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBSUt0ODdnWks2WkVjWGpzVHlUTjBoSmhlClN4ZUFaZjczMWY3TE9nZmJUNFJZRFJROUx0VjRzZ2IxMElCaWpLNG16Q1JNMFZpRGdrUUdMaGtKcGwyeXl5elMKVXNrNUptTmlnWGRVWGRrR2hQVmw2Z2JZbHloLzZzWmlHSDBqeGVuQW4yN3BHcm55Q0RESEY0bHJXMWhNSnU1UQphNHJoSXl2ZTA1eC9UTEljZXdZVXpvWWRQSGE0clpiUjhCOTRJdm0zZjVQcEttN09GSWhZYVBKdXdRdEhFY0VnCmlhVEdqbUJMZEorNTh4RGNqRllLMnFvSU9qWk1zVVRjTjNWUGIyZHpXV2VTT1ZQTytadG9oajlSU2hyQ2JCeTkKM0tWVEgzbzJjNWJleCtKZW03QmlhaVJXa3pQa3oyeEVUTXl2bDJFT1hGVFF5STl5dlJIc0doUmtWTjlMZFE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==")
#   }
# }


# provider "kubernetes" {
#   # host  = "https://${data.google_container_cluster.primary.endpoint}"
#   host = "https://35.233.64.119:443"
#   token = "ya29.c.KqgBCQgoI7VXNy6Pa73-x8TrpKW51JEGTP21m9WZ55OH4PEuLNMf6vLu8blWGBhG5tzDEdsXqeMHQOxqPXsl03qTmddHrmdhf0Q79YuoKUdKby8jaHZ4_HVurf7qzxcb9ogbEvaABiT9zVl-i92-_IBSIAG-_UeWRVoDG2b65lyqKYRTGrmJkkbCM4FrTgI4I7zlaCRg7sS210Hb7ZCdtC8cSKk6tlizcWS-"
#   cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLakNDQWhLZ0F3SUJBZ0lRQW1FTU54ZmRUTytjSW1sODFDdHg3ekFOQmdrcWhraUc5dzBCQVFzRkFEQXYKTVMwd0t3WURWUVFERXlSaFlqQTBZV0ZoWXkwNFpHTXhMVFJrT1RrdFltRXhOQzB3WkRNMU1ETTFNMlUxTURFdwpIaGNOTWpFd056STJNRGt6TURNMldoY05Nall3TnpJMU1UQXpNRE0yV2pBdk1TMHdLd1lEVlFRREV5UmhZakEwCllXRmhZeTA0WkdNeExUUmtPVGt0WW1FeE5DMHdaRE0xTURNMU0yVTFNREV3Z2dFaU1BMEdDU3FHU0liM0RRRUIKQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUUM2NW1lN1RyZVZQUm5rSzNKUkxtUkQ1ZERLZzBhcXVuWGlZYTV3TGpCVApQWWovcEN0ZjRjWVFITnduemdUQ0syenJxbHF4aEdwZHB3OEZ0ZGMybWY2TCtFSzdyYnNGc1p3cUJhd0Ztem43CmlMREFvKy84K2kra3hDWkltUFd5QmNoWUF2bm9qeE9pSThvTTFsWmRDMGhwQnhkSTJzQ3VFQlBIdjM2MmdadFAKMko1SFo3aHdCWW8xY1FCUU1xcS81WkE2TTlxNVp1UnY3YlRvQlNNbXEwbzAwQ0pOZ0hQaGtnbUZxS0tCeDM3NwpiazFaSzlBZTlzMnNNOENQSXFoWG0zbUNTY1FCWVQrSjZKSW9HRlhiK0M3TGwxQytDUVRYdkdBTWNXR0VLWmRxCldROUIvZ1c1NXI5b0VQY1lLV0p1b0lHZThoQUxHVGs1RjYvRGZKVHlxdDN6QWdNQkFBR2pRakJBTUE0R0ExVWQKRHdFQi93UUVBd0lDQkRBUEJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJRYjJFb2wwM1lsQjA0Sgppb1VhVzBBdytzSTQ5akFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBSUt0ODdnWks2WkVjWGpzVHlUTjBoSmhlClN4ZUFaZjczMWY3TE9nZmJUNFJZRFJROUx0VjRzZ2IxMElCaWpLNG16Q1JNMFZpRGdrUUdMaGtKcGwyeXl5elMKVXNrNUptTmlnWGRVWGRrR2hQVmw2Z2JZbHloLzZzWmlHSDBqeGVuQW4yN3BHcm55Q0RESEY0bHJXMWhNSnU1UQphNHJoSXl2ZTA1eC9UTEljZXdZVXpvWWRQSGE0clpiUjhCOTRJdm0zZjVQcEttN09GSWhZYVBKdXdRdEhFY0VnCmlhVEdqbUJMZEorNTh4RGNqRllLMnFvSU9qWk1zVVRjTjNWUGIyZHpXV2VTT1ZQTytadG9oajlSU2hyQ2JCeTkKM0tWVEgzbzJjNWJleCtKZW03QmlhaVJXa3pQa3oyeEVUTXl2bDJFT1hGVFF5STl5dlJIc0doUmtWTjlMZFE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
#     )
# }
provider "kubernetes" {
  host  = "https://${data.google_container_cluster.primary.endpoint}"
  # host = "https://35.233.64.119:443"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}