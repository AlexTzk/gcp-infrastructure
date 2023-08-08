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
    

    location_preference {
      zone = "${var.zone}"
    }

    maintenance_window {
      day  = "7"  # Sunday
      hour = "3"  # 3 AM
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = "${var.db_point_recovery}"
#      location_preference            = "${var.region}"
    
    backup_retention_settings {
      retained_backups = 21
      retention_unit   = "COUNT"
    }
    }
    ip_configuration {
      ipv4_enabled    = false
      private_network = "${var.network_id}"
    }
  }
  
}
resource "google_sql_database" "postgresql_db" {
  name     = "${var.db_name}"
  project  = "${var.project}"
  instance = google_sql_database_instance.postgresql.name
}

#resource "random_id" "user_password" {
#  byte_length = 8
#}

resource "google_sql_user" "postgresql_user_1" {
  name        = "${var.db_user_1}"
  project     = "${var.project}"
  instance    = google_sql_database_instance.postgresql.name
  password    = "${var.db_password_1}"
#  password    = "${var.db_user_password}" != "" ? "${var.db_user_password}" : "${random_id.user_password.hex}"
}
resource "google_sql_user" "postgresql_user_2" {
  name        = "${var.db_user_2}"
  project     = "${var.project}"
  instance    = google_sql_database_instance.postgresql.name
  password    = "${var.db_password_2}"
#  password    = "${var.db_user_password}" != "" ? "${var.db_user_password}" : "${random_id.user_password.hex}"
}