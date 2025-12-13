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


module "cloudrun" {
  source       = "./modules/cloudrun"
  service_name = "gcp-dr-demo-${local.env}"
  image        = "gcr.io/${var.gcp_project}/gcp-dr-demo:day1"
  region       = var.region
  project      = var.gcp_project
}