resource "google_project_iam_member" "project_user_editor_tim" {
  project = google_project.project.project_id
  role    = "roles/editor"
  member  = "user:timhiatt@google.com"
}
