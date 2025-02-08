output "postgresql_instance_link" {
    value = google_sql_database_instance.postgresql.name
    description = "PostgreSQL instance name"
}
