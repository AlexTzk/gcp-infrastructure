variable "gke_num_nodes" {}
variable "project" {}
variable "region" {}
variable "env" {}
variable "company" {}
variable "privatenetwork_subnet" {}
variable "network_id" {}
variable "min_node_count" {}
variable "max_node_count" {}
variable "gke_machine_type" {}
variable "vm_ip_cidr" {}
variable "zone" {}
variable "gke_cluster_ipv4_cidr" {}
variable "gke_master_ipv4_cidr" {}
variable "gke_services_ipv4_cidr" {}
variable "gke_cloudsql_sa" {}
variable "authorized_networks" {}
variable "db_user_1" {
  type      = string
  sensitive = true
}

variable "db_password_1" {
  type      = string
  sensitive = true
}
variable "db_name" {
  type      = string
  sensitive = true  
}
