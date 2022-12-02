terraform {
  backend "gcs" {
    bucket = "tk-state-management-2048"
    prefix = "demo/cost-compate/terraform/state/environments"
  }
}