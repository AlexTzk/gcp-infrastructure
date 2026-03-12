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

# random password for db user
resource "random_password" "db_password_1" {
  length           = 32
  special          = true
  override_special = "_%@"
}

# google secret manager upload
resource "google_secret_manager_secret" "db_user_1" {
  secret_id = "${var.company}-${var.env}-db-user"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_user_1_v1" {
  secret      = google_secret_manager_secret.db_user_1.id
  secret_data = var.db_user_1
}

resource "google_secret_manager_secret" "db_password_1" {
  secret_id = "${var.company}-${var.env}-db-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_1_v1" {
  secret      = google_secret_manager_secret.db_password_1.id
  secret_data = random_password.db_password_1.result
}

resource "google_secret_manager_secret" "db_name" {
  secret_id = "${var.company}-${var.env}-db-name"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_name_v1" {
  secret      = google_secret_manager_secret.db_name.id
  secret_data = var.db_name
}

# create a DB within the host DB
resource "google_sql_database" "postgresql_db" {
  name     = "${var.db_name}"
  project  = "${var.project}"
  instance = google_sql_database_instance.postgresql.name
}

# create a local user and password
resource "google_sql_user" "postgresql_user_1" {
  name     = var.db_user_1
  project  = var.project
  instance = google_sql_database_instance.postgresql.name
  password = random_password.db_password_1.result
}
