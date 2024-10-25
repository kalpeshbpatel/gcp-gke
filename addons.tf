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
	Chartmuseum
 *****************************************/
module "chartmuseum" {
  depends_on      = [google_container_cluster.primary]
  source          = "./addons/chartmuseum"
  count           = try(var.gkeaddons["chartmuseum"].enable, false) ? 1 : 0
  project_id      = var.project_id
  cluster_name    = var.name
  region          = var.region
  name            = coalesce(try(var.gkeaddons["chartmuseum"].name, null), "chartmuseum")
  namespace       = coalesce(try(var.gkeaddons["chartmuseum"].namespace, null), "kube-addons")
  release_version = coalesce(try(var.gkeaddons["chartmuseum"].version, null), "3.10.3")
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
  dns_project_id  = try(var.gkeaddons["external_dns"].property.dns_project_id, null)
  zone            = coalesce(try(var.gkeaddons["external_dns"].property.zone, null), "demo.live")
  domain          = coalesce(try(var.gkeaddons["external_dns"].property.domain, null), "demo.live")
}

/******************************************
	Nginx Ingress Controller
 *****************************************/
module "nginx_ingress" {
  depends_on      = [google_container_cluster.primary]
  source          = "./addons/nginx_ingress"
  count           = try(var.gkeaddons["nginx_ingress"].enable, false) ? 1 : 0
  project_id      = var.project_id
  cluster_name    = var.name
  name            = coalesce(try(var.gkeaddons["nginx_ingress"].name, null), "ingress-nginx")
  namespace       = coalesce(try(var.gkeaddons["nginx_ingress"].namespace, null), "kube-addons")
  release_version = coalesce(try(var.gkeaddons["nginx_ingress"].version, null), "4.11.3")
  replicas        = coalesce(try(var.gkeaddons["nginx_ingress"].property.replicas, null), "2")
}

/******************************************
	Kubernetes Dashboard
 *****************************************/
module "kubernetes_dashboard" {
  depends_on      = [google_container_cluster.primary, module.cert_manager, module.nginx_ingress]
  source          = "./addons/kubernetes_dashboard"
  count           = try(var.gkeaddons["kubernetes_dashboard"].enable, false) ? 1 : 0
  project_id      = var.project_id
  cluster_name    = var.name
  name            = coalesce(try(var.gkeaddons["kubernetes_dashboard"].name, null), "kubernetes-dashboard")
  namespace       = coalesce(try(var.gkeaddons["kubernetes_dashboard"].namespace, null), "kube-addons")
  release_version = coalesce(try(var.gkeaddons["kubernetes_dashboard"].version, null), "7.9.0")
  ingress         = try(var.gkeaddons["cert_manager"].enable, false) && try(var.gkeaddons["nginx_ingress"].enable, false)
  url             = coalesce(try(var.gkeaddons["kubernetes_dashboard"].property.url, null), "k8s.demo.live")
  cert_issuer     = coalesce(try(var.gkeaddons["kubernetes_dashboard"].property.cert_issuer, null), "certmanager")
}
