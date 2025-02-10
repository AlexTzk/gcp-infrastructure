provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.zone}"
}

# Create a bucket called $project-tfstate for storing the Terraform states prior to everything else #
terraform {
  backend "gcs" {
    bucket  = "awesome-project-123456-tfstate"
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
    "sqladmin.googleapis.com",
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
  network_id                             =  module.network.network_id
  depends_on                             = [module.network]
}
# GCE
module "gce" {
  source                                 = "./modules/gce"
  company                                = "${var.company}"
  project 				                       = "${var.project}"
  env                                    = "${var.env}"
  region                                 = "${var.region}"
  zone                                   = "${var.zone}"
  vm_ip_nfs                              = "${var.vm_ip_nfs}"
  nfs_service_account                    =  module.iam.nfs_service_account
  network_id                             =  module.network.network_id
  privatenetwork_subnet                  =  module.network.privatenetwork_subnet
  depends_on                             = [module.network]
}
# GKE
module "gke" {
  source                                 = "./modules/gke"
  company                                = "${var.company}"
  project 				                       = "${var.project}"
  env                                    = "${var.env}"
  region                                 = "${var.region}"
  zone                                   = "${var.zone}"
  gke_num_nodes                          = "${var.gke_num_nodes}"
  min_node_count                         = "${var.min_node_count}"
  max_node_count                         = "${var.max_node_count}"
  gke_machine_type                       = "${var.gke_machine_type}"
  vm_ip_cidr                             = "${var.vm_ip_cidr}"
  gke_cluster_ipv4_cidr                  = "${var.gke_cluster_ipv4_cidr}"
  gke_master_ipv4_cidr                   = "${var.gke_master_ipv4_cidr}"
  gke_services_ipv4_cidr                 = "${var.gke_services_ipv4_cidr}"
  db_user_1                              = "${var.db_user_1}"
  db_password_1                          = "${var.db_password_1}"
  db_name 				                       = "${var.db_name}"
  authorized_networks                    = "${var.authorized_networks}"
  gke_cloudsql_sa                        =  module.iam.gke_sql_service_account
  network_id                             =  module.network.network_id
  privatenetwork_subnet                  =  module.network.privatenetwork_subnet
}
# Cloud Run 
module "cr" {
  source                                 = "./modules/cr"
  company                                = "${var.company}"
  project 				                       = "${var.project}"
  env                                    = "${var.env}"
  region                                 = "${var.region}"
} 
# Load Balancers
module "lbs" {
  source                                 = "./modules/lbs"
  company                                = "${var.company}"
  env                                    = "${var.env}"
  zone					                         = "${var.zone}"
  project                                = "${var.project}"
  region                                 = "${var.region}"
  network_id				                     = module.network.network_id
  lb_ip                                  = module.network.LB_IP
  privatenetwork_subnet                  = module.network.privatenetwork_subnet
  bs_depends_on                          = module.gke.helm_readiness
}
# Cloud IAP
module "iap" {
  source                                 = "./modules/iap"
  company                                = "${var.company}"
  env                                    = "${var.env}"
  project                                = "${var.project}"
  region                                 = "${var.region}"
  zone 				                         	 = "${var.zone}"
  privatenetwork_subnet                  = module.network.privatenetwork_subnet
}
