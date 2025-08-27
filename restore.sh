#!/bin/bash
set -e

WORLD_NAME="MyWorld"
RESTORE_DIR="/tmp/bedrock_restore"
WORLD_DIR="/server/worlds"

rm -rf "$RESTORE_DIR"
git clone https://$GITHUB_USER:$GITHUB_TOKEN@github.com/redmi5akannappi-tech/Minecraft-world-data.git "$RESTORE_DIR"

cd "$RESTORE_DIR"
cat world_chunk_* > world_backup.tar.gz

mkdir -p "$WORLD_DIR"
tar xzf world_backup.tar.gz -C "$WORLD_DIR"

# Optional: Update server.properties if it exists
if [ -f "/server/server.properties" ]; then
    sed -i "s/^level-name=.*/level-name=$WORLD_NAME/" /server/server.properties
fi
