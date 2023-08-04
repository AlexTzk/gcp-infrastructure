# VPC
resource "google_compute_network" "network" {
  name                            = "${var.network_name}-${var.env}-${var.company}"
  auto_create_subnetworks         = "${var.auto_create_subnetworks}"
  routing_mode                    = "${var.routing_mode}"
  project                         = "${var.project}"
  description                     = "${var.description}"
  delete_default_routes_on_create = "${var.delete_default_internet_gateway_routes}"
  mtu                             = "${var.mtu}"
}

#	Shared VPC
resource "google_compute_shared_vpc_host_project" "shared_vpc_host" {
  provider = google-beta
  count      = "${var.shared_vpc_host}" ? 1 : 0
  project    = "${var.project}"
  depends_on = [google_compute_network.network]
}

# Subnets
resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.network_name}-${var.env}-${var.company}-public"
  ip_cidr_range = "${var.pub_subnet_cidr}"
  network       = google_compute_network.network.id
  region        = "${var.region}"
  depends_on    = [google_compute_network.network]
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
    filter_expr          = "true"
  }
}
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
    filter_expr          = "true"
  }
}

# Router
resource "google_compute_router" "router" {
  name    = "${google_compute_network.network.name}-nat-router"
  network = google_compute_network.network.id
  region  = "${var.region}"
}

# Cloud NAT IPs
resource "google_compute_address" "address" {
  count  = 2
  name   = "nat-manual-ip-${count.index}"
  region = "${var.region}"
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