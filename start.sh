#!/usr/bin/env bash
set -euo pipefail

cd /server
export LD_LIBRARY_PATH=.

echo "[START] Launching Minecraft Bedrock..."
./bedrock_server
