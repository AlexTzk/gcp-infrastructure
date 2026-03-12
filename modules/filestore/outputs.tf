output "instance_name" {
  value = google_filestore_instance.shared.name
}

output "ip_addresses" {
  value = google_filestore_instance.shared.networks[0].ip_addresses
}

output "share_name" {
  value = google_filestore_instance.shared.file_shares[0].name
}