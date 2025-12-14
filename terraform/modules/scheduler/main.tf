resource "google_cloud_scheduler_job" "sql_export" {
  name      = var.name
  schedule  = var.schedule
  time_zone = var.time_zone

  http_target {
    uri         = var.target_uri
    http_method = "POST"

    oidc_token {
      service_account_email = var.scheduler_sa
    }
  }
}
