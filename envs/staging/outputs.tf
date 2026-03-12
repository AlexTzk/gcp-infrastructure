output "network_id" {
    value = module.network.network_id
}
output "NAT-IPs" {
    value = module.network.NAT-IPs
}
output "privatenetwork_subnet" {
    value =  module.network.privatenetwork_subnet
}
output "nfs_service_account" {
    value = module.iam.nfs_service_account
}
output "artifact_registry_repository_url" {
  description = "Base Artifact Registry URL for pushing and pulling container images."
  value       = module.artifact_registry.repository_url
}
output "artifact_registry_repository_name" {
  description = "Artifact Registry repository resource name."
  value       = module.artifact_registry.repository_name
}

# Artifact Registry
artifact_registry_repository_id = "mycompany-staging-images"