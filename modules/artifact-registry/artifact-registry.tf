resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project
  location      = var.region
  repository_id = var.repository_id
  description   = var.description
  format        = "DOCKER"

  labels = {
    env     = var.env
    company = var.company
  }
}