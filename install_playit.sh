#!/bin/bash
set -e

if [ ! -f "./playit" ]; then
  echo "Downloading Playit..."
  curl -L \
    -o playit \
    https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
  chmod +x playit
fi

# Run Playit tunnel
./playit
