#!/bin/bash
set -e

PLAYIT_DIR="/server/playit-data"
mkdir -p "$PLAYIT_DIR"

# Check if this is the first run (no configuration saved)
if [ -z "$PLAYIT_CONFIGURED" ] || [ "$PLAYIT_CONFIGURED" != "true" ]; then
    echo "🔧 First-time setup detected. Starting setup process..."
    
    # Download Playit if missing
    if [ ! -f "$PLAYIT_DIR/playit" ]; then
        echo "📥 Downloading Playit agent..."
        curl -L https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 -o "$PLAYIT_DIR/playit"
        chmod +x "$PLAYIT_DIR/playit"
    fi

    cd "$PLAYIT_DIR"
    
    # Start playit and check if it creates config files quickly
    echo "🔧 Starting Playit agent..."
    "$PLAYIT_DIR/playit" &
    PLAYIT_PID=$!
    
    # Wait a bit to see if config files appear (already claimed scenario)
    sleep 10
    
    if [ -f "$PLAYIT_DIR/agent.yml" ] && [ -f "$PLAYIT_DIR/secret.key" ]; then
        echo "✅ Found existing Playit configuration!"
        echo "📋 Your tunnel is already set up. Save these environment variables:"
        echo "========================================================="
        echo ""
        echo "PLAYIT_AGENT_YML:"
        cat "$PLAYIT_DIR/agent.yml" | base64 -w 0
        echo ""
        echo ""
        echo "PLAYIT_SECRET_KEY:"  
        cat "$PLAYIT_DIR/secret.key" | base64 -w 0
        echo ""
        echo ""
        echo "PLAYIT_CONFIGURED=true"
        echo ""
        echo "Add these to your Render environment variables to avoid this setup next time!"
        
        # Keep running
        wait $PLAYIT_PID
        exit 0
    else
        # No config files found, run full setup
        exec /server/setup_playit.sh
    fi
fi

echo "✅ Playit configuration found in environment variables"

# Restore configuration from environment variables (base64 encoded)
if [ -n "$PLAYIT_AGENT_YML" ] && [ -n "$PLAYIT_SECRET_KEY" ]; then
    echo "📂 Restoring Playit configuration..."
    echo "$PLAYIT_AGENT_YML" | base64 -d > "$PLAYIT_DIR/agent.yml"
    echo "$PLAYIT_SECRET_KEY" | base64 -d > "$PLAYIT_DIR/secret.key"
    
    # Verify files were created successfully
    if [ ! -s "$PLAYIT_DIR/agent.yml" ] || [ ! -s "$PLAYIT_DIR/secret.key" ]; then
        echo "❌ Failed to restore configuration files"
        echo "   Please check your environment variables and try again"
        exit 1
    fi
    
    echo "✅ Configuration restored successfully"
else
    echo "❌ Missing PLAYIT_AGENT_YML or PLAYIT_SECRET_KEY environment variables"
    echo "   Starting first-time setup..."
    exec /server/setup_playit.sh
fi

# Download Playit if missing
if [ ! -f "$PLAYIT_DIR/playit" ]; then
    echo "📥 Downloading Playit agent..."
    curl -L https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 -o "$PLAYIT_DIR/playit"
    chmod +x "$PLAYIT_DIR/playit"
fi

cd "$PLAYIT_DIR"

echo "🚀 Starting Playit with saved configuration..."

# Start playit and keep it running
exec "$PLAYIT_DIR/playit"
