variable "network_id" {
  description = "VPC network ID or self link used for private service networking."
  type        = string
}

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

variable "zone" {
  description = "Primary GCP zone."
  type        = string
}

variable "db_version" {
  description = "Cloud SQL engine version."
  type        = string
}

variable "db_tier" {
  description = "Cloud SQL machine tier."
  type        = string
}

variable "db_availability_type" {
  description = "Cloud SQL availability type."
  type        = string

  validation {
    condition     = contains(["REGIONAL", "ZONAL"], var.db_availability_type)
    error_message = "db_availability_type must be REGIONAL or ZONAL."
  }
}

variable "db_disk_size" {
  description = "Cloud SQL disk size in GB."
  type        = number
}

variable "db_disk_type" {
  description = "Cloud SQL disk type."
  type        = string

  validation {
    condition     = contains(["PD_SSD", "PD_HDD"], var.db_disk_type)
    error_message = "db_disk_type must be PD_SSD or PD_HDD."
  }
}

variable "db_point_recovery" {
  description = "Enable point-in-time recovery."
  type        = bool
}

variable "db_deletion" {
  description = "Enable deletion protection."
  type        = bool
}

variable "db_name" {
  description = "Application database name."
  type        = string
}

variable "db_user_1" {
  description = "Primary application database user."
  type        = string
}