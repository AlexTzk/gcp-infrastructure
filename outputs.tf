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