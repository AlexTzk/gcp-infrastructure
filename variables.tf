variable "project" {}
variable "region" {}
variable "env" {}
variable "company" {}
variable "network_name" {}
variable "routing_mode" {}
variable "description" {}
variable "mtu" {}
variable "zone" {}
variable "pri_subnet_cidr" {}
variable "pri_vpc_peering_address" {}
variable "gke_cluster_ipv4_cidr" {}
variable "db_version" {}
variable "db_tier" {}
variable "db_availability_type" {} # REGIONAL for HA / ZONAL for single zone
variable "db_disk_size" {}
variable "db_disk_type"{} # PD_SSD / PD_HDD
variable "db_point_recovery" {} # Required for HA
variable "db_deletion" {}
variable "db_name" {}
variable "db_user_1" {}
variable "db_password_1" {}
variable "vm_ip_nfs" {}
variable "gke_num_nodes" {}
variable "min_node_count" {}
variable "max_node_count" {}
variable "gke_machine_type" {}
variable "vm_ip_cidr" {}
variable "authorized_networks" {}
variable "gke_master_ipv4_cidr" {}
variable "gke_services_ipv4_cidr" {}

