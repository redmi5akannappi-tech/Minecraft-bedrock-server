#!/usr/bin/env bash
set -euo pipefail

# env defaults
FAKE_PORT="${FAKE_PORT:-8080}"
BACKUP_INTERVAL_SECONDS="${BACKUP_INTERVAL_SECONDS:-86400}"

cd /server

# Start fake HTTP/TCP server so Render sees a listening TCP port
python3 ./fake_server.py & 
FAKE_PID=$!

# Optionally install or start Playit (if you have script)
if [ -x ./install_playit.sh ]; then
  ./install_playit.sh || true &
fi

# Start periodic backup background daemon
if [ -x ./auto-backup.sh ]; then
  ./auto-backup.sh & 
  BACKUP_PID=$!
fi

# Start the monitored bedrock server
./start.sh

# When start.sh returns (server stopped), kill background processes
echo "Bedrock server exited. Cleaning up..."
kill ${FAKE_PID} 2>/dev/null || true
kill ${BACKUP_PID:-0} 2>/dev/null || true
wait
