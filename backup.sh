#!/bin/bash
set -e

WORLD_NAME="MyWorld"
WORLD_DIR="/server/worlds"
BACKUP_DIR="/tmp/bedrock_backup"
CHUNK_SIZE="90M"
REPO_DIR="/server/bedrock-backups"

rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Compress world
tar czf "$BACKUP_DIR/world_backup.tar.gz" -C "$WORLD_DIR" "$WORLD_NAME"

# Split into chunks
cd "$BACKUP_DIR"
split -b $CHUNK_SIZE world_backup.tar.gz world_chunk_

# Push to GitHub
if [ ! -d "$REPO_DIR/.git" ]; then
    git clone https://github.com/you/bedrock-backups.git "$REPO_DIR"
fi

cd "$REPO_DIR"
rm -f world_chunk_*
cp "$BACKUP_DIR"/world_chunk_* .
git add world_chunk_*
git commit -m "Backup $(date)" || true
git push origin main || true
