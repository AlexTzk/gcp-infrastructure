output "nfs_service_account" {
  value       = google_service_account.nfs_vm_service_account.email
  description = "The SA used for GCE Bastion instance"
}