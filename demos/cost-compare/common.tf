locals {
  services = [
    "servicenetworking.googleapis.com",
    "cloudbilling.googleapis.com",
    "iap.googleapis.com",
    "containerregistry.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "monitoring.googleapis.com",
    "anthos.googleapis.com",
    "gkehub.googleapis.com",
    "gkeconnect.googleapis.com",
    "anthosconfigmanagement.googleapis.com",
    "mesh.googleapis.com",
    "meshconfig.googleapis.com",
    "meshtelemetry.googleapis.com",
    "run.googleapis.com",
  ]
}

resource "random_integer" "salt" {
  min = 0001
  max = 9999
}