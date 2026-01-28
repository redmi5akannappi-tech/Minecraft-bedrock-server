#!/bin/bash
set -e

if [ ! -f "./playit" ]; then
  echo "[PLAYIT] Downloading Playit..."
  curl -L \
    -o playit \
    https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
  chmod +x playit
fi

# Run Playit tunnel with secret if available
if [ -n "${PLAYIT_SECRET:-}" ]; then
  echo "[PLAYIT] Using PLAYIT_SECRET for persistent connection..."
  ./playit --secret "$PLAYIT_SECRET"
else
  echo "[PLAYIT] WARNING: No PLAYIT_SECRET set!"
  echo "[PLAYIT] The tunnel will need to be reclaimed after each restart."
  echo "[PLAYIT] To fix: Get your secret from https://playit.gg/account/agents"
  echo "[PLAYIT] Then add PLAYIT_SECRET to your Render environment variables."
  ./playit
fi