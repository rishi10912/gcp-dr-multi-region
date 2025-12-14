output "service_account_email" {
  description = "Email of the service account used by Cloud Scheduler and Cloud Run Jobs"
  value       = google_service_account.sa.email
}