resource "google_compute_address" "nat_gw_address" {
  project = google_project.project.project_id
  name    = "${var.prefix}-${var.demo_name}-${var.env}-nat-ext-addr-${var.region}-1"
  region  = var.region
}

resource "google_compute_router" "nat_router" {
  name    = "${var.prefix}-${var.demo_name}-${var.env}-nat-rtr-1"
  project = google_project.project.project_id
  region  = var.region
  network = google_compute_network.vpc-global.self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_gateway" {
  project = google_project.project.project_id
  name    = "${var.prefix}-${var.demo_name}-${var.env}-nat-gw-${var.region}-1"

  router = google_compute_router.nat_router.name
  region = google_compute_router.nat_router.region

  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_gw_address.self_link]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"


  subnetwork {
    name                    = google_compute_subnetwork.subnet.0.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    filter = "TRANSLATIONS_ONLY"
    enable = true
  }
}