resource "random_integer" "np_ext_salt" {
  min = 0001
  max = 9999
}

resource "google_container_node_pool" "np-external" {
  project = var.project_id
  //name    = "${local.cluster_name}-np-ext"
  name = "np-${local.region}-ext-${random_integer.np_ext_salt.result}"
  //name_prefix = "${var.prefix}-${var.demo_name}-${var.env}-np-ext"
  location = local.region
  cluster  = google_container_cluster.gke.name

  node_config {
    image_type   = "COS_CONTAINERD"
    machine_type = "n1-standard-2"

    disk_size_gb = 100
    disk_type    = "pd-balanced"

    preemptible = false

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      private-pool = "true",
      type         = "egress"
    }

    shielded_instance_config {
      enable_secure_boot          = "true"
      enable_integrity_monitoring = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    service_account = local.service_account_egress
  }

  initial_node_count = 1

  autoscaling {
    min_node_count  = 1
    max_node_count  = 5
    location_policy = "BALANCED"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  timeouts {
    create = "30m"
    update = "40m"
    delete = "2h"
  }

}