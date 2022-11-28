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
  env_autopilot = "autopilot"
}

resource "google_project" "project_autopilot" {
  folder_id           = google_folder.parent_folder.folder_id
  name                = "${var.prefix}-${var.demo_name}-${local.env_autopilot}"
  project_id          = "${var.prefix}-${var.demo_name}-${local.env_autopilot}-${random_integer.salt.result}"
  billing_account     = var.billing_account
  auto_create_network = true
}

data "google_project" "project_autopilot" {
  project_id = google_project.project_autopilot.project_id
}

data "google_client_config" "default_autopilot" {}

resource "google_project_service" "project_apis_autopilot" {
  project = google_project.project_autopilot.project_id
  count   = length(local.services)
  service = element(local.services, count.index)

  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_service_account" "default_autopilot" {
  project = data.google_project.project_autopilot.project_id
  account_id   = "service-account-autopilot"
  display_name = "Service Account - ${var.prefix}-${var.demo_name}-${local.env_autopilot}"
}

resource "google_container_cluster" "primary_autopilot" {
  project = data.google_project.project_autopilot.project_id
  name               = "${var.prefix}-${var.demo_name}-${local.env_autopilot}"
  location           = "europe-west6"
  enable_autopilot = true
  initial_node_count = 1
  node_config {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default_autopilot.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      cluster_type = "autopilot"
    }
  }
  master_authorized_networks_config {
    cidr_blocks {
        cidr_block   = "0.0.0.0/0"
        display_name = "all"
    }
  }
  ip_allocation_policy {
  }
  timeouts {
    create = "30m"
    update = "40m"
  }
}