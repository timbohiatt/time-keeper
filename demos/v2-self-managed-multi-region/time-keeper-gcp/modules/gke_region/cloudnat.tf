resource "random_integer" "nat_salt" {
  min = 0001
  max = 9999
}

resource "google_compute_address" "nat_gw_address" {
  project = var.project_id
  name    = "${var.prefix}-gke-nat-ext-addr-${var.region}-${random_integer.nat_salt.result}"
  region  = var.region
}

resource "google_compute_router" "nat_router" {
  name    = "${var.prefix}-nat-rtr-${random_integer.nat_salt.result}"
  project = var.project_id
  region  = var.region
  network = var.vpc_network_self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_gateway" {
  project = var.project_id
  name    = "${var.prefix}-nat-gw-${var.region}-${random_integer.nat_salt.result}"

  router = google_compute_router.nat_router.name
  region = google_compute_router.nat_router.region

  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_gw_address.self_link]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  //source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  subnetwork {
    name                    = google_compute_subnetwork.subnet.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    filter = "TRANSLATIONS_ONLY"
    enable = true
  }

  depends_on = [google_compute_subnetwork.subnet]
}