output "network" {
  value       = google_compute_network.network
  description = "The VPC resource being created"
}
output "network_name" {
  value       = google_compute_network.network.name
  description = "The name of the VPC being created"
}
output "network_id" {
  value       = google_compute_network.network.id
  description = "The ID of the VPC being created"
}
output "privatenetwork_subnet" {
  value       = google_compute_subnetwork.private_subnet.name
  description = "Private subnet"
}
output "NAT-IPs" {
  value       = google_compute_address.address.*.address
}
output "LB-IP" {
  value       = google_compute_global_address.loadbalancer_ip.address
}
