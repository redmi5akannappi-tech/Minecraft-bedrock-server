#!/bin/bash
set -e

# Start a dummy HTTP server so Render detects an open TCP port
# Runs in the background
python3 -m http.server ${PORT:-8080} --bind 0.0.0.0 &
DUMMY_PID=$!

# Start Playit in background
./install_playit.sh &
PLAYIT_PID=$!

# Keep restarting Bedrock to avoid memory leaks
while true; do
    ./start.sh
    echo "Bedrock server stopped or crashed. Restarting in 10 seconds..."
    sleep 10
done

# Cleanup on exit
trap "kill $PLAYIT_PID $DUMMY_PID" EXIT
