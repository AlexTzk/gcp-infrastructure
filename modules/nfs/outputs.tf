output "instance_name" {
  value = google_compute_instance.nfs.name
}

output "internal_ip" {
  value = google_compute_instance.nfs.network_interface[0].network_ip
}

output "export_path" {
  value = "/srv/nfs/shared"
}