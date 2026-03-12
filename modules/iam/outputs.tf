output "nfs_service_account" {
  value       = google_service_account.nfs_vm_service_account.email
  description = "The SA used for NFS instance"
}
output "gke_sql_service_account" {
  value       = google_service_account.gke_cloudsql_sa.email
  description = "The SA used for GKE to access CloudSQL"
}
output "bitbucket_service_account_email" {
  value       = google_service_account.bitbucket_service_account.email
  description = "Service account for Bitbucket Pipelines"
}
output "bitbucket_workload_identity_provider" {
  value       = google_iam_workload_identity_pool_provider.bitbucket_provider.name
  description = "Full resource name of the Bitbucket WIF provider"
}
output "external_secrets_service_account" {
  value       = google_service_account.external_secrets_sa.email
  description = "GSA for External Secrets Operator"
}
output "bastion_service_account" {
  value       = google_service_account.bastion_vm_service_account.email
  description = "Service account attached to the bastion VM."
}