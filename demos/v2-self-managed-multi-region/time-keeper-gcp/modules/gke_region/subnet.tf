resource "google_compute_subnetwork" "subnet" {
  project                  = var.project_id
  network                  = var.vpc_network_self_link
  name                     = "${var.prefix}-gke-${var.region}"
  region                   = var.region
  ip_cidr_range            = local.subnet_cidr_range
  private_ip_google_access = local.subnet_private_google_access
}