#!/bin/bash

# Targz and upload .backup folder to S3.
# VERSION: 1.0.2
# DATE:    2022-08-15

# Configuration
BUCKET_PATH="s3:epistrephein/backups" # Replace with your actual S3 bucket path
BACKUP_FOLDER="$HOME/.backup" # Replace with your actual backup folder path

HOSTNAME=$(hostname -s)
TIMESTAMP=$(date '+%Y%m%dT%H%M%S')
ARCHIVE_NAME="$HOSTNAME-backup-$TIMESTAMP"

find "$BACKUP_FOLDER" -printf "%P\n" | tar czvf "/tmp/$ARCHIVE_NAME.tar.gz" --transform "s,^,$ARCHIVE_NAME/," --no-recursion -C "$BACKUP_FOLDER" -T - && rclone --s3-no-check-bucket copy "/tmp/$ARCHIVE_NAME.tar.gz" "$BUCKET_PATH/$HOSTNAME/"
