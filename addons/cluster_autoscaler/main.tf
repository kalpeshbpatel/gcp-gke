resource "google_service_account" "cluster_autoscaler" {
  project      = var.project_id
  account_id   = lower("${var.cluster_name}-as-sa")
  display_name = "Cluster Autoscaler Service Account"
}

resource "google_project_iam_binding" "cluster_autoscaler" {
  project = var.project_id
  role    = "roles/compute.admin"
  members = ["serviceAccount:${google_service_account.cluster_autoscaler.email}"]
}

resource "google_service_account_iam_binding" "cluster_autoscaler" {
  service_account_id = google_service_account.cluster_autoscaler.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${var.name}]",
  ]
}

locals {
  vars = {
    name        = var.name
    clusterName = lower(var.cluster_name)
    sa          = google_service_account.cluster_autoscaler.email
  }
  values = templatefile(
    "${path.module}/cluster-autoscaler.tmpl",
    local.vars
  )
}

resource "helm_release" "cluster_autoscaler" {
  depends_on       = [google_service_account_iam_binding.cluster_autoscaler, google_project_iam_binding.cluster_autoscaler]
  name             = var.name
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = var.namespace
  create_namespace = true
  version          = var.release_version
  values           = [local.values]
}
