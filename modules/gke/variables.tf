variable "gke_num_nodes" {
  description = "Initial number of nodes in the GKE node pool."
  type        = number

  validation {
    condition     = var.gke_num_nodes >= 1
    error_message = "gke_num_nodes must be at least 1."
  }
}

variable "project" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Primary GCP region."
  type        = string
}

variable "env" {
  description = "Deployment environment."
  type        = string
}

variable "company" {
  description = "Company or project prefix used for naming."
  type        = string
}

variable "privatenetwork_subnet" {
  description = "Self link or identifier of the private subnet used by GKE."
  type        = string
}

variable "network_id" {
  description = "VPC network ID or self link."
  type        = string
}

variable "min_node_count" {
  description = "Minimum node count for autoscaling."
  type        = number

  validation {
    condition     = var.min_node_count >= 0
    error_message = "min_node_count must be 0 or greater."
  }
}

variable "max_node_count" {
  description = "Maximum node count for autoscaling."
  type        = number

  validation {
    condition     = var.max_node_count >= var.min_node_count
    error_message = "max_node_count must be greater than or equal to min_node_count."
  }
}

variable "gke_machine_type" {
  description = "Machine type for GKE worker nodes."
  type        = string
}

variable "vm_ip_cidr" {
  description = "CIDR allowed to reach the private control plane."
  type        = string

  validation {
    condition     = can(cidrhost(var.vm_ip_cidr, 0))
    error_message = "vm_ip_cidr must be a valid CIDR block."
  }
}

variable "zone" {
  description = "Primary GCP zone."
  type        = string
}

variable "gke_cluster_ipv4_cidr" {
  description = "CIDR for pod IP addresses."
  type        = string

  validation {
    condition     = can(cidrhost(var.gke_cluster_ipv4_cidr, 0))
    error_message = "gke_cluster_ipv4_cidr must be a valid CIDR block."
  }
}

variable "gke_master_ipv4_cidr" {
  description = "CIDR for the private GKE control plane."
  type        = string

  validation {
    condition     = can(cidrhost(var.gke_master_ipv4_cidr, 0))
    error_message = "gke_master_ipv4_cidr must be a valid CIDR block."
  }
}

variable "gke_services_ipv4_cidr" {
  description = "CIDR for service IP addresses."
  type        = string

  validation {
    condition     = can(cidrhost(var.gke_services_ipv4_cidr, 0))
    error_message = "gke_services_ipv4_cidr must be a valid CIDR block."
  }
}

variable "gke_cloudsql_sa" {
  description = "Google service account email used by Cloud SQL access workloads in GKE."
  type        = string
}

variable "authorized_networks" {
  description = "Map of CIDR => display name for GKE master authorized networks."
  type        = map(string)
}

variable "db_user_secret_name" {
  description = "Secret Manager secret name for DB username."
  type        = string
}

variable "db_password_secret_name" {
  description = "Secret Manager secret name for DB password."
  type        = string
}

variable "db_name_secret_name" {
  description = "Secret Manager secret name for DB name."
  type        = string
}

variable "gke_external_secrets_sa" {
  description = "Google service account email used by External Secrets Operator."
  type        = string
}

variable "gke_lb_target_tag" {
  description = "Network tag applied to GKE nodes that should receive LB traffic."
  type        = string
}