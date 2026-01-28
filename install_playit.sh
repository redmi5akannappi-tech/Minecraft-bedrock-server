#!/bin/bash
set -e

PLAYIT_BIN="/server/playit"

# Download if not exists
if [ ! -f "$PLAYIT_BIN" ]; then
  echo "[PLAYIT] Downloading Playit..."
  curl -L \
    -o "$PLAYIT_BIN" \
    https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
  chmod +x "$PLAYIT_BIN"
fi

# Playit reads secret from SECRET_KEY env var
# Support both PLAYIT_SECRET and SECRET_KEY for flexibility
if [ -n "${PLAYIT_SECRET:-}" ]; then
  export SECRET_KEY="$PLAYIT_SECRET"
fi

if [ -n "${SECRET_KEY:-}" ]; then
  echo "[PLAYIT] Starting with SECRET_KEY..."
  exec "$PLAYIT_BIN" 2>&1
else
  echo "[PLAYIT] WARNING: No SECRET_KEY or PLAYIT_SECRET set!"
  echo "[PLAYIT] Generate one at: https://playit.gg/account/agents/new-docker"
  echo "[PLAYIT] Then add SECRET_KEY to Render environment variables"
  # Try running anyway - may show claim link
  exec "$PLAYIT_BIN" 2>&1 || echo "[PLAYIT] Failed to start"
fiplay