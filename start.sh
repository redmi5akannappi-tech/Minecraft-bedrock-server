#!/usr/bin/env bash
set -euo pipefail

cd /server

echo "[START] Launching Minecraft Paper server..."
java -Xms128M -Xmx256M -jar paper.jar --nogui
