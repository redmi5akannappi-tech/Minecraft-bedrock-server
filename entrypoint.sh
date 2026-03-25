# #!/bin/bash
# set -e

# cd /server

# # Start a dummy HTTP server so Render detects an open TCP port
# python3 -m http.server ${PORT:-8080} --bind 0.0.0.0 &
# DUMMY_PID=$!

# # =====================================================
# # PLAYIT SETUP - uses SECRET_KEY env var
# # =====================================================

# if [ -n "$SECRET_KEY" ]; then
#     echo "[PLAYIT] Secret key found! Starting playit agent..."
#     # Write secret to a temp file (playit reads it this way)
#     echo "$SECRET_KEY" > /server/playit_secret.toml
#     playit --secret "$SECRET_KEY" 2>&1 | sed 's/^/[PLAYIT] /' &
#     PLAYIT_PID=$!
#     echo "[PLAYIT] Agent started. Manage tunnels at https://playit.gg/account/tunnels"
# else
#     echo ""
#     echo "######################################################"
#     echo "#  WARNING: SECRET_KEY not set!                      #"
#     echo "#  Add SECRET_KEY env var in Render dashboard.       #"
#     echo "######################################################"
#     echo ""
#     playit 2>&1 | sed 's/^/[PLAYIT] /' &
#     PLAYIT_PID=$!
# fi

# sleep 5

# # Attempt to restore world from backup
# # if [ -x ./restore.sh ]; then
# #     echo "[BACKUP] Checking for backups to restore..."
# #     ./restore.sh || echo "[BACKUP] No restore performed."
# # fi

# # Start auto-backup service
# # if [ -x ./auto-backup.sh ]; then
# #     echo "[BACKUP] Starting backup scheduler..."
# #     ./auto-backup.sh &
# #     BACKUP_PID=$!
# # fi

# # Cleanup on exit
# trap "kill $PLAYIT_PID $DUMMY_PID $BACKUP_PID 2>/dev/null" EXIT

# # Keep restarting Paper to avoid memory leaks
# # while true; do
# #     echo "[PAPER] Starting Minecraft Paper server..."
# #     java -Xms256M -Xmx400M -jar paper.jar --nogui || true
# #     echo "[PAPER] Server stopped or crashed. Restarting in 10 seconds..."
# #     sleep 10
# # done
# java -Xms128M -Xmx256M -jar paper.jar --nogui
#!/bin/bash
#!/bin/bash
set -e

cd /server

# HTTP server for Render
python3 -m http.server ${PORT:-8080} --bind 0.0.0.0 &

# Start Minecraft FIRST
echo "[PAPER] Starting Minecraft server..."
java -Xms128M -Xmx192M -jar paper.jar --nogui &
MC_PID=$!

# Delay Playit start
sleep 15

# Start Playit
if [ -n "$SECRET_KEY" ]; then
    echo "[PLAYIT] Starting..."
    playit --secret "$SECRET_KEY" &
else
    playit &
fi

wait $MC_PID