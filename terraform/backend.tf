terraform {
  backend "gcs" {
    bucket = "copper-frame-479111-q5-tf-state"
    prefix = "dr/dev"
  }
}