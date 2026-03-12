# nfs data disk snapshots
resource "google_compute_resource_policy" "nfs_daily_snapshots" {
  name   = "${var.company}-${var.env}-nfs-snapshots"
  region = var.backup_schedule_region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }

    retention_policy {
      max_retention_days    = 14
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      guest_flush       = false
      storage_locations = [substr(var.region, 0, length(var.region) - 2)]
      labels = {
        env     = var.env
        company = var.company
        role    = "nfs"
      }
    }
  }
}

# nfs boot disk
resource "google_compute_disk" "nfs_boot" {
  name = "${var.company}-${var.env}-nfs-boot"
  type = "pd-balanced"
  zone = var.zone
  size = 20

  image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"

  labels = {
    env     = var.env
    company = var.company
    role    = "nfs"
  }
}

# nfs data disk
resource "google_compute_disk" "nfs_data" {
  name = "${var.company}-${var.env}-nfs-data"
  type = var.nfs_data_disk_type
  zone = var.zone
  size = var.nfs_data_disk_size_gb

  labels = {
    env     = var.env
    company = var.company
    role    = "nfs"
  }
}

# aattach policy
resource "google_compute_disk_resource_policy_attachment" "nfs_boot_backup" {
  name = google_compute_resource_policy.nfs_daily_snapshots.name
  disk = google_compute_disk.nfs_boot.name
  zone = var.zone
}

resource "google_compute_disk_resource_policy_attachment" "nfs_data_backup" {
  name = google_compute_resource_policy.nfs_daily_snapshots.name
  disk = google_compute_disk.nfs_data.name
  zone = var.zone
}

# define GCE instance
resource "google_compute_instance" "nfs" {
  name         = "${var.company}-${var.env}-nfs"
  machine_type = var.nfs_machine_type
  zone         = var.zone

  deletion_protection = false
  enable_display      = false

  labels = {
    env     = var.env
    company = var.company
    role    = "nfs"
  }

  boot_disk {
    source      = google_compute_disk.nfs_boot.id
    device_name = google_compute_disk.nfs_boot.name
  }

  attached_disk {
    source      = google_compute_disk.nfs_data.id
    device_name = "nfs-data"
    mode        = "READ_WRITE"
  }

  metadata = {
    block-project-ssh-keys = "true"
    enable-oslogin         = "true"
    startup-script = file("${path.module}/startup_nfs.sh")
  }

  network_interface {
    network_ip = var.nfs_internal_ip
    subnetwork = var.privatenetwork_subnet
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }

  tags = ["allow-nfs"]

  service_account {
    email  = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }
}