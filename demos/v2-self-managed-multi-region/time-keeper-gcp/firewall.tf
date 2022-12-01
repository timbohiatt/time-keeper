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

// TODO - Handle this Rule and Ensure it's enabled successfully after..
// Create a deny-all catch all firewall rule.
/*resource "google_compute_firewall" "egress-deny-all" {
  project = google_project.project.project_id
  network = google_compute_network.vpc-global.self_link

  name = "${var.prefix}-${var.demo_name}-${var.env}-gke-node-deny-egress"
  //name = "${var.prefix}-${var.demo_name}-${var.env}-gke-node-deny-egress-${random_id.postfix.hex}"

  priority  = "65535"
  direction = "EGRESS"

  deny {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
}*/

// TODO - Add Description
resource "google_compute_firewall" "egress-allow-ext-gw" {
  project = google_project.project.project_id
  network = google_compute_network.vpc-global.self_link

  //name = "${var.prefix}-${var.demo_name}-${var.env}-gke-node-allow-ext-egress-${random_id.postfix.hex}"
  name = "${var.prefix}-${var.demo_name}-${var.env}-gke-node-allow-ext-egress"

  priority  = "1000"
  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]

  target_service_accounts = [google_service_account.gke_egress_service_account.email]
}


// Create the firewall rules to allow health checks
resource "google_compute_firewall" "ingress-allow-gke-hc" {
  project = google_project.project.project_id
  network = google_compute_network.vpc-global.self_link

  //name = "${var.prefix}-${var.demo_name}-${var.env}-gke-node-allow-ingress-hc-${random_id.postfix.hex}"
  name = "${var.prefix}-${var.demo_name}-${var.env}-gke-node-allow-ingress-hc"

  priority  = "100"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
}