
/*resource "kubernetes_cluster_role_binding" "cluster-admin-role" {

  metadata {
    name = "jump-vm"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
 subject {
    kind      = "ServiceAccount"
    name      = "${google_service_account.jump-vm.email}"
    api_group = "rbac.authorization.k8s.io"
  }
}*/


resource "google_compute_firewall" "jump-ssh-allow" {
  project = google_project.project.project_id
  network = google_compute_network.vpc-global.self_link
  direction="INGRESS"

  allow {
    protocol = "tcp"
  }

  source_ranges=["35.235.240.0/20"]
  name = "${var.prefix}-${var.demo_name}-${var.env}-iap"
  priority  = "1000"
}



resource "google_service_account" "jump-vm" {
  project = google_project.project.project_id
  account_id   = "${var.prefix}-${var.env}-jump-vm"
  display_name = "Service Account jump-vm"
}

resource "google_project_iam_policy" "project" {
  project = google_project.project.project_id
  policy_data = data.google_iam_policy.admin.policy_data
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/container.admin"

    members = [
      "serviceAccount:${google_service_account.jump-vm.email}",
    ]
  }
}

resource "google_compute_instance" "jump-vm" {
  project = google_project.project.project_id
  name         = "jump-vm"
  machine_type = "e2-medium"
  zone         = "europe-west6-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    //network = google_compute_network.vpc-global.self_link
    subnetwork =google_compute_subnetwork.subnet[0].self_link

    //access_config {
      // Ephemeral public IP
    //}
  }

  metadata_startup_script = "sudo apt-get install git kubectl google-cloud-sdk-gke-gcloud-auth-plugin -y"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.jump-vm.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_project_metadata" "enable-oslogin" {
  project = google_project.project.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
}