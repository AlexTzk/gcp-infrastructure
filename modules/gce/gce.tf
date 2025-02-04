# Create a VM 

resource "google_compute_instance" "bastion-nfs" {
  boot_disk {
    auto_delete = true
    device_name = "bastion-nfs-os-disk"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20250117"
      size  = 80
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  # Change the deletion_protection to True in PROD
  deletion_protection = false
  enable_display      = false

  labels = {
    env = "${var.env}"
    company = "${var.company}"
  }

  machine_type = "n2d-standard-2"
  # RAID 0 these two nvme's through the staging script 375G * 2 => 750G => 2x R/W speeds
    scratch_disk {
    interface = "NVME"
  }
  scratch_disk {
    interface = "NVME"
  }

  metadata = {
    block-project-ssh-keys = "true"
    enable-oslogin         = "true"
    startup-script =  file("${path.module}/startup_nfs.sh")
  }

  name = "${var.company}-${var.env}-bastion-nfs"
  # Assign IP from the vars file 
  network_interface {
    network_ip = "${var.vm_ip_nfs}"
    subnetwork = "${var.privatenetwork_subnet}"
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }
  # enable secure boot and tampering - might want to disable if you plan on migrating it to different architecture
  # secure boot creates a hardware fingerprint so migration won't be as easy as attaching the drive to new instance
  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }

  tags = ["allow-ssh", "allow-gke"]
  zone = "${var.zone}"
}

# Grant user access to bastion host
resource "google_iap_tunnel_instance_iam_member" "instance" {
  instance = "${var.company}-${var.env}-bastion-nfs"
  zone     = "${var.zone}"
  role     = "roles/iap.tunnelResourceAccessor"
  member   = "user:alexandru@hey.com"
  depends_on = [google_compute_instance.bastion-nfs]
}
