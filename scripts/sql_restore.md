# Cloud SQL Disaster Recovery Restore Procedure

## Scenario
Primary region (us-central1) is unavailable.

## Steps

1. Identify latest backup
   gsutil ls gs://copper-frame-479111-q5-sql-backups | tail -1

2. Create new Cloud SQL instance in secondary region
   gcloud sql instances create gcp-dr-sql-restore \
     --database-version=POSTGRES_14 \
     --region=us-east1 \
     --tier=db-custom-1-3840 \
     --network=gcp-dr-vpc-dev

3. Restore from backup
   gcloud sql import sql gcp-dr-sql-restore \
     gs://<backup-file> \
     --database=appdb