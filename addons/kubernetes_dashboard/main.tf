locals {
  kubernetes_dashboard_vars = {
    # replicaCount = var.replicas
  }

  kubernetes_dashboard_values = templatefile(
    "${path.module}/helm-values.tmpl",
    local.kubernetes_dashboard_vars
  )
}

resource "helm_release" "kubernetes_dashboard" {
  name             = var.name
  repository       = "https://kubernetes.github.io/dashboard"
  chart            = "kubernetes-dashboard"
  namespace        = var.namespace
  create_namespace = true
  version          = var.release_version
  values           = [local.kubernetes_dashboard_values]
}

locals {
  dashboard_user_vars = {
    namespace = var.namespace
  }
  cert_manager_issuer_vars = {
    email                 = "admin@dashboard.com"
    dashboard_cert_issuer = var.cert_issuer
    ingress_class         = "nginx"
    namespace             = var.namespace
  }
}

data "kubectl_file_documents" "dashboard_user" {
  content = templatefile(
    "${path.module}/dashboard-user.tmpl",
  local.dashboard_user_vars)
}

locals {
  yaml_dashboard_user = split("---", data.kubectl_file_documents.dashboard_user.content)
}

resource "kubectl_manifest" "dashboard_user" {
  depends_on = [helm_release.kubernetes_dashboard]
  count      = length(local.yaml_dashboard_user)
  yaml_body  = local.yaml_dashboard_user[count.index]
}

resource "kubectl_manifest" "cert_manager_issuer" {
  count = var.ingress ? 1 : 0
  yaml_body = templatefile(
    "${path.module}/cert-manager-issuer.tmpl",
    local.cert_manager_issuer_vars
  )
}

resource "kubernetes_ingress_v1" "kubernetes-dashboard" {
  count = var.ingress ? 1 : 0
  metadata {
    name      = "dashboard"
    namespace = var.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = true
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
      "cert-manager.io/issuer"                         = var.cert_issuer
      "cert-manager.io/renew-before"                   = "48h"
      "cert-manager.io/private-key-rotation-policy"    = "Always"
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["${var.url}"]
      secret_name = var.url
    }
    rule {
      host = var.url
      http {
        path {
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "kubernetes-dashboard-kong-proxy"
              port {
                number = 8443
              }
            }
          }
        }
      }
    }
  }
}
