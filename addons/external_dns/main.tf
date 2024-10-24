resource "google_project_iam_custom_role" "externaldns_role" {
  project     = var.dns_project_id != null ? var.dns_project_id : var.project_id
  role_id     = "${replace(var.cluster_name, "-", "")}externaldnsRole"
  title       = "${var.cluster_name} ExternalDNS Manager Role"
  description = "Custom role to manage DNS zones and records for ExternalDNS"
  permissions = [
    "dns.changes.create",
    "dns.changes.get",
    "dns.changes.list",
    "dns.managedZones.get",
    "dns.managedZones.list",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update"
  ]
  stage = "GA"
}

resource "google_service_account" "externaldns" {
  project      = var.dns_project_id != null ? var.dns_project_id : var.project_id
  account_id   = lower("${var.cluster_name}-dns-sa")
  display_name = "ExternalDNS Service Account"
}

resource "google_project_iam_binding" "externaldns" {
  project = var.dns_project_id != null ? var.dns_project_id : var.project_id
  role    = google_project_iam_custom_role.externaldns_role.name
  members = ["serviceAccount:${google_service_account.externaldns.email}"]
}

resource "google_service_account_iam_binding" "externaldns" {
  service_account_id = google_service_account.externaldns.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${var.name}]",
  ]
}


locals {
  vars = {
    namespace = var.namespace
    log_level = "debug",
    policy    = "upsert-only",

    project = var.dns_project_id != null ? var.dns_project_id : var.project_id
    zone    = var.zone
    domain  = var.domain
    sa      = google_service_account.externaldns.email
  }

  values = templatefile(
    "${path.module}/helm-values.tmpl",
    local.vars
  )
}

resource "helm_release" "external_dns" {
  depends_on       = [google_service_account_iam_binding.externaldns, google_project_iam_binding.externaldns]
  name             = var.name
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "external-dns"
  namespace        = var.namespace
  create_namespace = true
  version          = var.release_version
  values           = [local.values]
}
