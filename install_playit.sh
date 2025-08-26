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

# Always run in correct directory
cd "$PLAYIT_DIR"
"$PLAYIT_DIR/playit"
