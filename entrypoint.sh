#!/usr/bin/env bash
set -euo pipefail

cd /server

# ============================================
# 1. Start fake HTTP server for Render health
# ============================================
echo "[ENTRYPOINT] Starting fake HTTP server on port ${FAKE_PORT:-8080}..."
python3 fake_server.py &
FAKE_PID=$!
sleep 1

# ============================================
# 2. Start Playit tunnel (if installed)
# ============================================
if [ -x ./install_playit.sh ]; then
    echo "[ENTRYPOINT] Starting Playit tunnel..."
    ./install_playit.sh &
    PLAYIT_PID=$!
    sleep 3
fi

# ============================================
# 3. Attempt to restore world (if backup exists)
# ============================================
if [ -x ./restore.sh ]; then
    echo "[ENTRYPOINT] Checking for backups..."
    ./restore.sh || echo "[ENTRYPOINT] No restore performed."
fi

# ============================================
# 4. Start auto-backup service
# ============================================
if [ -x ./auto-backup.sh ]; then
    echo "[ENTRYPOINT] Starting backup scheduler..."
    ./auto-backup.sh &
fi

# ============================================
# 5. Start Bedrock server LAST
# ============================================
echo "[ENTRYPOINT] Starting Bedrock server..."
./start.sh
