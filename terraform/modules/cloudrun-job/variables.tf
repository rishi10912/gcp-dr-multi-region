variable "name" { type = string }
variable "region" { type = string }
variable "image" { type = string }
variable "project" { type = string }

variable "scheduler_sa" {
  type        = string
  description = "Service account email used by Cloud Scheduler to invoke the Cloud Run job"
}