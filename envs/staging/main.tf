provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

# Create a bucket called $project-tfstate for storing the Terraform states prior to everything else #
terraform {
    required_version = ">= 1.5.0"
    required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  backend "gcs" {
    bucket  = "awesome-project-123456-tfstate"
    prefix = "envs/staging/terraform/state"
  }
}

# Enable required APIs
module "project-services" {
  source = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.5"

  project_id                  = var.project
  disable_services_on_destroy = false
  disable_dependent_services  = false
  activate_apis = flatten([
    "autoscaling.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "file.googleapis.com",
    "gkehub.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "iap.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
    "sts.googleapis.com"
  ])
}

# Check for DB availability
check "db_point_recovery_required_for_regional_sql" {
  assert {
    condition = (
      var.db_availability_type != "REGIONAL" ||
      var.db_point_recovery == true
    )
    error_message = "db_point_recovery must be true when db_availability_type is REGIONAL."
  }
}

# Artifact Registry
module "artifact_registry" {
  source        = "../../modules/artifact-registry"
  project       = var.project
  region        = var.region
  env           = var.env
  company       = var.company
  repository_id = var.artifact_registry_repository_id
  description   = "Docker image repository for ${var.env}"
  depends_on    = [module.project-services]
}

# VPC, Subnets, Router, Cloud NAT IPs, NAT GW
module "network" {
  source                  = "../../modules/vpc"
  project                 = var.project
  env                     = var.env
  company                 = var.company
  network_name            = var.network_name
  routing_mode            = var.routing_mode
  project_id              = var.project
  description             = var.description
  mtu                     = var.mtu
  region                  = var.region
  pri_subnet_cidr         = var.pri_subnet_cidr
  pri_vpc_peering_address = var.pri_vpc_peering_address
  depends_on = [module.project-services]
}

# Firewall
module "firewall" {
  source                                 = "../../modules/firewall"
  company               = var.company
  network_id            = module.network.network_id
  pri_subnet_cidr       = var.pri_subnet_cidr
  gke_cluster_ipv4_cidr = var.gke_cluster_ipv4_cidr
  gke_lb_target_tag     = var.gke_lb_target_tag
  use_filestore         = var.use_filestore
  depends_on = [module.project-services, module.network]
}

# IAM
module "iam"{
  source                                 = "../../modules/iam"
  company                 = var.company
  env                     = var.env
  project                 = var.project
  region                  = var.region
  bastion_access_members  = var.bastion_access_members
  bitbucket_workspace     = var.bitbucket_workspace
  frontend_access_members = var.frontend_access_members
  bitbucket_workspace_uuid = var.bitbucket_workspace_uuid
  depends_on = [module.project-services]
}

# SQL
module "sql" {
  source                                 = "../../modules/sql"
  company              = var.company
  project              = var.project
  env                  = var.env
  region               = var.region
  zone                 = var.zone
  db_tier              = var.db_tier
  db_availability_type = var.db_availability_type
  db_version           = var.db_version
  db_disk_size         = var.db_disk_size
  db_disk_type         = var.db_disk_type
  db_deletion          = var.db_deletion
  db_point_recovery    = var.db_point_recovery
  db_name              = var.db_name
  db_user_1            = var.db_user_1
  network_id           = module.network.network_id
  depends_on = [module.project-services, module.network]
}

# Bastion 
module "bastion" {
  source = "../../modules/bastion"
  company               = var.company
  env                   = var.env
  project               = var.project
  region                = var.region
  zone                  = var.zone
  network_id            = module.network.network_id
  privatenetwork_subnet = module.network.privatenetwork_subnet
  bastion_internal_ip   = var.bastion_internal_ip
  bastion_machine_type  = var.bastion_machine_type
  service_account_email = module.iam.bastion_service_account
  backup_schedule_region = var.region
  depends_on = [module.network, module.iam, module.project-services]
}

# NFS GCE - only in use when filestore is disabled
module "nfs" {
  count  = var.use_filestore ? 0 : 1
  source = "../../modules/nfs"
  company               = var.company
  env                   = var.env
  project               = var.project
  region                = var.region
  zone                  = var.zone
  nfs_internal_ip       = var.nfs_internal_ip
  nfs_machine_type      = var.nfs_machine_type
  nfs_data_disk_size_gb = var.nfs_data_disk_size_gb
  nfs_data_disk_type    = var.nfs_data_disk_type
  gke_cluster_ipv4_cidr = var.gke_cluster_ipv4_cidr
  backup_schedule_region = var.region
  network_id            = module.network.network_id
  privatenetwork_subnet = module.network.privatenetwork_subnet
  service_account_email = module.iam.nfs_service_account
  depends_on = [module.project-services, module.network, module.iam]
}

# Filestore - only in use when enabled
module "filestore" {
  count  = var.use_filestore ? 1 : 0
  source = "../../modules/filestore"
  company                = var.company
  env                    = var.env
  project                = var.project
  zone                   = var.zone
  network_name           = module.network.network_name
  filestore_tier         = var.filestore_tier
  filestore_capacity_gb  = var.filestore_capacity_gb
  filestore_share_name   = var.filestore_share_name
  filestore_connect_mode = "DIRECT_PEERING"
  depends_on = [module.project-services]
}

# GKE
module "gke" {
  source                                 = "../../modules/gke"
  company                  = var.company
  project                  = var.project
  env                      = var.env
  region                   = var.region
  zone                     = var.zone
  gke_num_nodes            = var.gke_num_nodes
  min_node_count           = var.min_node_count
  max_node_count           = var.max_node_count
  gke_machine_type         = var.gke_machine_type
  vm_ip_cidr               = var.vm_ip_cidr
  gke_lb_target_tag        = var.gke_lb_target_tag
  gke_cluster_ipv4_cidr    = var.gke_cluster_ipv4_cidr
  gke_master_ipv4_cidr     = var.gke_master_ipv4_cidr
  gke_services_ipv4_cidr   = var.gke_services_ipv4_cidr
  gke_external_secrets_sa  = module.iam.external_secrets_service_account
  db_user_secret_name      = module.sql.db_user_secret_name
  db_password_secret_name  = module.sql.db_password_secret_name
  db_name_secret_name      = module.sql.db_name_secret_name
  authorized_networks      = var.authorized_networks
  gke_cloudsql_sa          = module.iam.gke_sql_service_account
  network_id               = module.network.network_id
  privatenetwork_subnet    = module.network.privatenetwork_subnet
}

# Cloud Run 
module "cr" {
  source                                 = "../../modules/cr"
  company = var.company
  project = var.project
  env     = var.env
  region  = var.region
  depends_on = [module.project-services]
} 

# Load Balancers
module "lbs" {
  source                                 = "../../modules/lbs"
  company                = var.company
  env                    = var.env
  zone                   = var.zone
  project                = var.project
  region                 = var.region
  lb_certificate_domains = var.lb_certificate_domains
  gke_hosts              = var.gke_hosts
  cloudrun_hosts         = var.cloudrun_hosts
  network_id             = module.network.network_id
  lb_ip                  = module.network.LB_IP
  privatenetwork_subnet  = module.network.privatenetwork_subnet
  bs_depends_on          = module.gke.helm_readiness
  depends_on = [module.project-services, module.gke, module.cr]
}