# create a db
resource "google_sql_database_instance" "postgresql" {
  provider              = google-beta
  name                  = "${var.company}-${var.env}-db1"
  project               = "${var.project}"
  region                = "${var.region}"
  database_version      = "${var.db_version}"
  deletion_protection   = "${var.db_deletion}"
  settings {
    tier                = "${var.db_tier}"
    availability_type   = "${var.db_availability_type}"
    disk_size           = "${var.db_disk_size}"
    disk_type           = "${var.db_disk_type}"
    maintenance_window {
      day  = "7"
      hour = "3"
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "04:00"
      point_in_time_recovery_enabled = "${var.db_point_recovery}"
    
    backup_retention_settings {
      retained_backups = 21
      retention_unit   = "COUNT"
    }
    }
    ip_configuration {
      ipv4_enabled    = false
      private_network = "${var.network_id}"
      ssl_mode        = "ENCRYPTED_ONLY"
    }
  }
}

# create a DB within the host DB
resource "google_sql_database" "postgresql_db" {
  name     = "${var.db_name}"
  project  = "${var.project}"
  instance = google_sql_database_instance.postgresql.name
}

# create a local user and password
resource "google_sql_user" "postgresql_user_1" {
  name        = "${var.db_user_1}"
  project     = "${var.project}"
  instance    = google_sql_database_instance.postgresql.name
  password    = "${var.db_password_1}"
}
