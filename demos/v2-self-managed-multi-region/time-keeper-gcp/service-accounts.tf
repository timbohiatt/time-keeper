resource "google_service_account" "billing_data_admin" {
  project      = google_project.project.project_id
  account_id   = "${var.prefix}-${var.env}-billing-data"
  display_name = "${var.prefix}-${var.demo_name}-${var.env}-billing-admin"
}

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


resource "google_project_iam_member" "gke_service_account_iam_editor" {
  project = google_project.project.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

resource "google_project_iam_member" "gke_service_account_iam_cluster_admin" {
  project = google_project.project.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}