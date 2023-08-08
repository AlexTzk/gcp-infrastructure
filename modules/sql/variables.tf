variable "network_id" {}
variable "company" {}
variable "env" {}
variable "project" {}
variable "region" {}
variable "zone" {}
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