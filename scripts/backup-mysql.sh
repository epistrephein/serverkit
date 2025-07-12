#!/bin/bash

# Dump and backup MySQL databases to S3.
# VERSION: 1.0.2
# DATE:    2022-07-16

# Configuration
declare -a DATABASES=(db1 db2 db3) # Replace with your actual database names
BUCKET_PATH="s3:epistrephein/databases" # Replace with your actual S3 bucket path

MYSQLFILE="$HOME/.mysqldump"
TIMESTAMP=$(date '+%Y%m%dT%H%M%S')
HOSTNAME=$(hostname -s)

# Backup each database and upload to S3
for db in "${DATABASES[@]}"; do
  echo "Backing up: $db"

  mysqldump --defaults-extra-file=$MYSQLFILE "$db" | gzip -c > "/tmp/$db-$HOSTNAME-mysql-$TIMESTAMP.sql.gz" && \
    rclone --s3-no-check-bucket copy "/tmp/$db-$HOSTNAME-mysql-$TIMESTAMP.sql.gz" "$BUCKET_PATH/$db/"
done
