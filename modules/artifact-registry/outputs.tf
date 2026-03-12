output "repository_id" {
  description = "Artifact Registry repository ID."
  value       = google_artifact_registry_repository.docker_repo.repository_id
}

output "repository_name" {
  description = "Full Artifact Registry repository resource name."
  value       = google_artifact_registry_repository.docker_repo.name
}

output "repository_url" {
  description = "Base Artifact Registry Docker URL."
  value       = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.docker_repo.repository_id}"
}