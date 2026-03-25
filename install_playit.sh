#!/bin/bash
set -e

# Install playit via official PPA (used during Docker build)
echo "[PLAYIT] Installing Playit via PPA..."

curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | tee /etc/apt/sources.list.d/playit-cloud.list
apt-get update
apt-get install -y playit

echo "[PLAYIT] Playit installed successfully."
echo "[PLAYIT] ================================================"
echo "[PLAYIT] When running, look for the claim URL in logs!"
echo "[PLAYIT] Create tunnels for:"
echo "[PLAYIT]   - 127.0.0.1:25565 (TCP - Java Edition)"
echo "[PLAYIT]   - 127.0.0.1:19132 (UDP - Bedrock via Geyser)"
echo "[PLAYIT] ================================================"