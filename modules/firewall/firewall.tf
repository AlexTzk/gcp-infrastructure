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

# Enable HTTPS for exposing endpoints
resource "google_compute_firewall" "allow-https" {
  name    = "${var.company}-fw-allow-https"
  network = "${var.network_id}"
allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  target_tags = ["allow-https"]
  source_ranges = ["0.0.0.0/0"] 
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