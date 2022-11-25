// Create the GKE Cluster
resource "google_container_cluster" "gke" {
  provider = google-beta

  project  = google_project.project.project_id
  name     = "${var.prefix}-${var.demo_name}-${var.env}" 
  location = var.region

  network    = google_compute_network.vpc-global.self_link
  subnetwork = google_compute_subnetwork.subnet.0.self_link

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  min_master_version = "1.24.5"

  remove_default_node_pool = true
  initial_node_count       = 1
  enable_shielded_nodes    = true
  enable_legacy_abac       = false

  resource_labels = {
    //mesh_id = "proj-${google_project.project.number}",
  }

  master_auth {
    // Disable login auth to the cluster
    //username = ""
    //password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  node_config {
    labels = {
      private-pool = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = "true"
      enable_integrity_monitoring = "true"
    }

    preemptible = false

    service_account = google_service_account.gke_service_account.email
  }

  workload_identity_config {
    workload_pool = "${google_project.project.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  master_authorized_networks_config {
  }

  ip_allocation_policy {
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  //resource_labels = var.cluster_labels

  lifecycle {
    ignore_changes = [master_auth]
  }

  timeouts {
    create = "30m"
    update = "40m"
    delete = "2h"
  }

  depends_on = [google_compute_firewall.egress-allow-gke-node, google_compute_firewall.ingress-allow-gke-node]
}

// TODO - Gary - What's the purpose of the internal and external node pool? I think I am missing something.
resource "google_container_node_pool" "np-external" {
  project     = google_project.project.project_id
  name = "${var.prefix}-${var.demo_name}-${var.env}-np-ext"
  //name_prefix = "${var.prefix}-${var.demo_name}-${var.env}-np-ext"
  location    = var.region
  cluster     = google_container_cluster.gke.name

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

    service_account = google_service_account.gke_egress_service_account.email
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

  lifecycle {
    create_before_destroy = true
  }

}

// Workload nodepool
resource "google_container_node_pool" "np-internal" {
  project     = google_project.project.project_id
  name = "${var.prefix}-${var.demo_name}-${var.env}-np-wpl-1"
  //name_prefix = "${var.prefix}-${var.demo_name}-${var.env}-np-wpl-1"
  location    = var.region
  cluster     = google_container_cluster.gke.name

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
      private-pool = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = "true"
      enable_integrity_monitoring = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    service_account = google_service_account.gke_worker_service_account.email
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

  lifecycle {
    create_before_destroy = true
  }

}