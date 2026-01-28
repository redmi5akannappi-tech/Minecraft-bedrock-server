#!/bin/bash
set -e

cd /server

# Start a dummy HTTP server so Render detects an open TCP port
python3 -m http.server ${PORT:-8080} --bind 0.0.0.0 &
DUMMY_PID=$!

# Download and start Playit
if [ ! -f "./playit" ]; then
  echo "[PLAYIT] Downloading Playit..."
  curl -L \
    -o playit \
    https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
  chmod +x playit
fi

echo "[PLAYIT] ================================================"
echo "[PLAYIT] Starting Playit - WATCH FOR CLAIM URL BELOW!"
echo "[PLAYIT] Make sure tunnel points to 127.0.0.1:19132"
echo "[PLAYIT] ================================================"
./playit &
PLAYIT_PID=$!

# Attempt to restore world from backup
if [ -x ./restore.sh ]; then
    echo "[BACKUP] Checking for backups to restore..."
    ./restore.sh || echo "[BACKUP] No restore performed."
fi

# Start auto-backup service
if [ -x ./auto-backup.sh ]; then
    echo "[BACKUP] Starting backup scheduler..."
    ./auto-backup.sh &
    BACKUP_PID=$!
fi

# Cleanup on exit
trap "kill $PLAYIT_PID $DUMMY_PID $BACKUP_PID 2>/dev/null" EXIT

# Keep restarting Bedrock to avoid memory leaks
while true; do
    echo "[BEDROCK] Starting Minecraft Bedrock server..."
    export LD_LIBRARY_PATH=.
    ./bedrock_server || true
    echo "[BEDROCK] Server stopped or crashed. Restarting in 10 seconds..."
    sleep 10
done
