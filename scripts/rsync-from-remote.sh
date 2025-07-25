#!/bin/bash
# Rsync files from a remote server to a local directory.

# Configuration
REMOTE_ALIAS="your_server" # Replace with your actual remote alias
DEST_DIR="/tmp/rsync" # Replace with your actual destination

FILELIST="filelist.txt"

# Ensure the destination directory exists
mkdir -p "$DEST_DIR"

# Read the filelist and sync each path
while IFS= read -r REMOTE_PATH || [ -n "$REMOTE_PATH" ]; do
  [[ -z "$REMOTE_PATH" || "$REMOTE_PATH" =~ ^# ]] && continue

  echo "=> Syncing $REMOTE_PATH..."
  rsync -avz --relative "${REMOTE_ALIAS}:${REMOTE_PATH}" "$DEST_DIR"
done < "$FILELIST"
