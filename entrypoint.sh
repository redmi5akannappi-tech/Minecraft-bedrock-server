#!/bin/bash
set -e

# Start Playit in background
./install_playit.sh &
PLAYIT_PID=$!

# Start Bedrock server (foreground)
./start.sh

# Clean up Playit if Bedrock exits
kill $PLAYIT_PID
