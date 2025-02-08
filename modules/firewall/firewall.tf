# Allow internal traffic on all ports
resource "google_compute_firewall" "allow-internal" {
  name    = "${var.company}-fw-allow-internal"
  network = "${var.network_id}"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  source_ranges = ["${var.pri_subnet_cidr}"]
}

# Allow traffic from LB for reverse proxy to GKE/other services
resource "google_compute_firewall" "allow_tcp_loadbalancer" {
  name    = "allow-tcp-loadbalancer"
  network = "${var.network_id}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  direction = "INGRESS"
  priority  = 1000
}

# Allow GCP IAP ranges to Bastion SSH host access
resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.company}-fw-allow-ssh"
  network = "${var.network_id}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["allow-ssh"]
  source_ranges = ["35.235.240.0/20"]
}

# Allow GKE to GCE NFS share 
resource "google_compute_firewall" "allow-gke" {
  name    = "${var.company}-fw-allow-gke"
  network = "${var.network_id}"
  allow {
    protocol = "tcp"
    ports    = ["2049"]
  }
  target_tags = ["allow-gke"]
  source_ranges = ["${var.gke_cluster_ipv4_cidr}"]
}
