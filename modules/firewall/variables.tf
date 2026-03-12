variable "network_id" {
  type = string
}

variable "company" {
  type = string
}

variable "pri_subnet_cidr" {
  type = string
}

variable "gke_cluster_ipv4_cidr" {
  type = string
}

variable "use_filestore" {
  type = bool
}

variable "gke_lb_target_tag" {
  description = "Network tag applied to GKE nodes that should receive LB traffic."
  type        = string
}
