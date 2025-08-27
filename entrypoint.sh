#!/bin/bash
set -e

echo "🚀 Starting Minecraft Bedrock Server on Render Free Tier"
echo "========================================================"

# Dummy HTTP server for Render (required for free tier)
echo "🌐 Starting HTTP server for Render health checks..."
python3 -m http.server ${PORT:-8080} --bind 0.0.0.0 &
DUMMY_PID=$!
echo "✅ HTTP server started on port ${PORT:-8080}"

# Start cron service for scheduled backups
echo "📅 Starting cron service..."
service cron start

# Restore world from backup
echo "🗺️  Restoring world from backup..."
/server/restore.sh || echo "ℹ️  No backup found, starting with fresh world."

# Start Playit in background - this handles first-time setup automatically
echo "🔧 Setting up Playit.gg tunnel..."
/server/install_playit.sh &
PLAYIT_PID=$!

# Start backup watcher in background
echo "💾 Starting backup watcher..."
/server/auto-backup.sh &
BACKUP_WATCHER_PID=$!

# Give Playit a moment to initialize
sleep 5

# Check if Playit is still running (important for first-time setup)
if ! kill -0 $PLAYIT_PID 2>/dev/null; then
    echo "⚠️  Playit process ended - this might be normal for first-time setup"
    echo "   Check logs above for setup instructions"
fi

# Start Bedrock server
echo "🎮 Starting Minecraft Bedrock Server..."
/server/start.sh &
BEDROCK_PID=$!

echo "✅ All services started!"
echo "📋 Process Summary:"
echo "   - HTTP Server (PID: $DUMMY_PID) on port ${PORT:-8080}"
echo "   - Playit Tunnel (PID: $PLAYIT_PID)"
echo "   - Backup Watcher (PID: $BACKUP_WATCHER_PID)"
echo "   - Bedrock Server (PID: $BEDROCK_PID)"

# Enhanced shutdown handler
cleanup() {
    echo ""
    echo "🛑 Shutdown signal received, cleaning up..."
    
    # Backup world before shutdown
    echo "💾 Creating backup before shutdown..."
    /server/backup.sh || echo "⚠️  Backup failed"
    
    # Kill all background processes
    echo "🔄 Stopping services..."
    kill $DUMMY_PID 2>/dev/null || echo "HTTP server already stopped"
    kill $PLAYIT_PID 2>/dev/null || echo "Playit already stopped"  
    kill $BACKUP_WATCHER_PID 2>/dev/null || echo "Backup watcher already stopped"
    kill $BEDROCK_PID 2>/dev/null || echo "Bedrock server already stopped"
    
    echo "✅ Cleanup complete"
}

# Set up signal handlers
trap cleanup EXIT INT TERM

# Wait for any process to exit
wait
