variable "company" {
  type = string
}

variable "env" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "network_id" {
  type = string
}

variable "privatenetwork_subnet" {
  type = string
}

variable "nfs_internal_ip" {
  type = string
}

variable "nfs_machine_type" {
  type = string
}

variable "nfs_data_disk_size_gb" {
  type = number
}

variable "nfs_data_disk_type" {
  type = string
}

variable "gke_cluster_ipv4_cidr" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "backup_schedule_region" {
  type = string
}