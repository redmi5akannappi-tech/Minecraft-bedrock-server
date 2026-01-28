#!/bin/bash
set -e

PLAYIT_DIR="/server"
PLAYIT_BIN="$PLAYIT_DIR/playit"
PLAYIT_TOML="$PLAYIT_DIR/playit.toml"

# Download if not exists
if [ ! -f "$PLAYIT_BIN" ]; then
  echo "[PLAYIT] Downloading Playit..."
  curl -L \
    -o "$PLAYIT_BIN" \
    https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
  chmod +x "$PLAYIT_BIN"
fi

# Create config file with secret if available
if [ -n "${PLAYIT_SECRET:-}" ]; then
  echo "[PLAYIT] Creating config with PLAYIT_SECRET..."
  cat > "$PLAYIT_TOML" << EOF
secret_key = "$PLAYIT_SECRET"
EOF
  echo "[PLAYIT] Starting Playit with config file..."
  # Run with --stdout to avoid terminal rendering issues in Docker
  exec "$PLAYIT_BIN" --config "$PLAYIT_TOML" --stdout 2>&1
else
  echo "[PLAYIT] WARNING: No PLAYIT_SECRET set!"
  echo "[PLAYIT] To get your secret:"
  echo "[PLAYIT] 1. Run playit locally first to claim it"
  echo "[PLAYIT] 2. Or get it from https://playit.gg/account/agents"
  echo "[PLAYIT] 3. Add PLAYIT_SECRET to Render environment variables"
  # Try running anyway - will show claim link
  exec "$PLAYIT_BIN" --stdout 2>&1 || echo "[PLAYIT] Failed to start"
fi