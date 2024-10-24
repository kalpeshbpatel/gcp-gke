/******************************************
	Cluster Auto Scaler
 *****************************************/
module "cluster_autoscaler" {
  depends_on      = [google_container_cluster.primary]
  source          = "./addons/cluster_autoscaler"
  count           = try(var.gkeaddons["cluster_autoscaler"].enable, false) ? 1 : 0
  project_id      = var.project_id
  cluster_name    = var.name
  name            = var.gkeaddons.cluster_autoscaler.name
  namespace       = var.gkeaddons.cluster_autoscaler.namespace
  release_version = var.gkeaddons.cluster_autoscaler.version
}
