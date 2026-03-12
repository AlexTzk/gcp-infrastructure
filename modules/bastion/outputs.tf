output "instance_name" {
  value = google_compute_instance.bastion.name
}

output "internal_ip" {
  value = google_compute_instance.bastion.network_interface[0].network_ip
}