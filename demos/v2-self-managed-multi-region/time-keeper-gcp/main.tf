
locals {
  _gke_cluster_defaults = yamldecode(file(var.gke_defaults_file))
  _gke_cluster_net = {

  }
  gke_defaults = merge(local._gke_cluster_defaults, local._gke_cluster_net)
  gke_clusters = {
    for f in fileset("${var.gke_data_dir}", "**/*.yaml") :
    trimsuffix(f, ".yaml") => yamldecode(file("${var.gke_data_dir}/${f}"))
  }
}


locals {
  services = [
    "servicenetworking.googleapis.com",
    "cloudbilling.googleapis.com",
    "iap.googleapis.com",
    //"stackdriver.googleapis.com",
    //"cloudresourcemanager.googleapis.com",
    //"storage-component.googleapis.com",
    "containerregistry.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    //"gkehub.googleapis.com",
    //"mesh.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "bigquery.googleapis.com",
  ]
}

resource "random_integer" "salt" {
  min = 0001
  max = 9999
}

resource "google_project" "project" {
  folder_id = var.folder_id
  //folder_id           = google_folder.folder.folder_id
  name                = "${var.prefix}-${var.demo_name}-${var.env}"
  project_id          = "${var.prefix}-${var.demo_name}-${var.env}-${random_integer.salt.result}"
  billing_account     = var.billing_account
  auto_create_network = false
}

resource "google_project_service" "project_apis" {
  project = google_project.project.project_id
  count   = length(local.services)
  service = element(local.services, count.index)

  disable_dependent_services = true
  disable_on_destroy         = true
}