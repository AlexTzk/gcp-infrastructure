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
    metadata             = "INCLUDE_ALL_METADATA"
  }
  source_ranges = [
    "${var.pri_subnet_cidr}",
    "${var.pub_subnet_cidr}"
  ]
}
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
resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.company}-fw-allow-ssh"
  network = "${var.network_id}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["allow-ssh"]
  source_ranges = ["${var.office_ip}",
                    "${var.failsafe_ip}"
  ]
  }
resource "google_compute_firewall" "allow-postgres" {
  name    = "${var.company}-fw-allow-postgres"
  network = "${var.network_id}"
  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  target_tags = ["allow-postgres"]
  source_ranges = ["${var.office_ip}",
                    "${var.failsafe_ip}"
  ]
  }