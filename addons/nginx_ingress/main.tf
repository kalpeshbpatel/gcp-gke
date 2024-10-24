locals {
  nginx_ingress_vars = {
    replicaCount = var.replicas
  }

  nginx_ingress_values = templatefile(
    "${path.module}/helm-values.tmpl",
    local.nginx_ingress_vars
  )
}

resource "helm_release" "nginx_ingress" {
  name             = var.name
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = var.namespace
  create_namespace = true
  version          = var.release_version
  values           = [local.nginx_ingress_values]
}
