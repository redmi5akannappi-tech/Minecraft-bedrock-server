#!/bin/bash
set -e

# Dummy HTTP server for Render
python3 -m http.server ${PORT:-8080} --bind 0.0.0.0 &
DUMMY_PID=$!

# Restore world from GitHub
/server/restore.sh || echo "No backup found, starting fresh world."

# Start Playit in background
/server/install_playit.sh &
PLAYIT_PID=$!

# Start backup watcher in background
/server/auto-backup.sh &
BACKUP_WATCHER_PID=$!

# Start Bedrock server
/server/start.sh &
BEDROCK_PID=$!

# On shutdown, backup world + cleanup
trap "/server/backup.sh; kill $PLAYIT_PID $DUMMY_PID $BEDROCK_PID $BACKUP_WATCHER_PID" EXIT

wait
