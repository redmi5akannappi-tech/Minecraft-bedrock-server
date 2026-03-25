#!/usr/bin/env bash
set -euo pipefail

cd /server

echo "[START] Launching Minecraft Paper server..."
java -Xms256M -Xmx400M -jar paper.jar --nogui
