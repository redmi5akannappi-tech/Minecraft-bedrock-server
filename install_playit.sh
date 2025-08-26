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

cd "$PLAYIT_DIR"

if [ ! -f "$PLAYIT_DIR/agent.yml" ]; then
  echo "⚠ No Playit agent.yml found! Starting in claim mode..."
  "$PLAYIT_DIR/playit" &
  PLAYIT_PID=$!

  echo "⏳ Waiting for agent.yml to be created after claim..."
  for i in {1..60}; do   # wait up to 5 minutes
    if [ -f "$PLAYIT_DIR/agent.yml" ]; then
      echo "✅ Playit generated agent.yml, printing it below:"
      echo "--------------------------------------------"
      cat "$PLAYIT_DIR/agent.yml"
      echo "--------------------------------------------"
      echo "👉 Copy the above YAML into your Render env var PLAYIT_AGENT_YML"
      kill $PLAYIT_PID || true
      break
    fi
    sleep 5
  done
fi

# At this point, either env var restored or claim created agent.yml
echo "✅ Starting Playit with existing agent.yml..."
"$PLAYIT_DIR/playit"
