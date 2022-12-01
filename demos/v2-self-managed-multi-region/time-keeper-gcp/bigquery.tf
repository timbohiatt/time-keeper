resource "google_bigquery_dataset" "billing_dataset" {
  project = google_project.project.project_id
  dataset_id                  = "raw_billing_data"
  friendly_name               = "All Billing Data"
  description                 = "This Dataset is used for Detailed Cost Analysis"
  location                    = "EU"
  default_table_expiration_ms = 3600000

  labels = {
    env = "${var.prefix}-${var.env}"
  }

  access {
    role          = "OWNER"
    user_by_email = google_service_account.billing_data_admin.email
  }

  access {
    role   = "OWNER"
    domain = "google.com"
  }
}