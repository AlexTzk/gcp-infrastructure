variable "project" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Artifact Registry region."
  type        = string
}

variable "env" {
  description = "Deployment environment."
  type        = string
}

variable "company" {
  description = "Company or project prefix."
  type        = string
}

variable "repository_id" {
  description = "Artifact Registry repository ID."
  type        = string
}

variable "description" {
  description = "Artifact Registry repository description."
  type        = string
  default     = "Docker image repository"
}