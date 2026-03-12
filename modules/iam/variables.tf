variable "company" {
  description = "Company or project prefix."
  type        = string
}

variable "env" {
  description = "Deployment environment."
  type        = string
}

variable "project" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Primary GCP region."
  type        = string
}

variable "bitbucket_workspace" {
  description = "Bitbucket workspace slug."
  type        = string
}

variable "bitbucket_workspace_uuid" {
  description = "Bitbucket workspace UUID."
  type        = string
}

variable "bastion_access_members" {
  description = "Users or groups allowed to access the bastion via IAP and OS Login."
  type        = list(string)

  validation {
    condition = length(var.bastion_access_members) > 0 && alltrue([
      for member in var.bastion_access_members :
      can(regex("^(user|group|serviceAccount):.+$", member))
    ])
    error_message = "bastion_access_members must contain valid IAM member strings."
  }
}

variable "frontend_access_members" {
  description = "Users or groups that should receive the frontend custom role."
  type        = list(string)
  default     = []
}