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
  env_okd = "okd"
}

resource "google_project" "project_okd" {
  folder_id           = google_folder.parent_folder.folder_id
  name                = "${var.prefix}-${var.demo_name}-${local.env_okd}"
  project_id          = "${var.prefix}-${var.demo_name}-${local.env_okd}-${random_integer.salt.result}"
  billing_account     = var.billing_account
  auto_create_network = true
}

data "google_project" "project_okd" {
  project_id = google_project.project_okd.project_id
}

data "google_client_config" "default_okd" {}

resource "google_project_service" "project_apis_okd" {
  project = google_project.project_okd.project_id
  count   = length(local.services)
  service = element(local.services, count.index)

  disable_dependent_services = true
  disable_on_destroy         = true
}