provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.zone}"
#  gcp_region  = "${var.gcp_region
#  gcp_credentials_file = "${var.gcp_credentials_file
}

# Create a bucket called $project-tfstate for storing the Terraform states prior to everything else #
/*terraform {
  backend "gcs" {
    project = "${var.project}"
    bucket  = "${var.project}-tfstate"
    prefix  = "terraform/state"
  }
}*/
 
# VPC, Shared VPC, Subnets, Router, Cloud NAT IPs, NAT GW
module "network" {
  source                                 = "./modules/vpc" 
  project 				                       = "${var.project}"
  env                                    = "${var.env}"
  company                                = "${var.company}"
  network_name                           = "${var.network_name}"
  auto_create_subnetworks                = "${var.auto_create_subnetworks}"
  routing_mode                           = "${var.routing_mode}"
  project_id                             = "${var.project}"
  description                            = "${var.description}"
  shared_vpc_host                        = "${var.shared_vpc_host}"
  delete_default_internet_gateway_routes = "${var.delete_default_internet_gateway_routes}"
  mtu                                    = "${var.mtu}"
  region                                 = "${var.region}"
  pub_subnet_cidr                        = "${var.pub_subnet_cidr}"
  pri_subnet_cidr                        = "${var.pri_subnet_cidr}"
  pri_vpc_peering_address                = "${var.pri_vpc_peering_address}"
}
# Firewall
module "firewall" {
  source                                 = "./modules/firewall"
  company                                = "${var.company}"
  network_id                             = module.network.network_id
  pub_subnet_cidr                        = "${var.pub_subnet_cidr}"
  pri_subnet_cidr                        = "${var.pri_subnet_cidr}"
  office_ip                              = "${var.office_ip}"
  failsafe_ip                            = "${var.failsafe_ip}"
  depends_on                             = [module.network]
}
# SQL
module "sql" {
  source                                 = "./modules/sql"
  company                                = "${var.company}"
  project 				                       = "${var.project}"
  env                                    = "${var.env}"
  region                                 = "${var.region}"
  zone                                   = "${var.zone}"
  db_tier                                = "${var.db_tier}"
  db_availability_type                   = "${var.db_availability_type}"
  db_version                             = "${var.db_version}"
  db_disk_size                           = "${var.db_disk_size}"
  db_disk_type                           = "${var.db_disk_type}"
  db_deletion                            = "${var.db_deletion}"
  db_point_recovery                      = "${var.db_point_recovery}"
  db_name                                = "${var.db_name}"
  db_user_1                              = "${var.db_user_1}"
  db_password_1                          = "${var.db_password_1}"
  db_user_2                              = "${var.db_user_2}"
  db_password_2                          = "${var.db_password_2}"
  network_id                             =  module.network.network_id
  depends_on                             = [module.network]
}
