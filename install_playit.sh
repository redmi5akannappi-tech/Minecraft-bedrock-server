#!/bin/bash
set -e

cd /server

if [ ! -f "./playit" ]; then
  echo "[PLAYIT] Downloading Playit..."
  curl -L \
    -o playit \
    https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
  chmod +x playit
fi

echo "[PLAYIT] Starting Playit agent..."
echo "[PLAYIT] ================================================"
echo "[PLAYIT] If this is first run, look for claim URL below!"
echo "[PLAYIT] Make sure tunnel points to 127.0.0.1:19132"
echo "[PLAYIT] ================================================"

# Run playit (runs in background via entrypoint)
./playit 2>&1