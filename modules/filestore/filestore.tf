resource "google_filestore_instance" "shared" {
  name     = "${var.company}-${var.env}-filestore"
  location = var.zone
  tier     = var.filestore_tier

  file_shares {
    name        = var.filestore_share_name
    capacity_gb = var.filestore_capacity_gb
  }

  networks {
    network      = var.network_name
    modes        = [var.filestore_connect_mode]
    connect_mode = var.filestore_connect_mode
  }

  labels = {
    env     = var.env
    company = var.company
    role    = "filestore"
  }
}