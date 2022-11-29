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
  env_gke = "gke"
}

resource "google_project" "project_gke" {
  folder_id           = google_folder.parent_folder.folder_id
  name                = "${var.prefix}-${var.demo_name}-${local.env_gke}"
  project_id          = "${var.prefix}-${var.demo_name}-${local.env_gke}-${random_integer.salt.result}"
  billing_account     = var.billing_account
  auto_create_network = true
}

data "google_project" "project_gke" {
  project_id = google_project.project_gke.project_id
}

data "google_client_config" "default_gke" {}

resource "google_project_service" "project_apis_gke" {
  project = google_project.project_gke.project_id
  count   = length(local.services)
  service = element(local.services, count.index)

  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_service_account" "default_gke" {
  project = data.google_project.project_gke.project_id
  account_id   = "service-account-gke"
  display_name = "Service Account - ${var.prefix}-${var.demo_name}-${local.env_gke}"
}

resource "google_container_cluster" "primary_gke" {
  project = data.google_project.project_gke.project_id
  name               = "${var.prefix}-${var.demo_name}-${local.env_gke}"
  location           = var.region
  enable_autopilot = false
  initial_node_count = 1
  node_config {
    machine_type = "e2-standard-4"
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default_gke.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      cluster_type = "gke"
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

# module "kubectl-yaml-gke-jwt" {
#    source = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"
#    project_id              = data.google_project.project_gke.project_id
#    cluster_name            = google_container_cluster.primary_gke.name
#    cluster_location        = var.region
#    module_depends_on       = [google_container_cluster.primary_gke]
#    kubectl_create_command  = "kubectl apply -f ./bank-of-anthos/extras/jwt/jwt-secret.yaml"
#    kubectl_destroy_command = "kubectl delete -f ./bank-of-anthos/extras/jwt/jwt-secret.yaml"
#    skip_download           = false
# }

# module "kubectl-yaml-gke-boa" {
#    source = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"
#    project_id              = data.google_project.project_gke.project_id
#    cluster_name            = google_container_cluster.primary_gke.name
#    cluster_location        = var.region
#    module_depends_on       = [module.kubectl-yaml-gke-jwt]
#    kubectl_create_command  = "kubectl apply -f ./bank-of-anthos/kubernetes-manifests"
#    kubectl_destroy_command = "kubectl delete -f ./bank-of-anthos/kubernetes-manifests"
#    skip_download           = false
# }

resource "google_container_registry" "registry_gke" {
  project = data.google_project.project_gke.project_id
  location = "EU"
}

resource "google_storage_bucket_iam_member" "gke_viewer" {
  bucket = google_container_registry.registry_gke.id
  role = "roles/storage.objectViewer"
  member = google_service_account.default_gke.member
}


resource "google_monitoring_dashboard" "dashboard_gke" {
  project = data.google_project.project_gke.project_id
  dashboard_json = <<EOF
{
  "displayName": "Bank of Anthos Dashboard - GKE",
  "gridLayout": {
    "columns": "2",
    "widgets": [
      {
        "title": "Kubernetes Container - CPU usage time",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"kubernetes.io/container/cpu/core_usage_time\" resource.type=\"k8s_container\" resource.label.\"namespace_name\"=\"default\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_RATE",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "groupByFields": [
                      "resource.label.\"container_name\""
                    ]
                  },
                  "secondaryAggregation": {}
                },
                "unitOverride": "s"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Memory usage",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"custom.googleapis.com/jvm/memory/used\" resource.type=\"k8s_container\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "groupByFields": [
                      "resource.label.\"container_name\""
                    ]
                  },
                  "secondaryAggregation": {}
                },
                "unitOverride": "1"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Cache hits",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"custom.googleapis.com/cache/gets\" resource.type=\"k8s_container\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "groupByFields": [
                      "resource.label.\"container_name\""
                    ]
                  },
                  "secondaryAggregation": {}
                },
                "unitOverride": "1"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Cache misses",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"custom.googleapis.com/cache/load\" resource.type=\"k8s_container\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "groupByFields": [
                      "resource.label.\"container_name\""
                    ]
                  },
                  "secondaryAggregation": {}
                },
                "unitOverride": "1"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Available CPU Count",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"custom.googleapis.com/system/cpu/count\" resource.type=\"k8s_container\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "groupByFields": [
                      "resource.label.\"container_name\""
                    ]
                  },
                  "secondaryAggregation": {}
                },
                "unitOverride": "1"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Log entry count per container",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"logging.googleapis.com/log_entry_count\" resource.type=\"k8s_container\" resource.label.\"namespace_name\"=\"default\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_RATE",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [
                      "metric.label.\"severity\"",
                      "resource.label.\"container_name\""
                    ]
                  },
                  "secondaryAggregation": {},
                  "pickTimeSeriesFilter": {
                    "rankingMethod": "METHOD_MEAN",
                    "numTimeSeries": 3,
                    "direction": "TOP"
                  }
                },
                "unitOverride": "1"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Total latency per response code [Frontend load balancer]",
        "xyChart": {
          "chartOptions": {
            "mode": "COLOR"
          },
          "dataSets": [
            {
              "minAlignmentPeriod": "60s",
              "plotType": "LINE",
              "targetAxis": "Y1",
              "timeSeriesQuery": {
                "apiSource": "DEFAULT_CLOUD",
                "timeSeriesFilter": {
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_NONE",
                    "perSeriesAligner": "ALIGN_PERCENTILE_99"
                  },
                  "filter": "metric.type=\"loadbalancing.googleapis.com/https/total_latencies\" resource.type=\"https_lb_rule\" resource.label.\"backend_name\"=monitoring.regex.full_match(\"^.*default-frontend.*$\")",
                  "pickTimeSeriesFilter": {
                    "direction": "TOP",
                    "numTimeSeries": 3,
                    "rankingMethod": "METHOD_MEAN"
                  },
                  "secondaryAggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_STDDEV",
                    "groupByFields": [
                      "metric.label.\"response_code_class\""
                    ],
                    "perSeriesAligner": "ALIGN_MEAN"
                  }
                }
              }
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      },
      {
        "title": "Request size per response code [Frontend load balancer]",
        "xyChart": {
          "chartOptions": {
            "mode": "COLOR"
          },
          "dataSets": [
            {
              "minAlignmentPeriod": "60s",
              "plotType": "LINE",
              "targetAxis": "Y1",
              "timeSeriesQuery": {
                "apiSource": "DEFAULT_CLOUD",
                "timeSeriesFilter": {
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_NONE",
                    "perSeriesAligner": "ALIGN_RATE"
                  },
                  "filter": "metric.type=\"loadbalancing.googleapis.com/https/request_bytes_count\" resource.type=\"https_lb_rule\" resource.label.\"backend_name\"=monitoring.regex.full_match(\"^.*default-frontend.*$\")",
                  "secondaryAggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [
                      "metric.label.\"response_code_class\""
                    ],
                    "perSeriesAligner": "ALIGN_INTERPOLATE"
                  }
                }
              }
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      },
      {
        "title": "Request count per response code [Frontend load balancer]",
        "xyChart": {
          "chartOptions": {
            "mode": "COLOR"
          },
          "dataSets": [
            {
              "minAlignmentPeriod": "60s",
              "plotType": "LINE",
              "targetAxis": "Y1",
              "timeSeriesQuery": {
                "apiSource": "DEFAULT_CLOUD",
                "timeSeriesFilter": {
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_NONE",
                    "perSeriesAligner": "ALIGN_RATE"
                  },
                  "filter": "metric.type=\"loadbalancing.googleapis.com/https/request_count\" resource.type=\"https_lb_rule\" resource.label.\"backend_name\"=monitoring.regex.full_match(\"^.*default-frontend.*$\")",
                  "secondaryAggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [
                      "metric.label.\"response_code_class\""
                    ],
                    "perSeriesAligner": "ALIGN_MEAN"
                  }
                }
              }
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      },
      {
        "title": "Request source to response latency",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"istio.io/service/server/response_latencies\" resource.type=\"k8s_container\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_SUM",
                    "crossSeriesReducer": "REDUCE_PERCENTILE_99",
                    "groupByFields": [
                      "metric.label.\"source_workload_name\""
                    ]
                  },
                  "secondaryAggregation": {},
                  "pickTimeSeriesFilter": {
                    "rankingMethod": "METHOD_MEAN",
                    "numTimeSeries": 3,
                    "direction": "TOP"
                  }
                },
                "unitOverride": "ms"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Request size",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"istio.io/service/server/request_bytes\" resource.type=\"k8s_container\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_SUM",
                    "crossSeriesReducer": "REDUCE_PERCENTILE_99",
                    "groupByFields": [
                      "metric.label.\"source_workload_name\""
                    ]
                  },
                  "secondaryAggregation": {}
                },
                "unitOverride": "By"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Entity Creation count",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"custom.googleapis.com/hibernate/entities/inserts\" resource.type=\"k8s_container\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "groupByFields": [
                      "resource.label.\"container_name\""
                    ]
                  },
                  "secondaryAggregation": {}
                },
                "unitOverride": "1"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Slowest query time",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"custom.googleapis.com/hibernate/query/executions/max\" resource.type=\"k8s_container\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "groupByFields": [
                      "resource.label.\"container_name\""
                    ]
                  },
                  "secondaryAggregation": {}
                },
                "unitOverride": "1"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Database query count",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"custom.googleapis.com/hibernate/query/executions\" resource.type=\"k8s_container\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "groupByFields": [
                      "resource.label.\"container_name\""
                    ]
                  },
                  "secondaryAggregation": {}
                },
                "unitOverride": "1"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Uptime",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"custom.googleapis.com/process/uptime\" resource.type=\"k8s_container\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_STDDEV",
                    "groupByFields": [
                      "resource.label.\"container_name\""
                    ]
                  },
                  "secondaryAggregation": {}
                },
                "unitOverride": "1"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      }
    ]
  }
}

EOF
}