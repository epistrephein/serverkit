#!/bin/bash

# Backup files and settings to a local backup folder.
# VERSION: 1.0.0
# DATE:    2025-07-12

# Configuration
BACKUP_FOLDER="$HOME/.local/backup" # Replace with your actual backup folder path

# Backup crontab
mkdir -p "$BACKUP_FOLDER/crontab"
crontab -l > "$BACKUP_FOLDER/crontab/crontab.txt"

# Backup nginx sites configurations
mkdir -p "$BACKUP_FOLDER/nginx"
rsync -a "/etc/nginx/sites-available"/* "$BACKUP_FOLDER/nginx/"

# Backup www directories
rsync -a "/var/www" "$BACKUP_FOLDER/" --exclude={.git,vendor,node_modules,*.pid,*.sock}

# Backup scripts
mkdir -p "$BACKUP_FOLDER/scripts"
rsync -a "$HOME/.local/scripts" "$BACKUP_FOLDER/"
