resource "google_compute_global_network_endpoint_group" "neg" {
  project  = google_project.project.project_id
  name                  = "${var.prefix}-${var.demo_name}-${var.env}-lb-neg"
  network_endpoint_type = "INTERNET_IP_PORT"
  default_port          = 80
}