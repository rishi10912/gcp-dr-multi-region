#!/usr/bin/env bash
set -e
TIMESTAMP=$(date +%Y%m%d%H%M)
INSTANCE=gcp-dr-sql-dev
BUCKET=${PROJECT}-sql-backups


gcloud sql export sql $INSTANCE \
gs://$BUCKET/$INSTANCE-$TIMESTAMP.sql.gz \
--database=appdb