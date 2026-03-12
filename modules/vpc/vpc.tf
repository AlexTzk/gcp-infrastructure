# VPC
resource "google_compute_network" "network" {
  name                            = "${var.network_name}-${var.env}-${var.company}"
  auto_create_subnetworks         =  false
  routing_mode                    = "${var.routing_mode}"
  project                         = "${var.project}"
  description                     = "${var.description}"
  mtu                             = "${var.mtu}"
}

#	Shared VPC block for connecting other Google projects
# # A host project provides network resources to associated service projects
/*resource "google_compute_shared_vpc_host_project" "shared_vpc_host" {
  provider = google-beta
  count      = "${var.shared_vpc_host}" ? 1 : 0
  project    = "${var.project}"
  depends_on = [google_compute_network.network]
}

# A service project gains access to network resources provided by its
# associated host project.
resource "google_compute_shared_vpc_service_project" "service1" {
  host_project    = google_compute_shared_vpc_host_project.shared_vpc_host.project
  service_project = "service-project-id-1"
}

resource "google_compute_shared_vpc_service_project" "service2" {
  host_project    = google_compute_shared_vpc_host_project.shared_vpc_host.project
  service_project = "service-project-id-2"
}*/

# Subnet - if exposing VMs or DBs would recommend cloning the block below for a public subnet along with firewall rules
resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.network_name}-${var.env}-${var.company}-private"
  ip_cidr_range = "${var.pri_subnet_cidr}"
  network       = google_compute_network.network.id
  region        = "${var.region}"
  depends_on    = [google_compute_network.network]
  log_config {
    aggregation_interval = "INTERVAL_15_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# VPC peer - can use private service connect instead but VPC peering worked great so far for me
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.company}-${var.env}-private-services-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  network       = google_compute_network.network.id
  address       = "${var.pri_vpc_peering_address}"
  prefix_length = 24
  depends_on    = [google_compute_subnetwork.private_subnet]
}

# Private VPC connector
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  depends_on              = [google_compute_global_address.private_ip_address]
}

# Router
resource "google_compute_router" "router" {
  name    = "${google_compute_network.network.name}-nat-router"
  network = google_compute_network.network.id
  region  = "${var.region}"
}

# Cloud NAT IPs - configured as one but can expand 
resource "google_compute_address" "address" {
  count  = 1
  name   = "nat-manual-ip-${count.index}"
  region = "${var.region}"
  depends_on = [google_compute_router.router]
}

# Global Load balancer IP
resource "google_compute_global_address" "loadbalancer_ip" {
  name   = "${var.company}-${var.env}-lb-ip"
  depends_on = [google_compute_router.router]
}

# NAT gateway 
resource "google_compute_router_nat" "nat_manual" {
  name                               = "${google_compute_network.network.name}-nat-gw"
  router                             = google_compute_router.router.name
  region                             = "${var.region}"
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.address.*.self_link
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
  depends_on = [google_compute_address.address]
}