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

if [ ! -f "$PLAYIT_DIR/agent.yml" ]; then
  echo "⚠ No Playit agent.yml found! Starting in claim mode..."
  "$PLAYIT_DIR/playit" &
  PLAYIT_PID=$!
  
  # Give Playit some time to create agent.yml after claim
  sleep 10
  
  if [ -f "$PLAYIT_DIR/agent.yml" ]; then
    echo "✅ Playit generated agent.yml, printing it below:"
    echo "--------------------------------------------"
    cat "$PLAYIT_DIR/agent.yml"
    echo "--------------------------------------------"
    echo "👉 Copy the above YAML into your Render env var PLAYIT_AGENT_YML"
  else
    echo "❌ agent.yml was not generated yet. Use the claim link above to register the agent."
  fi
  
  wait $PLAYIT_PID
else
  echo "✅ Found existing agent.yml, starting Playit..."
  "$PLAYIT_DIR/playit"
fi
