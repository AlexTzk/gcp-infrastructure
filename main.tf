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
}
# SQL
module "sql" {
  source                                 = "./modules/sql"
  company                                = "${var.company}"
  
}