locals {
  env = "dev"
}


module "network" {
  source      = "./modules/network"
  vpc_name    = "gcp-dr-vpc-${local.env}"
  subnet_name = "gcp-dr-subnet-${local.env}"
  subnet_cidr = "10.10.0.0/24"
  region      = var.region
}


module "iam" {
  source       = "./modules/iam"
  account_id   = "gcp-dr-sa-${local.env}"
  display_name = "gcp-dr service account"
  project      = var.gcp_project
  role         = "roles/run.admin"
}


module "cloudrun_service" {
  source = "./modules/cloudrun"

  service_name = "gcp-dr-demo-${local.env}"
  image        = "gcr.io/${var.gcp_project}/gcp-dr-demo:day1"
  region       = var.region
  project      = var.gcp_project
}


module "backup_bucket" {
  source      = "./modules/gcs-backup"
  bucket_name = "${var.gcp_project}-sql-backups"
  location    = var.region
}


module "cloudsql" {
  source        = "./modules/cloudsql"
  instance_name = "gcp-dr-sql-dev"
  db_name       = "appdb"
  region        = var.region
  tier          = "db-custom-1-3840"
  vpc_id        = module.network.vpc_id

  depends_on = [
    module.network
  ]
}

module "backup_replica" {
  source              = "./modules/gcs-replica"
  source_bucket       = module.backup_bucket.bucket_name
  replica_bucket_name = "${var.gcp_project}-sql-backups-replica"
  replica_location    = "us-east1"
}


module "sql_export_job" {
  source = "./modules/cloudrun-job"

  name         = "sql-export-job"
  region       = var.region
  image        = "google/cloud-sdk:slim"
  project      = var.gcp_project
  scheduler_sa = module.iam.service_account_email
}
module "sql_export_scheduler" {
  source = "./modules/scheduler"

  name      = "sql-export-nightly"
  schedule  = "0 2 * * *"
  time_zone = "UTC"

  target_uri   = "https://us-central1-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/copper-frame-479111-q5/jobs/sql-export-job:run"
  scheduler_sa = module.iam.service_account_email
}
