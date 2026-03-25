#!/bin/bash
set -e

cd /server

# Start a dummy HTTP server so Render detects an open TCP port
python3 -m http.server ${PORT:-8080} --bind 0.0.0.0 &
DUMMY_PID=$!

# Start Playit and capture output so claim URL is visible
echo ""
echo "######################################################"
echo "#                                                    #"
echo "#   PLAYIT STARTING - WATCH FOR CLAIM URL BELOW!     #"
echo "#                                                    #"
echo "#   Tunnels will be created for:                     #"
echo "#     - 127.0.0.1:25565 (TCP - Java Edition)         #"
echo "#     - 127.0.0.1:19132 (UDP - Bedrock via Geyser)   #"
echo "#                                                    #"
echo "######################################################"
echo ""

# Run playit and prefix ALL its output so it stands out in logs
# Also save to a log file for easy retrieval
playit 2>&1 | while IFS= read -r line; do
    echo "[PLAYIT] $line"
    echo "$line" >> /server/playit.log
    # Highlight the claim URL when it appears
    if echo "$line" | grep -qi "claim"; then
        echo ""
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "!!! CLAIM URL FOUND: $line"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo ""
    fi
done &
PLAYIT_PID=$!

# Wait for playit to print claim URL before starting Paper
echo "[WAIT] Giving playit 15 seconds to display claim URL..."
sleep 15

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
