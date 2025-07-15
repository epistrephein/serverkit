#!/bin/bash
# Backup files and settings to a local backup folder.

# Configuration
BACKUP_FOLDER="$HOME/.local/backup" # Replace with your actual backup folder path

# Backup crontab
mkdir -p "$BACKUP_FOLDER/crontab"
crontab -l > "$BACKUP_FOLDER/crontab/crontab.txt"

# Backup dotfiles
mkdir -p "$BACKUP_FOLDER/dotfiles"
rsync -a --ignore-missing-args "$HOME"/{.bashrc,.inputrc} "$BACKUP_FOLDER/dotfiles/"

# Backup ssh configurations
mkdir -p "$BACKUP_FOLDER/ssh"
rsync -a --ignore-missing-args "$HOME"/.ssh/{authorized_keys,config,known_hosts} "$BACKUP_FOLDER/ssh/"

# Backup apt package lists
mkdir -p "$BACKUP_FOLDER/apt"
apt list --manual-installed=true 2>/dev/null | tail -n +2 | cut -d/ -f1 > "$BACKUP_FOLDER/apt/manual-packages.txt"

# Backup nginx sites configurations
mkdir -p "$BACKUP_FOLDER/nginx"
rsync -a "/etc/nginx/sites-available"/* "$BACKUP_FOLDER/nginx/"

# Backup www directories
rsync -a "/var/www" "$BACKUP_FOLDER/" --exclude={.git,vendor,node_modules,*.pid,*.sock}

# Backup scripts
mkdir -p "$BACKUP_FOLDER/scripts"
rsync -a --ignore-missing-args "$HOME/.local/scripts" "$BACKUP_FOLDER/"
