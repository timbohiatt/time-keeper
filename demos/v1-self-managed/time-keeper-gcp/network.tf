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
  subnets = [
    {
      name       = "${var.prefix}-${var.demo_name}-${var.env}"
      region     = var.region
      cidr_range = "10.0.0.0/22"
    },
  ]
}

resource "google_compute_network" "vpc-global" {
  name                    = "${var.prefix}-${var.demo_name}-${var.env}-global"
  project                 = google_project.project.project_id
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "subnet" {
  count                    = length(local.subnets)
  project                  = google_project.project.project_id
  network                  = google_compute_network.vpc-global.self_link
  name                     = "${local.subnets[count.index]["name"]}-${local.subnets[count.index]["region"]}"
  region                   = local.subnets[count.index]["region"]
  ip_cidr_range            = local.subnets[count.index]["cidr_range"]
  private_ip_google_access = true
}