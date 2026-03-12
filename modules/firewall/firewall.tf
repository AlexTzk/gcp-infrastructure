# allow ping
resource "google_compute_firewall" "allow_internal_icmp" {
  name    = "${var.company}-fw-allow-internal-icmp"
  network = var.network_id

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.pri_subnet_cidr]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# allow port 80 and 443
resource "google_compute_firewall" "allow_internal_web" {
  name    = "${var.company}-fw-allow-internal-web"
  network = var.network_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = [var.pri_subnet_cidr]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# allow internal 8080
resource "google_compute_firewall" "allow_internal_8080" {
  name    = "${var.company}-fw-allow-internal-8080"
  network = var.network_id

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = [var.gke_cluster_ipv4_cidr]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# allow gke to postgres
resource "google_compute_firewall" "allow_gke_to_postgres" {
  name    = "${var.company}-fw-allow-gke-to-postgres"
  network = var.network_id

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [var.gke_cluster_ipv4_cidr]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# allow lb to nginx gke
resource "google_compute_firewall" "allow_lb_to_gke_nginx" {
  name    = "${var.company}-fw-allow-lb-to-gke-nginx"
  network = var.network_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = [var.gke_lb_target_tag]

  direction = "INGRESS"
  priority  = 1000

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# allow ssh iap
resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "${var.company}-fw-allow-ssh"
  network = var.network_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["allow-ssh"]
  source_ranges = ["35.235.240.0/20"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# allow gke to nfs - only enabled when filestore is disabled
resource "google_compute_firewall" "allow_gke_to_nfs" {
  count   = var.use_filestore ? 0 : 1
  name    = "${var.company}-fw-allow-gke-to-nfs"
  network = var.network_id

  allow {
    protocol = "tcp"
    ports    = ["2049"]
  }

  target_tags   = ["allow-nfs"]
  source_ranges = [var.gke_cluster_ipv4_cidr]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}