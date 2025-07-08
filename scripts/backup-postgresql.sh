#!/bin/bash

# Dump and backup PostgreSQL databases to S3.
# VERSION: 1.0.0
# DATE:    2025-07-07

declare -a DATABASES=(db1 db2 db3) # Replace with your actual database names

TIMESTAMP=$(date '+%Y%m%dT%H%M%S')
PGPASSFILE="$HOME/.pgpass"
BUCKET_PATH="s3:epistrephein/databases" # Replace with your actual S3 bucket path
HOSTNAME=$(hostname -s)

for db in "${DATABASES[@]}"; do
  echo "Backing up: $db"

  pg_dump -d "$db" | gzip -c > "/tmp/$db-$HOSTNAME-postgresql-$TIMESTAMP.sql.gz" && \
    rclone --s3-no-check-bucket copy "/tmp/$db-$HOSTNAME-postgresql-$TIMESTAMP.sql.gz" "$BUCKET_PATH/$db/"
done
