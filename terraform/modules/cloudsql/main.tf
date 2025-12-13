resource "google_sql_database_instance" "primary" {
  name             = var.instance_name
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = var.tier

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
    }

    availability_type = "REGIONAL"

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_id
    }
  }

  deletion_protection = false
}
resource "google_sql_database" "app" {
  name     = var.db_name
  instance = google_sql_database_instance.primary.name
}

