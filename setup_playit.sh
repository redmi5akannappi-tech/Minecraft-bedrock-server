#!/bin/bash
set -e

PLAYIT_DIR="/server/playit-data"
mkdir -p "$PLAYIT_DIR"

echo "🚀 First-time Playit.gg setup for Render"
echo "========================================"

# Download Playit if missing
if [ ! -f "$PLAYIT_DIR/playit" ]; then
  echo "📥 Downloading Playit agent..."
  curl -L https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 -o "$PLAYIT_DIR/playit"
  chmod +x "$PLAYIT_DIR/playit"
fi

cd "$PLAYIT_DIR"

echo "🔧 Starting Playit in claim mode..."
echo "Please follow these steps:"
echo "1. Go to https://playit.gg/login"
echo "2. Login or create an account"
echo "3. You'll see a claim code below - enter it on the website"
echo "4. Once claimed, this script will show you the environment variables"
echo ""

# Start playit in background
"$PLAYIT_DIR/playit" &
PLAYIT_PID=$!

# Give it a moment to start
sleep 5

# Look for claim URL in the output or logs
echo "🔗 Check the logs above for the claim URL and code"
echo "   It should look like: https://playit.gg/claim/XXXXXX"
echo ""

# Wait for both configuration files to be created
echo "⏳ Waiting for you to claim the agent on playit.gg..."
echo "   (This script will wait up to 10 minutes)"

for i in {1..120}; do
    if [ -f "$PLAYIT_DIR/agent.yml" ] && [ -f "$PLAYIT_DIR/secret.key" ]; then
        echo ""
        echo "✅ SUCCESS! Playit has been claimed and configured."
        echo ""
        echo "📋 COPY THESE VALUES TO YOUR RENDER ENVIRONMENT VARIABLES:"
        echo "========================================================="
        echo ""
        echo "Variable name: PLAYIT_AGENT_YML"
        echo "Value:"
        echo "---"
        cat "$PLAYIT_DIR/agent.yml" | base64 -w 0
        echo ""
        echo "---"
        echo ""
        echo "Variable name: PLAYIT_SECRET_KEY"
        echo "Value:"
        echo "---"
        cat "$PLAYIT_DIR/secret.key" | base64 -w 0
        echo ""
        echo "---"
        echo ""
        echo "Variable name: PLAYIT_CONFIGURED"
        echo "Value: true"
        echo ""
        echo "🔧 HOW TO ADD THESE TO RENDER:"
        echo "1. Go to your Render service dashboard"
        echo "2. Click on 'Environment'"
        echo "3. Add the three variables above"
        echo "4. Deploy your service again"
        echo ""
        echo "⚠️  IMPORTANT: The values above are base64 encoded to handle multiline content"
        echo ""
        
        # Keep playit running so the tunnel stays active
        echo "🌐 Playit tunnel is now active. Keeping it running..."
        wait $PLAYIT_PID
        exit 0
    fi
    
    if [ $((i % 10)) -eq 0 ]; then
        echo "⏳ Still waiting... ($((i * 5)) seconds elapsed)"
    fi
    
    sleep 5
done

echo "❌ Timeout reached. Please try again."
kill $PLAYIT_PID 2>/dev/null || true
wait $PLAYIT_PID 2>/dev/null || true
exit 1
