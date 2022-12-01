
// Create the firewall rules to allow nodes to communicate with the control plane
resource "google_compute_firewall" "egress-allow-gke-node" {
  project = google_project.project.project_id
  network = google_compute_network.vpc-global.self_link

  //name = "${var.prefix}-${var.demo_name}-${var.env}-gke-node-allow-egress-${random_id.postfix.hex}"
  //name = "${local.cluster_name}-egress"
  name = "${local.cluster_name}-egress${random_integer.np_ext_salt.result}"

  priority  = "200"
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443", "9443", "10250", "15017", "6443"]
  }

  destination_ranges = [local.pcc_master_ipv4_cidr_block]
  target_service_accounts = [
    local.service_account_internal,
    local.service_account_egress,
    local.service_account
  ]
}

resource "google_compute_firewall" "ingress-allow-gke-node" {
  project = google_project.project.project_id
  network = google_compute_network.vpc-global.self_link

  //name = "${var.prefix}-${var.demo_name}-${var.env}-gke-node-allow-ingress-${random_id.postfix.hex}"
  name = "${local.cluster_name}-ingress${random_integer.np_ext_salt.result}"

  priority  = "200"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443", "9443", "10250", "15017", "6443"]
  }

  source_ranges = [local.pcc_master_ipv4_cidr_block]
  source_service_accounts = [
    local.service_account_internal,
    local.service_account_egress
  ]
}