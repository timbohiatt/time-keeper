terraform {
  backend "gcs" {
    bucket = "tk-state-management-2048"
    prefix = "terraform/state/environments/v2"
  }
}