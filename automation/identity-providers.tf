locals {
  serviceAccountIAMRoles = [
    //"roles/resourcemanager.organizationAdmin",
    "roles/iam.workloadIdentityUser",
    //"roles/resourcemanager.projectCreator",
    //"roles/resourcemanager.projectIamAdmin",
    //"roles/container.clusterAdmin",
    //"roles/compute.admin",
  ]
  federated_identity_providers = {
    gitlab = {
      attribute_condition = "attribute.namespace_path==\"tk\""
      issuer              = "gitlab"
      custom_settings = {
        issuer_uri        = "${module.gke-gitlab.gitlab_url}/"
        allowed_audiences = ["${module.gke-gitlab.gitlab_url}"]
      }
    }
  }
  identity_providers = {
    for k, v in local.federated_identity_providers : k => merge(
      v,
      lookup(local.identity_providers_defs, v.issuer, {})
    )
  }
  identity_providers_defs = {
    # https://docs.gitlab.com/ee/ci/cloud_services/index.html#how-it-works
    gitlab = {
      attribute_mapping = {
        "google.subject"                  = "assertion.sub"
        "attribute.sub"                   = "assertion.sub"
        "attribute.environment"           = "assertion.environment"
        "attribute.environment_protected" = "assertion.environment_protected"
        "attribute.namespace_id"          = "assertion.namespace_id"
        "attribute.namespace_path"        = "assertion.namespace_path"
        "attribute.pipeline_id"           = "assertion.pipeline_id"
        "attribute.pipeline_source"       = "assertion.pipeline_source"
        "attribute.project_id"            = "assertion.project_id"
        "attribute.project_path"          = "assertion.project_path"
        "attribute.repository"            = "assertion.project_path"
        "attribute.ref"                   = "assertion.ref"
        "attribute.ref_protected"         = "assertion.ref_protected"
        "attribute.ref_type"              = "assertion.ref_type"
      }
      allowed_audiences = ["https://gitlab.com"]
      issuer_uri        = "https://gitlab.com"
      principal_tpl     = "principalSet://iam.googleapis.com/%s/attribute.sub/project_path:%s:ref_type:branch:ref:%s"
      principalset_tpl  = "principalSet://iam.googleapis.com/%s/attribute.repository/%s"
    }
  }
}


resource "google_iam_workload_identity_pool" "gitlab-pool" {
  provider                  = google-beta
  count                     = length(local.identity_providers) > 0 ? 1 : 0
  project                   = google_project.project.project_id
  workload_identity_pool_id = "${var.prefix}-${var.demo_name}"
}

resource "google_iam_workload_identity_pool_provider" "gitlab-provider-jwt" {
  provider = google-beta
  for_each = local.identity_providers
  project  = google_project.project.project_id
  workload_identity_pool_id = (
    google_iam_workload_identity_pool.gitlab-pool.0.workload_identity_pool_id
  )
  workload_identity_pool_provider_id = "${var.prefix}-${var.demo_name}-${each.key}"
  attribute_condition                = each.value.attribute_condition
  attribute_mapping                  = each.value.attribute_mapping
  oidc {
    allowed_audiences = (
      try(each.value.custom_settings.allowed_audiences, null) != null
      ? each.value.custom_settings.allowed_audiences
      : try(each.value.allowed_audiences, null)
    )
    issuer_uri = (
      try(each.value.custom_settings.issuer_uri, null) != null
      ? each.value.custom_settings.issuer_uri
      : try(each.value.issuer_uri, null)
    )
  }
}

resource "google_service_account" "gitlab-runner" {
  project      = google_project.project.project_id
  account_id   = "gitlab-runner-service-account"
  display_name = "Service Account for GitLab Runner"
}

resource "google_service_account_iam_member" "gitlab-runner-iam-bindings" {
  count              = length(local.serviceAccountIAMRoles)
  service_account_id = google_service_account.gitlab-runner.name
  role               = element(local.serviceAccountIAMRoles, count.index)
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gitlab-pool[0].name}/attribute.project_id/${google_project.project.project_id}"
}

output "GCP_WORKLOAD_IDENTITY_PROVIDER" {
  value = google_iam_workload_identity_pool_provider.gitlab-provider-jwt["gitlab"].name
}

output "GCP_SERVICE_ACCOUNT" {
  value = google_service_account.gitlab-runner.email
}