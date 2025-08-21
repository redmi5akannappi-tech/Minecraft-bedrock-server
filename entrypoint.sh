#!/bin/bash
set -e

# Start Playit in background
./install_playit.sh &
PLAYIT_PID=$!

# Keep restarting Bedrock to avoid memory leaks
while true; do
    ./start.sh
    echo "Bedrock server stopped or crashed. Restarting in 10 seconds..."
    sleep 10
done

# Cleanup Playit when container stops
kill $PLAYIT_PID
