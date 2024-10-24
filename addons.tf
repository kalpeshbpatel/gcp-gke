/******************************************
	Cluster Auto Scaler
 *****************************************/
module "cluster_autoscaler" {
  depends_on      = [google_container_cluster.primary]
  source          = "./addons/cluster_autoscaler"
  count           = try(var.gkeaddons["cluster_autoscaler"].enable, false) ? 1 : 0
  project_id      = var.project_id
  cluster_name    = var.name
  name            = coalesce(try(var.gkeaddons["cluster_autoscaler"].name, null), "clusterautoscaler")
  namespace       = coalesce(try(var.gkeaddons["cluster_autoscaler"].namespace, null), "kube-addons")
  release_version = coalesce(try(var.gkeaddons["cluster_autoscaler"].version, null), "9.43.0")
}

/******************************************
	Cert Manager
 *****************************************/
module "cert_manager" {
  depends_on      = [google_container_cluster.primary]
  source          = "./addons/cert_manager"
  count           = try(var.gkeaddons["cert_manager"].enable, false) ? 1 : 0
  project_id      = var.project_id
  cluster_name    = var.name
  name            = coalesce(try(var.gkeaddons["cert_manager"].name, null), "cert-manager")
  namespace       = coalesce(try(var.gkeaddons["cert_manager"].namespace, null), "kube-addons")
  release_version = coalesce(try(var.gkeaddons["cert_manager"].version, null), "1.16.1")
}

/******************************************
	Cert Manager
 *****************************************/
module "external_dns" {
  depends_on      = [google_container_cluster.primary]
  source          = "./addons/external_dns"
  count           = try(var.gkeaddons["external_dns"].enable, false) ? 1 : 0
  project_id      = var.project_id
  cluster_name    = var.name
  name            = coalesce(try(var.gkeaddons["external_dns"].name, null), "external-dns")
  namespace       = coalesce(try(var.gkeaddons["external_dns"].namespace, null), "kube-addons")
  release_version = coalesce(try(var.gkeaddons["external_dns"].version, null), "8.3.9")
}
