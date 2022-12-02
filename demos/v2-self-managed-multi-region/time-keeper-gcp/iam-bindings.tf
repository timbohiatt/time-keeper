locals {
  GKEServiceAccountIAMRoles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
  ]
  GitLabServiceAccountIAMRoles = [
    "roles/owner",
    "roles/editor",
    "roles/container.developer",
  ]
}

resource "google_project_iam_member" "gke_service_account" {
  count   = length(local.GKEServiceAccountIAMRoles)
  project = google_project.project.project_id
  role    = element(local.GKEServiceAccountIAMRoles, count.index)
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

resource "google_project_iam_member" "gke_service_account_worker" {
  count   = length(local.GKEServiceAccountIAMRoles)
  project = google_project.project.project_id
  role    = element(local.GKEServiceAccountIAMRoles, count.index)
  member  = "serviceAccount:${google_service_account.gke_worker_service_account.email}"
}

resource "google_project_iam_member" "gke_service_account_external" {
  count   = length(local.GKEServiceAccountIAMRoles)
  project = google_project.project.project_id
  role    = element(local.GKEServiceAccountIAMRoles, count.index)
  member  = "serviceAccount:${google_service_account.gke_egress_service_account.email}"
}

resource "google_project_iam_member" "gitlab_service_account" {
  count   = length(local.GitLabServiceAccountIAMRoles)
  project = google_project.project.project_id
  role    = element(local.GitLabServiceAccountIAMRoles, count.index)
  member  = "serviceAccount:${var.GitLabServiceAccountEmail}"
}