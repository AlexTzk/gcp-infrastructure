provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.zone}"
}

# Create a bucket called $project-tfstate for storing the Terraform states prior to everything else #
terraform {
  backend "gcs" {
    bucket  = "YOUR_PROJECT-tfstate"
    prefix  = "terraform/state"
  }
}

# Enable required APIs
module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.5"

  project_id                  = var.project
  disable_services_on_destroy = false
  disable_dependent_services  = false
  activate_apis = flatten([
    "autoscaling.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "gkehub.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "iap.googleapis.com",
    "run.googleapis.com",
    "sql-component.googleapis.com",
    "storage.googleapis.com"
  ])
}

# VPC, Subnets, Router, Cloud NAT IPs, NAT GW
module "network" {
  source                                 = "./modules/vpc" 
  project 				                       = "${var.project}"
  env                                    = "${var.env}"
  company                                = "${var.company}"
  network_name                           = "${var.network_name}"
  routing_mode                           = "${var.routing_mode}"
  project_id                             = "${var.project}"
  description                            = "${var.description}"
  mtu                                    = "${var.mtu}"
  region                                 = "${var.region}"
  pri_subnet_cidr                        = "${var.pri_subnet_cidr}"
  pri_vpc_peering_address                = "${var.pri_vpc_peering_address}"
}
# Firewall
module "firewall" {
  source                                 = "./modules/firewall"
  company                                = "${var.company}"
  network_id                             = module.network.network_id
  pri_subnet_cidr                        = "${var.pri_subnet_cidr}"
  gke_cluster_ipv4_cidr                  = "${var.gke_cluster_ipv4_cidr}"
  depends_on                             = [module.network]
}
# IAM
module "iam"{
  source                                 = "./modules/iam"
  company                                = "${var.company}"
  env                                    = "${var.env}"
  project                                = "${var.project}"
  region                                 = "${var.region}"
}

