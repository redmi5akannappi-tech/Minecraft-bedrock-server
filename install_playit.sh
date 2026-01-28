#!/bin/bash
set -e

if [ ! -f "./playit" ]; then
  echo "[PLAYIT] Downloading Playit..."
  curl -L \
    -o playit \
    https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
  chmod +x playit
fi

echo "[PLAYIT] Starting Playit agent..."
echo "[PLAYIT] Look for the claim URL in the logs if this is first run"

# Run Playit tunnel
./playit