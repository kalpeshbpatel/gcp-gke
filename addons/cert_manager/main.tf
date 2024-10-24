locals {
  vars = {
    installCRDs = true
  }

  values = templatefile(
    "${path.module}/cert-manager.tmpl",
    local.vars
  )
}

resource "helm_release" "cert_manager" {
  name             = var.name
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = var.namespace
  create_namespace = true
  version          = var.release_version
  values           = [local.values]
}
