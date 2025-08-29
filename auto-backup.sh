#!/bin/bash

# Query Bedrock server for online players
players=$(curl -s http://localhost:19132/status | jq '.players.online' 2>/dev/null)

# If the query fails, assume 0 players
players=${players:-0}

if [ "$players" -eq 0 ]; then
    echo "[AutoBackup] No players online, running backup..."
    /server/backup.sh
else
    echo "[AutoBackup] $players players online, skipping backup..."
fi
