#!/bin/bash
set -e

curl -L https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 -o playit
chmod +x playit

echo "Playit installed successfully."
