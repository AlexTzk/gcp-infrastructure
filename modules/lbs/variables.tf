variable "company" {
  description = "Company or project prefix."
  type        = string
}

variable "env" {
  description = "Deployment environment."
  type        = string
}

variable "project" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Primary GCP region."
  type        = string
}

variable "lb_ip" {
  description = "Reserved public IP for the load balancer."
  type        = string
}

variable "zone" {
  description = "Primary GCP zone."
  type        = string
}

variable "network_id" {
  description = "VPC network ID or self link."
  type        = string
}

variable "privatenetwork_subnet" {
  description = "Private subnet used by load-balanced backends."
  type        = string
}

variable "bs_depends_on" {
  description = "Placeholder dependency for backend readiness."
  type        = any
}

variable "lb_certificate_domains" {
  description = "Domains attached to the Google-managed certificate."
  type        = list(string)

  validation {
    condition     = length(var.lb_certificate_domains) > 0
    error_message = "lb_certificate_domains must contain at least one domain."
  }
}

variable "gke_hosts" {
  description = "Hostnames routed to the GKE backend."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.gke_hosts) > 0
    error_message = "gke_hosts must contain at least one hostname."
  }
}

variable "cloudrun_hosts" {
  description = "Hostnames routed to the Cloud Run backend."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.cloudrun_hosts) > 0
    error_message = "cloudrun_hosts must contain at least one hostname."
  }
}