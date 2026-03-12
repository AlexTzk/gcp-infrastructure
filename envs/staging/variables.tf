variable "project" {
  description = "GCP project ID where resources will be created."
  type        = string

  validation {
    condition     = length(trim(var.project, " ")) > 0
    error_message = "project must not be empty."
  }
}

variable "region" {
  description = "Primary GCP region for regional resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9]+[0-9]$", var.region))
    error_message = "region must look like a valid GCP region, for example europe-west2."
  }
}

variable "zone" {
  description = "Primary GCP zone for zonal resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9]+[0-9]-[a-z]$", var.zone))
    error_message = "zone must look like a valid GCP zone, for example europe-west2-a."
  }
}

variable "env" {
  description = "Deployment environment name."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be one of: dev, staging, prod."
  }
}

variable "company" {
  description = "Short company or project prefix used in resource naming."
  type        = string

  validation {
    condition     = length(trim(var.company, " ")) > 0
    error_message = "company must not be empty."
  }
}

variable "network_name" {
  description = "Name of the VPC network."
  type        = string

  validation {
    condition     = length(trim(var.network_name, " ")) > 0
    error_message = "network_name must not be empty."
  }
}

variable "routing_mode" {
  description = "VPC routing mode. Valid values are REGIONAL or GLOBAL."
  type        = string

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "routing_mode must be REGIONAL or GLOBAL."
  }
}

variable "description" {
  description = "Description applied to network resources where supported."
  type        = string
  default     = ""
}

variable "mtu" {
  description = "MTU for the VPC network."
  type        = number

  validation {
    condition     = var.mtu >= 1460 && var.mtu <= 1500
    error_message = "mtu must be between 1460 and 1500."
  }
}

variable "pri_subnet_cidr" {
  description = "Primary subnet CIDR block for the private VPC subnet."
  type        = string

  validation {
    condition     = can(cidrhost(var.pri_subnet_cidr, 0))
    error_message = "pri_subnet_cidr must be a valid CIDR block."
  }
}

variable "pri_vpc_peering_address" {
  description = "CIDR range reserved for Private Service Access / VPC peering."
  type        = string

  validation {
    condition     = can(cidrhost(var.pri_vpc_peering_address, 0))
    error_message = "pri_vpc_peering_address must be a valid CIDR block."
  }
}

variable "gke_cluster_ipv4_cidr" {
  description = "CIDR block used for GKE pod IPs."
  type        = string

  validation {
    condition     = can(cidrhost(var.gke_cluster_ipv4_cidr, 0))
    error_message = "gke_cluster_ipv4_cidr must be a valid CIDR block."
  }
}

variable "gke_master_ipv4_cidr" {
  description = "CIDR block used for the private GKE control plane endpoint."
  type        = string

  validation {
    condition     = can(cidrhost(var.gke_master_ipv4_cidr, 0))
    error_message = "gke_master_ipv4_cidr must be a valid CIDR block."
  }
}

variable "gke_services_ipv4_cidr" {
  description = "CIDR block used for GKE service IPs."
  type        = string

  validation {
    condition     = can(cidrhost(var.gke_services_ipv4_cidr, 0))
    error_message = "gke_services_ipv4_cidr must be a valid CIDR block."
  }
}

variable "db_version" {
  description = "Cloud SQL database engine version."
  type        = string

  validation {
    condition     = contains(["POSTGRES_14", "POSTGRES_15", "POSTGRES_16"], var.db_version)
    error_message = "db_version must be one of: POSTGRES_14, POSTGRES_15, POSTGRES_16."
  }
}

variable "db_tier" {
  description = "Cloud SQL machine tier, for example db-custom-2-7680."
  type        = string

  validation {
    condition     = length(trim(var.db_tier, " ")) > 0
    error_message = "db_tier must not be empty."
  }
}

variable "db_availability_type" {
  description = "Cloud SQL availability type. Use REGIONAL for HA or ZONAL for single-zone."
  type        = string

  validation {
    condition     = contains(["REGIONAL", "ZONAL"], var.db_availability_type)
    error_message = "db_availability_type must be REGIONAL or ZONAL."
  }
}

variable "db_disk_size" {
  description = "Cloud SQL disk size in GB."
  type        = number

  validation {
    condition     = var.db_disk_size >= 10
    error_message = "db_disk_size must be at least 10 GB."
  }
}

variable "db_disk_type" {
  description = "Cloud SQL disk type. Valid values are PD_SSD or PD_HDD."
  type        = string

  validation {
    condition     = contains(["PD_SSD", "PD_HDD"], var.db_disk_type)
    error_message = "db_disk_type must be PD_SSD or PD_HDD."
  }
}

variable "db_point_recovery" {
  description = "Whether Cloud SQL point-in-time recovery is enabled. Required for HA/REGIONAL setups."
  type        = bool
}

variable "db_deletion" {
  description = "Whether deletion protection is enabled for database resources."
  type        = bool
}

variable "db_name" {
  description = "Application database name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
    error_message = "db_name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "db_user_1" {
  description = "Primary application database username."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_user_1))
    error_message = "db_user_1 must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "gke_num_nodes" {
  description = "Initial number of nodes in the GKE node pool."
  type        = number

  validation {
    condition     = var.gke_num_nodes >= 1
    error_message = "gke_num_nodes must be at least 1."
  }
}

variable "min_node_count" {
  description = "Minimum number of nodes for GKE autoscaling."
  type        = number

  validation {
    condition     = var.min_node_count >= 0
    error_message = "min_node_count must be 0 or greater."
  }
}

variable "max_node_count" {
  description = "Maximum number of nodes for GKE autoscaling."
  type        = number

  validation {
    condition     = var.max_node_count >= var.min_node_count
    error_message = "max_node_count must be greater than or equal to min_node_count."
  }
}

variable "gke_machine_type" {
  description = "Machine type used by GKE worker nodes."
  type        = string

  validation {
    condition     = length(trim(var.gke_machine_type, " ")) > 0
    error_message = "gke_machine_type must not be empty."
  }
}

variable "vm_ip_cidr" {
  description = "CIDR block allowed to access the bastion or private control plane where applicable."
  type        = string

  validation {
    condition     = can(cidrhost(var.vm_ip_cidr, 0))
    error_message = "vm_ip_cidr must be a valid CIDR block."
  }
}

variable "authorized_networks" {
  description = "Map of authorized CIDR blocks to display names for GKE master authorized networks."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for cidr, _ in var.authorized_networks : can(cidrhost(cidr, 0))])
    error_message = "All keys in authorized_networks must be valid CIDR blocks."
  }
}

variable "bitbucket_workspace" {
  description = "Bitbucket workspace slug used for Workload Identity Federation."
  type        = string

  validation {
    condition     = length(trim(var.bitbucket_workspace, " ")) > 0
    error_message = "bitbucket_workspace must not be empty."
  }
}

variable "bitbucket_workspace_uuid" {
  description = "Bitbucket workspace UUID used in OIDC trust conditions."
  type        = string

  validation {
    condition     = length(trim(var.bitbucket_workspace_uuid, " ")) > 0
    error_message = "bitbucket_workspace_uuid must not be empty."
  }
}

variable "bastion_access_members" {
  description = "Users or groups allowed to access the bastion through IAP and OS Login. Example: user:alice@example.com or group:platform@example.com"
  type        = list(string)

  validation {
    condition = length(var.bastion_access_members) > 0 && alltrue([
      for member in var.bastion_access_members :
      can(regex("^(user|group|serviceAccount):.+$", member))
    ])
    error_message = "bastion_access_members must contain at least one IAM member string prefixed with user:, group:, or serviceAccount:."
  }
}

variable "use_filestore" {
  description = "When true, provision Filestore. When false, provision the NFS VM."
  type        = bool
  default     = false
}

variable "bastion_internal_ip" {
  description = "Static internal IP address assigned to the bastion VM."
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.bastion_internal_ip))
    error_message = "bastion_internal_ip must be a valid IPv4 address."
  }
}

variable "nfs_internal_ip" {
  description = "Static internal IP address assigned to the NFS VM."
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.nfs_internal_ip))
    error_message = "nfs_internal_ip must be a valid IPv4 address."
  }
}

variable "bastion_machine_type" {
  description = "Machine type for the bastion VM."
  type        = string
  default     = "e2-micro"
}

variable "nfs_machine_type" {
  description = "Machine type for the NFS VM."
  type        = string
  default     = "e2-small"
}

variable "nfs_data_disk_size_gb" {
  description = "Persistent data disk size in GB for the NFS VM."
  type        = number
  default     = 200

  validation {
    condition     = var.nfs_data_disk_size_gb >= 50
    error_message = "nfs_data_disk_size_gb must be at least 50."
  }
}

variable "nfs_data_disk_type" {
  description = "Persistent data disk type for the NFS VM."
  type        = string
  default     = "pd-ssd"

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd"], var.nfs_data_disk_type)
    error_message = "nfs_data_disk_type must be one of: pd-standard, pd-balanced, pd-ssd."
  }
}

variable "filestore_tier" {
  description = "Filestore service tier."
  type        = string
  default     = "BASIC_HDD"

  validation {
    condition = contains([
      "BASIC_HDD",
      "BASIC_SSD",
      "ZONAL",
      "REGIONAL",
      "ENTERPRISE"
    ], var.filestore_tier)
    error_message = "filestore_tier must be one of: BASIC_HDD, BASIC_SSD, ZONAL, REGIONAL, ENTERPRISE."
  }
}

variable "filestore_capacity_gb" {
  description = "Filestore capacity in GB."
  type        = number
  default     = 1024
}

variable "filestore_share_name" {
  description = "Filestore exported share name."
  type        = string
  default     = "sharedfiles"
}

variable "gke_hosts" {
  description = "Hostnames routed to the GKE backend."
  type        = list(string)

  validation {
    condition     = length(var.gke_hosts) > 0
    error_message = "gke_hosts must contain at least one hostname."
  }
}

variable "cloudrun_hosts" {
  description = "Hostnames routed to the Cloud Run backend."
  type        = list(string)

  validation {
    condition     = length(var.cloudrun_hosts) > 0
    error_message = "cloudrun_hosts must contain at least one hostname."
  }
}

variable "lb_certificate_domains" {
  description = "Domains attached to the managed LB certificate."
  type        = list(string)

  validation {
    condition     = length(var.lb_certificate_domains) > 0
    error_message = "lb_certificate_domains must contain at least one domain."
  }
}

variable "frontend_access_members" {
  description = "Users or groups that should receive the frontend custom role."
  type        = list(string)
  default     = []
}

variable "gke_lb_target_tag" {
  description = "Network tag applied to GKE nodes that should receive LB traffic."
  type        = string
}

variable "artifact_registry_repository_id" {
  description = "Artifact Registry repository ID for container images."
  type        = string
}