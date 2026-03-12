output "postgresql_instance_link" {
    value = google_sql_database_instance.postgresql.name
    description = "PostgreSQL instance name"
}

output "db_user_secret_id" {
  value       = google_secret_manager_secret.db_user_1.id
  description = "Secret Manager secret id for DB username"
}

output "db_password_secret_id" {
  value       = google_secret_manager_secret.db_password_1.id
  description = "Secret Manager secret id for DB password"
}

output "db_name_secret_id" {
  value       = google_secret_manager_secret.db_name.id
  description = "Secret Manager secret id for DB name"
}

output "db_user_secret_name" {
  value       = google_secret_manager_secret.db_user_1.secret_id
  description = "Secret Manager name for DB username"
}

output "db_password_secret_name" {
  value       = google_secret_manager_secret.db_password_1.secret_id
  description = "Secret Manager name for DB password"
}

output "db_name_secret_name" {
  value       = google_secret_manager_secret.db_name.secret_id
  description = "Secret Manager name for DB name"
}