#!/bin/bash
set -e
if [ ! -f "./playit" ]; then
  echo "Downloading Playit..."
  curl -L https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux -o playit
  chmod +x playit
fi
./playit
