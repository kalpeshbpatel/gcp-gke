# ---------- Chart Museum ---------- #

resource "random_string" "chartmuseum" {
  length      = 8
  lower       = true
  numeric     = true
  min_numeric = 2
  min_lower   = 6
  special     = false
}


resource "google_storage_bucket" "chartmuseum" {
  name                        = lower("chartmuseum-${random_string.chartmuseum.result}")
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_project_iam_custom_role" "chartmuseum_bucket_read_write" {
  role_id = "${replace(var.cluster_name, "-", "")}bucketReadWrite"
  title   = "Chartmuseum role for bucket read and write access"
  permissions = [
    "storage.objects.get",
    "storage.objects.list",
    "storage.objects.create",
    "storage.objects.update",
    "storage.objects.delete",
  ]
}

resource "google_service_account" "chartmuseum" {
  account_id   = lower("${var.cluster_name}-helm-sa")
  display_name = "Chartmuseum Service Account"
}

resource "google_storage_bucket_iam_member" "chartmuseum" {
  bucket = google_storage_bucket.chartmuseum.name
  role   = google_project_iam_custom_role.chartmuseum_bucket_read_write.name
  member = "serviceAccount:${google_service_account.chartmuseum.email}"
}

resource "google_service_account_iam_binding" "chartmuseum" {
  service_account_id = google_service_account.chartmuseum.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${var.name}]",
  ]
}

locals {
  chartmuseum_vars = {
    bucket = lower("chartmuseum-${random_string.chartmuseum.result}")
    sa     = google_service_account.chartmuseum.email
  }
  chartmuseum_values = templatefile(
    "${path.module}/helm-values.tmpl",
    local.chartmuseum_vars
  )
}

resource "helm_release" "chartmuseum" {
  depends_on       = [google_storage_bucket.chartmuseum, google_storage_bucket_iam_member.chartmuseum, google_service_account_iam_binding.chartmuseum]
  name             = var.name
  repository       = "https://chartmuseum.github.io/charts"
  chart            = "chartmuseum"
  namespace        = var.namespace
  create_namespace = true
  version          = var.release_version
  values           = [local.chartmuseum_values]
}

resource "kubernetes_deployment" "chartmuseum_ui" {
  depends_on = [helm_release.chartmuseum]
  metadata {
    name = "${var.name}-ui"
    labels = {
      "app.kubernetes.io/instance" = "${var.name}-ui"
      "app.kubernetes.io/name"     = "${var.name}-ui"
    }
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/instance" = "${var.name}-ui"
        "app.kubernetes.io/name"     = "${var.name}-ui"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/instance" = "${var.name}-ui"
          "app.kubernetes.io/name"     = "${var.name}-ui"
        }
      }
      spec {
        # service_account_name = "chartmuseum"
        container {
          image = "idobry/chartmuseumui:latest"
          name  = "${var.name}-ui"
          env {
            name  = "CHART_MUSESUM_URL"
            value = "http://chartmuseum.${var.namespace}.svc.cluster.local:8080"
          }
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "chartmuseum_ui" {
  depends_on = [helm_release.chartmuseum]
  metadata {
    name      = "${var.name}-ui"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/instance" = "${var.name}-ui"
      "app.kubernetes.io/name"     = "${var.name}-ui"
    }
    annotations = {
      "cloud.google.com/neg" = jsonencode(
        {
          ingress = true
        }
      )
    }
  }
  spec {
    selector = {
      "app.kubernetes.io/instance" = "${var.name}-ui"
      "app.kubernetes.io/name"     = "${var.name}-ui"
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
  }
}
