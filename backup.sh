#!/bin/bash
set -e

# Use environment variables with defaults
WORLD_NAME="${WORLD_NAME:-MyWorld}"
WORLD_DIR="/server/worlds"
BACKUP_DIR="/tmp/bedrock_backup"
CHUNK_SIZE="50M"  # Smaller for Render's resources
REPO_DIR="/server/bedrock-backups"

# Ensure necessary environment variables are set
if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo "ERROR: GITHUB_USER and GITHUB_TOKEN environment variables must be set"
    exit 1
fi

rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Check if world exists
if [ ! -d "$WORLD_DIR/$WORLD_NAME" ]; then
    echo "World directory $WORLD_DIR/$WORLD_NAME does not exist"
    exit 0
fi

# Compress world
echo "Compressing world..."
tar czf "$BACKUP_DIR/world_backup.tar.gz" -C "$WORLD_DIR" "$WORLD_NAME"

# Split into chunks
cd "$BACKUP_DIR"
split -b $CHUNK_SIZE world_backup.tar.gz world_chunk_

# Push to GitHub
if [ ! -d "$REPO_DIR/.git" ]; then
    git clone https://$GITHUB_USER:$GITHUB_TOKEN@github.com/redmi5akannappi-tech/Minecraft-world-data.git "$REPO_DIR"
fi

cd "$REPO_DIR"
git config user.email "backup@render.com"
git config user.name "Backup Script"
git pull origin main || true

rm -f world_chunk_*
cp "$BACKUP_DIR"/world_chunk_* .
git add world_chunk_*

if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
else
    git commit -m "Backup $(date +"%Y-%m-%d %H:%M:%S")"
    git push origin main
fi

echo "Backup completed successfully"
