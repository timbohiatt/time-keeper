module "gke_region" {
  source = "./modules/gke_region"
  for_each = {
    for k, v in local.gke_clusters : k => v
    if v.enabled
  }
  defaults                      = local.gke_defaults
  project_id                    = google_project.project.project_id
  prefix                        = "${var.prefix}-${var.demo_name}-${var.env}"
  cluster_name                  = try(each.value.cluster_name, null)
  region                        = try(each.value.region, null)
  vpc_network_self_link         = google_compute_network.vpc-global.self_link
  subnet_config                 = try(each.value.subnet_config, null)
  private_cluster_config        = try(each.value.private_cluster_config, null)
  service_account               = try(each.value.service_account, google_service_account.gke_service_account.email)
  logging_service               = try(each.value.logging_service, null)
  monitoring_service            = try(each.value.monitoring_service, null)
  enable_cost_management_config = try(each.value.enable_cost_management_config, null)
  min_master_version            = try(each.value.min_master_version, null)

  //depends_on = [google_compute_firewall.egress-allow-gke-node, google_compute_firewall.ingress-allow-gke-node]
}