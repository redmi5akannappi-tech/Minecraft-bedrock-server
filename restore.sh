#!/usr/bin/env bash
set -euo pipefail

WORLD_DIR="${WORLD_DIR:-/server/worlds}"
GITHUB_REPO="${GITHUB_REPO:-}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

# If no repo config, skip restore
if [ -z "$GITHUB_REPO" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo "[RESTORE] No GitHub config. Skipping restore."
    exit 0
fi

# Check if backups folder exists
resp=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_REPO/contents/backups")

# No backups available
if echo "$resp" | jq -e 'type=="array"' >/dev/null 2>&1; then
    latest=$(echo "$resp" | jq -r '.[].name' | sort -r | head -n 1)
else
    echo "[RESTORE] No backups found."
    exit 0
fi

if [ -z "$latest" ]; then
    echo "[RESTORE] No backups exist."
    exit 0
fi

echo "[RESTORE] Found backup: $latest"

# Download manifest
manifest=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_REPO/contents/backups/$latest" \
    | jq -r '.[] | select(.name|startswith("manifest")) | .download_url')

if [ -z "$manifest" ]; then
    echo "[RESTORE] Manifest missing."
    exit 0
fi

tmp="/tmp/restore_$latest"
mkdir -p "$tmp"

curl -L "$manifest" -o "$tmp/manifest.json"
parts=$(jq -r '.parts[].file' "$tmp/manifest.json")

echo "[RESTORE] Downloading parts..."
for p in $parts; do
    url="https://raw.githubusercontent.com/$GITHUB_REPO/main/backups/$latest/$p"
    curl -L "$url" -o "$tmp/$p"
done

# Rebuild archive
archive=$(jq -r '.archive' "$tmp/manifest.json")
cat "$tmp/$archive".part-* > "$tmp/$archive"

echo "[RESTORE] Extracting archive..."
rm -rf "$WORLD_DIR"
tar -xzf "$tmp/$archive" -C /server

echo "[RESTORE] Restore complete."
