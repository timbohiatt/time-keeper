
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
    "containerregistry.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "servicenetworking.googleapis.com",
  ]
}

resource "random_integer" "salt" {
  min = 0001
  max = 9999
}

resource "google_project" "project" {
  folder_id           = var.folder_id
  name                = "${var.prefix}-${var.demo_name}"
  project_id          = "${var.prefix}-${var.demo_name}-${random_integer.salt.result}"
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


module "gke-gitlab" {
  source                     = "./terraform-google-gke-gitlab"
  project_id                 = google_project.project.project_id
  certmanager_email          = "no-reply@${google_project.project.project_id}.example.com"
  gitlab_deletion_protection = false
  gitlab_db_random_prefix    = true
  helm_chart_version         = "6.6.0"
  runner_service_account_name="default"
}