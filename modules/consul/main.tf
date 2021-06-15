locals {
  consul_token_key = "bootstraptoken"
  consul_token = uuid()
  consulvalues = templatefile("${path.root}/templates/consul.yaml",{
      # version = "1.8.4",
      image = var.consul_enterprise ? "hashicorp/consul-enterprise:${var.consul_version}" : "consul:${var.consul_version}",
      # envoy = "envoyproxy/envoy-alpine:${var.envoy_version}"
      datacenter = var.consul_dc
      enterprise = var.consul_enterprise
      license = var.consul_license
      nodes = var.nodes
      secret = kubernetes_secret.bootstrap.metadata.0.name
      key = local.consul_token_key
      token = local.consul_token
  })
}


# Because we are executing remotely using TFC/TFE we want to save our templates in a Cloud bucket
resource "google_storage_bucket_object" "consul-config" {
  count = var.config_bucket != "" ? 1 : 0
  name   = "${var.cluster_name}-consul-${formatdate("YYMMDD_HHmm",timestamp())}.yml"
  content = local.consulvalues
  bucket = var.config_bucket
}

# The Helm provider creates the namespace, but if we want to create it manually would be with following lines
resource "kubernetes_namespace" "consul" {
  metadata {
    name = var.consul_namespace
  }
}

resource "kubernetes_secret" "bootstrap" {
  metadata {
    name = "bootstraptoken"
    namespace = kubernetes_namespace.consul.metadata.0.name
  }

  data = {
    "${local.consul_token_key}" = local.consul_token
  }
}

resource "kubernetes_secret" "consul-license" {
  count = var.consul_license == null ? 0 : 1
  metadata {
    name = "consul-ent-license"
    namespace = kubernetes_namespace.consul.metadata.0.name
  }
  data = {
    "key" = var.consul_license
  }
}


resource "helm_release" "consul" {
  depends_on = [
      # kubernetes_secret.google-application-credentials,
      kubernetes_namespace.consul
  ]
  name = "consul"
  # Depending on deprecation of data.helm_repository
  # repository = "${data.helm_repository.vault.metadata[0].name}"
  repository = "https://helm.releases.hashicorp.com"
  chart  = "consul"
  create_namespace = false
  namespace = kubernetes_namespace.consul.metadata.0.name
  force_update = false
  version = var.chart_version

  values = [ local.consulvalues ]

  wait = false
}