resource "google_storage_bucket" "backup" {
  name     = var.bucket_name
  location = var.location


  versioning {
    enabled = true
  }


  uniform_bucket_level_access = true
}