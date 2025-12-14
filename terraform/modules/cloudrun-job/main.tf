resource "google_cloud_run_v2_job" "job" {
  name     = var.name
  location = var.region


  template {
    template {
       service_account = var.scheduler_sa
      containers {
    image = "google/cloud-sdk:slim"

  command = ["/bin/bash", "-c"]
  args = [
    <<-EOT
      set -euxo pipefail

      echo "Starting Cloud SQL export job"
      date

      PROJECT_ID=$(gcloud config get-value project)
      echo "Project: $PROJECT_ID"

      echo "Listing SQL instances:"
      gcloud sql instances list

      INSTANCE="gcp-dr-sql-dev"
      BUCKET="copper-frame-479111-q5-sql-backups"
      TIMESTAMP=$(date +%Y%m%d%H%M)

      echo "Exporting database from $INSTANCE to $BUCKET"

      gcloud sql export sql $INSTANCE \
        gs://$BUCKET/$INSTANCE-$TIMESTAMP.sql.gz \
        --database=appdb \
        --quiet

      echo "Export completed"
    EOT
  ]
}
    }
  }
}