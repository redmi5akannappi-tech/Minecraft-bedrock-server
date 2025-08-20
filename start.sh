#!/bin/bash
cd /tmp/server

# Accept EULA if missing
if [ ! -f "eula.txt" ]; then
    echo "eula=true" > eula.txt
fi

echo "Starting Minecraft Bedrock server..."
LD_LIBRARY_PATH=. ./bedrock_server
