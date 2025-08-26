#!/bin/bash
set -e
PLAYIT_DIR="/server/playit-data"
mkdir -p "$PLAYIT_DIR"

# If env var exists, restore config
if [ ! -f "$PLAYIT_DIR/agent.yml" ] && [ -n "$PLAYIT_AGENT_YML" ]; then
  echo "$PLAYIT_AGENT_YML" > "$PLAYIT_DIR/agent.yml"
fi

# Download Playit if missing
if [ ! -f "$PLAYIT_DIR/playit" ]; then
  curl -L https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 -o "$PLAYIT_DIR/playit"
  chmod +x "$PLAYIT_DIR/playit"
fi

# If no agent.yml yet, run in claim mode (first-time setup)
if [ ! -f "$PLAYIT_DIR/agent.yml" ]; then
  echo "⚠ No Playit agent.yml found! Starting in claim mode..."
  "$PLAYIT_DIR/playit"
else
  "$PLAYIT_DIR/playit" --config "$PLAYIT_DIR/agent.yml"
fi
