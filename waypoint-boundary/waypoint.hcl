project = "boundary"

app "boundary-k8s" {
  path = "./k8s"

  build {
    use "docker-pull" {
      image = "hashicorp/boundary"
      tag = "0.2.3"
    }
    registry {
      use "docker" {
        image = "hashicorp/boundary"
        tag   = "0.2.3"
        local = true
      }
    }
  }

  deploy {
    hook {
      when = "before"
      command = ["kubectl", "apply", "-f", "${path.app}/namespace.yaml"]
    }
    use "kubernetes-apply" {
      path = templatedir("${path.app}/",{
        namespace="boundary"
      })
      prune_label = "project=boundary"
    }
  }
}