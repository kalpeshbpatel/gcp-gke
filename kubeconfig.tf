locals {
  kubeconfig = {
    cluster                = lower(var.name)
    endpoint               = data.google_container_cluster.gke.endpoint
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
  }

  kubeconfig_file = templatefile(
    "${path.module}/templatefile/kubeconfig_template.tmpl",
    local.kubeconfig
  )
}

resource "local_file" "kubectl_config" {
  content         = local.kubeconfig_file
  filename        = lower("${var.name}.kubeconfig")
  file_permission = 0600
}
