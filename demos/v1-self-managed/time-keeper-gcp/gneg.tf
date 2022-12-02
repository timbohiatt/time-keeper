


resource "google_compute_global_network_endpoint_group" "gneg" {
  project  = google_project.project.project_id
  name                  = "${var.prefix}-${var.demo_name}-${var.env}-lb-gneg"
  network_endpoint_type = "INTERNET_IP_PORT"
  default_port          = 80
}