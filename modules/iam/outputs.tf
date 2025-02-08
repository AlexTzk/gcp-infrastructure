output "nfs_service_account" {
  value       = google_service_account.nfs_vm_service_account.email
  description = "The SA used for GCE Bastion instance"
}
output "gke_sql_service_account" {
  value       = google_service_account.gke_cloudsql_sa.email
  description = "The SA used for GKE to access CloudSQL"
}
