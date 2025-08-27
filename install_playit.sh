#!/bin/bash
set -e
PLAYIT_DIR="/server/playit-data"
mkdir -p "$PLAYIT_DIR"

# Restore both agent.yml and secret.key from env vars if they exist
if [ -n "$PLAYIT_AGENT_YML" ] && [ -n "$PLAYIT_SECRET_KEY" ]; then
  echo "$PLAYIT_AGENT_YML" > "$PLAYIT_DIR/agent.yml"
  echo "$PLAYIT_SECRET_KEY" > "$PLAYIT_DIR/secret.key"
fi

# Download Playit if missing
if [ ! -f "$PLAYIT_DIR/playit" ]; then
  curl -L https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 -o "$PLAYIT_DIR/playit"
  chmod +x "$PLAYIT_DIR/playit"
fi

cd "$PLAYIT_DIR"

# Check if both required files exist
if [ ! -f "$PLAYIT_DIR/agent.yml" ] || [ ! -f "$PLAYIT_DIR/secret.key" ]; then
  echo "⚠ Missing configuration! Starting in claim mode..."
  "$PLAYIT_DIR/playit" &
  PLAYIT_PID=$!

  # Wait for both files to be created
  echo "⏳ Waiting for configuration files to be created after claim..."
  for i in {1..60}; do
    if [ -f "$PLAYIT_DIR/agent.yml" ] && [ -f "$PLAYIT_DIR/secret.key" ]; then
      echo "✅ Playit generated configuration files. Please save these values:"
      echo ""
      echo "PLAYIT_AGENT_YML:"
      cat "$PLAYIT_DIR/agent.yml"
      echo ""
      echo "PLAYIT_SECRET_KEY:"
      cat "$PLAYIT_DIR/secret.key"
      echo ""
      echo "👉 Add these environment variables to your Render service to persist across restarts"
      kill $PLAYIT_PID
      wait $PLAYIT_PID 2>/dev/null || true
      exit 0
    fi
    sleep 5
  done
  echo "❌ Failed to generate configuration files within timeout"
  kill $PLAYIT_PID
  wait $PLAYIT_PID 2>/dev/null || true
  exit 1
fi

echo "✅ Starting Playit with existing configuration..."
exec "$PLAYIT_DIR/playit"
