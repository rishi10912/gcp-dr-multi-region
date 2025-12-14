resource "google_storage_bucket" "replica" {
  name     = var.replica_bucket_name
  location = var.replica_location


  versioning { enabled = true }
  uniform_bucket_level_access = true
}

