locals {
  vaultvalues = templatefile("${path.root}/templates/vault_values.yaml",{
    vault_nodes = var.nodes
    vault_repo = var.vault_repo,
    vault_version = var.vault_version,
    hosts = local.hostnames,
    gcp_project = var.gcp_project,
    gcp_region = var.gcp_region,
    key_ring = var.key_ring
    crypto_key = google_kms_crypto_key.crypto_key.name,
    kms_creds = kubernetes_secret.google-application-credentials.metadata[0].name,
    http = var.tls == "enabled" ? "https" : "http",
    tls = var.tls,
    license_secret = var.vault_license == null ? "" : kubernetes_secret.vault-license[0].metadata[0].name,
    log_level = var.log_level
    })

  hostnames = [ for i in range(0,var.nodes) : "vault-${i}"]
}

resource "random_id" "gcs_vault" {
  byte_length = 4
  prefix = "vault-"
}

data "google_service_account" "owner_project" {
  account_id = var.gcp_service_account
}
# The Helm provider creates the namespace, but if we want to create it manually would be with following lines
resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.vault_namespace
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}

# Let's create a secret with the json credentials to use KMS autounseal
resource "google_service_account_key" "gcp_sa_key" {
  # service_account_id = var.gcp_service_account
  service_account_id = data.google_service_account.owner_project.account_id
}
resource "kubernetes_secret" "google-application-credentials" {
  metadata {
    name = "kms-creds"
    namespace = kubernetes_namespace.vault.metadata.0.name
  }
  data = {
    "credentials.json" = base64decode(google_service_account_key.gcp_sa_key.private_key)
  }
}
resource "kubernetes_secret" "certs" {
  metadata {
    name = "vault-server-tls"
    namespace = kubernetes_namespace.vault.metadata.0.name
  }
  data = {
    "vault.crt" = var.vault_cert
    "vault_ca.crt" = var.vault_ca
    "vault.key" = var.vault_key
  }
}

resource "kubernetes_secret" "vault-license" {
  count = var.vault_license == null ? 0 : 1
  metadata {
    name = "vault-license"
    namespace = kubernetes_namespace.vault.metadata.0.name
  }
  data = {
    "license" = var.vault_license
  }
}


# Because we are executing remotely using TFC/TFE we want to save our templates in a Cloud bucket
resource "google_storage_bucket_object" "vault-config" {
  count = var.config_bucket != "" ? 1 : 0
  name   = "${var.cluster_name}-${random_id.gcs_vault.dec}.yml"
  content = local.vaultvalues
  bucket = var.config_bucket
}

resource "helm_release" "vault" {
  depends_on = [
      kubernetes_secret.google-application-credentials,
  ]
  name = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart  = "vault"
  create_namespace = false
  namespace = kubernetes_namespace.vault.metadata.0.name
  force_update = false

  values = [
      local.vaultvalues
  ]
}

## I you want to create the template files locally uncomment the following lines (This is not working with remote execution in TFE)
# resource "local_file" "foo" {
#     content     = templatefile("${path.root}/templates/vault_values.yaml",{
#           hostname = var.hostname,
#           vault_version = var.vault_version
#           })
#     filename = "${path.root}/templates/vault.yaml"
# }
