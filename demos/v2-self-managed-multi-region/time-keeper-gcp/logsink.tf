resource "google_logging_billing_account_sink" "billing-sink" {
  name        = "billing-data-sync-${google_project.project.project_id}"
  description = "Exporting Billing Account Data"
  billing_account = "${var.billing_account}"

  # Can export to pubsub, cloud storage, or bigquery
  destination = "bigquery.googleapis.com/${google_bigquery_dataset.billing_dataset.id}"
}

resource "google_project_iam_binding" "log-writer" {
  project = google_project.project.project_id
  role = "roles/bigquery.dataEditor"

  members = [
    google_logging_billing_account_sink.billing-sink.writer_identity,
  ]
}