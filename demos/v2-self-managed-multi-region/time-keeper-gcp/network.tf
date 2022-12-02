resource "google_compute_network" "vpc-global" {
  name                    = "${var.prefix}-${var.demo_name}-${var.env}-global"
  project                 = google_project.project.project_id
  auto_create_subnetworks = false
}