resource "google_service_account" "gke_service_account" {
  project      = google_project.project.project_id
  account_id   = "${var.prefix}-${var.env}-gke"
  display_name = "${var.prefix}-${var.demo_name}-${var.env}-gke"
}

resource "google_service_account" "gke_egress_service_account" {
  project      = google_project.project.project_id
  account_id   = "${var.prefix}-${var.env}-gke-egress"
  display_name = "${var.prefix}-${var.demo_name}-${var.env}-gke-egress"
}

resource "google_service_account" "gke_worker_service_account" {
  project      = google_project.project.project_id
  account_id   = "${var.prefix}-${var.env}-gke-worker"
  display_name = "${var.prefix}-${var.demo_name}-${var.env}-gke-worker"
}
