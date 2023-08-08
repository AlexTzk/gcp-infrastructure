variable "project" {}
variable "region" {}
variable "env" {}
variable "company" {}
variable "network_name" {}
variable "auto_create_subnetworks" {}
variable "routing_mode" {}
variable "description" {}
variable "shared_vpc_host" {}
variable "delete_default_internet_gateway_routes" {}
variable "mtu" {}
variable "gcp_credentials_file" {}
variable "zone" {}
variable "pub_subnet_cidr" {}
variable "pri_subnet_cidr" {}
variable "pri_vpc_peering_address" {}
variable "office_ip" {}
variable "failsafe_ip" {}
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
variable "db_user_2" {}
variable "db_password_2" {}


