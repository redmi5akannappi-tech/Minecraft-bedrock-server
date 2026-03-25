#!/bin/bash
set -e

cd /server

# Start a dummy HTTP server so Render detects an open TCP port
python3 -m http.server ${PORT:-8080} --bind 0.0.0.0 &
DUMMY_PID=$!

# Start Playit (installed via apt)
echo "[PLAYIT] ================================================"
echo "[PLAYIT] Starting Playit - WATCH FOR CLAIM URL BELOW!"
echo "[PLAYIT] Create tunnels for:"
echo "[PLAYIT]   - 127.0.0.1:25565 (TCP - Java Edition)"
echo "[PLAYIT]   - 127.0.0.1:19132 (UDP - Bedrock via Geyser)"
echo "[PLAYIT] ================================================"
playit &
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

# Keep restarting Paper to avoid memory leaks
while true; do
    echo "[PAPER] Starting Minecraft Paper server..."
    java -Xms256M -Xmx400M -jar paper.jar --nogui || true
    echo "[PAPER] Server stopped or crashed. Restarting in 10 seconds..."
    sleep 10
done
