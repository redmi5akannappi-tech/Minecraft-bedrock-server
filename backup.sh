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

# Clone or update repo
if [ ! -d "$REPO_DIR/.git" ]; then
    git clone https://github.com/redmi5akannappi-tech/Minecraft-world-data.git "$REPO_DIR"
fi

cd "$REPO_DIR"
git config user.email "backup@render.com"
git config user.name "Backup Script"
git pull origin main

# Copy new chunks and push
rm -f world_chunk_*
cp "$BACKUP_DIR"/world_chunk_* .
git add world_chunk_*
if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
else
    git commit -m "Backup $(date)"
    git push https://$GITHUB_USER:$GITHUB_TOKEN@github.com/redmi5akannappi-tech/Minecraft-world-data.git main
fi
