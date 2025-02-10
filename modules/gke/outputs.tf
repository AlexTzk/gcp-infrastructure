output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}
output "helm_readiness" {
  value     = helm_release.nginx_ingress
  description = "a BS output so LBS module doesn't try to MAP NEG before its ready"
}
