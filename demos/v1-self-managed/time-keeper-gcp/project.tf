/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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

/*resource "google_folder" "folder" {
  parent       = var.folder_id
  display_name = "${var.prefix}-${var.demo_name}-${var.env}"
}*/

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