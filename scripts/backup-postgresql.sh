#!/bin/bash
# Dump and backup PostgreSQL databases to S3.

# Configuration
declare -a DATABASES=(db1 db2 db3) # Replace with your actual database names
BUCKET_PATH="s3:your_bucket/databases" # Replace with your actual S3 bucket path

PGPASSFILE="$HOME/.pgpass"
TIMESTAMP=$(date '+%Y%m%dT%H%M%S')
HOSTNAME=$(hostname -s)

# Backup each database and upload to S3
for db in "${DATABASES[@]}"; do
  echo "Backing up: $db"

  pg_dump -d "$db" | gzip -c > "/tmp/$db-$HOSTNAME-postgresql-$TIMESTAMP.sql.gz" && \
    rclone --s3-no-check-bucket copy "/tmp/$db-$HOSTNAME-postgresql-$TIMESTAMP.sql.gz" "$BUCKET_PATH/$db/"
done
