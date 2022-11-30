variable "project_id" {
  description = "Project id."
  type        = string
}

variable "prefix" {
  description = "GCP Resource Prefix"
  type        = string
}

variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
}

variable "region" {
  description = "GCP Region for Cluster"
  type        = string
}

variable "logging_service" {
  description = "GKE Logging Service"
  type        = string
}

variable "monitoring_service" {
  description = "GKE Monitoring Service"
  type        = string
}

variable "min_master_version" {
  description = "GKE Master Node Minimum Cluster Version"
  type        = string
}

variable "enable_cost_management_config" {
  description = "Enable GKE Cost Management Service"
  type        = bool
}

variable "vpc_network_self_link" {
  description = "GCP Network Self Link"
  type        = string
}

variable "subnet_config" {
  description = "GKE Subnet Configuration values."
  type = object({
    cidr_range            = optional(string)
    private_google_access = optional(bool)
  })
}

variable "private_cluster_config" {
  description = "GKE Private Master Config."
  type = object({
    enable_private_endpoint = optional(bool)
    enable_private_nodes    = optional(bool)
    master_ipv4_cidr_block  = optional(string)
  })
}

variable "defaults" {
  description = "GKE Cluster factory default values."
  type = object({
    enabled            = bool
    region             = string
    min_master_version = optional(string)
    subnet_config = object({
      cidr_range            = optional(string)
      private_google_access = optional(bool)
    })
    private_cluster_config = object({
      enable_private_endpoint = optional(bool)
      enable_private_nodes    = optional(bool)
      master_ipv4_cidr_block  = optional(string)
    })
    logging_service               = optional(string)
    monitoring_service            = optional(string)
    enable_cost_management_config = optional(bool)
  })
  default = null
}

variable "service_account" {
  description = "GCP Service Account Email for GKE"
  type        = string
}

variable "service_account_egress" {
  description = "GCP Service Account Email for GKE Egress Node Pool"
  type        = string
  default     = null
}

variable "service_account_internal" {
  description = "GCP Service Account Email for GKE Internal Node Pool"
  type        = string
  default     = null
}


