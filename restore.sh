#!/usr/bin/env bash
set -euo pipefail

GITHUB_REPO="${GITHUB_REPO:-}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
TIMESTAMP="${TIMESTAMP:-}"  # e.g. 20251114T123456Z
WORLD_DIR="${WORLD_DIR:-/server/worlds}"
TMPDIR="/tmp/restore_${TIMESTAMP:-latest}"

if [ -z "$GITHUB_REPO" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_REPO and GITHUB_TOKEN must be set" >&2
  exit 1
fi

# If timestamp not provided, list backups and pick latest
if [ -z "$TIMESTAMP" ]; then
  echo "Finding latest backup timestamp..."
  # list contents of 'backups' directory
  resp=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/${GITHUB_REPO}/contents/backups")
  TIMESTAMP=$(echo "$resp" | jq -r '.[].name' | sort -r | head -n1)
  if [ -z "$TIMESTAMP" ] || [ "$TIMESTAMP" = "null" ]; then
    echo "No backups found in repo/backups" >&2
    exit 1
  fi
  echo "Using latest timestamp: $TIMESTAMP"
fi

mkdir -p "$TMPDIR"
cd "$TMPDIR"

# Fetch manifest to know parts
manifest_url="https://api.github.com/repos/${GITHUB_REPO}/contents/backups/${TIMESTAMP}"
manifest_list=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$manifest_url" | jq -r '.[] | .name')

# find manifest file
manifest_file=$(echo "$manifest_list" | grep manifest_ || true)
if [ -z "$manifest_file" ]; then
  echo "No manifest file found in backups/${TIMESTAMP}" >&2
  echo "Listing remote files:"
  echo "$manifest_list"
  exit 1
fi

echo "Found manifest: $manifest_file"

# download and parse manifest
manifest_json=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/${GITHUB_REPO}/contents/backups/${TIMESTAMP}/${manifest_file}" | jq -r '.content' | base64 -d)
echo "$manifest_json" > "$manifest_file"

parts=$(echo "$manifest_json" | jq -r '.parts[].file')
if [ -z "$parts" ]; then
  echo "No parts listed in manifest" >&2
  exit 1
fi

# Download each part
i=0
for p in $parts; do
  echo "Downloading $p"
  content=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/${GITHUB_REPO}/contents/backups/${TIMESTAMP}/${p}" | jq -r '.content')
  echo "$content" | base64 -d > "$p"
  i=$((i+1))
done

# Concatenate parts back into single archive name found in manifest
archive_name=$(echo "$manifest_json" | jq -r '.archive')
cat ${archive_name}.part-* > "$archive_name"

# Extract into world dir (backup will contain folder name, usually "worlds")
mkdir -p /server
tar -xzf "$archive_name" -C /server

echo "Restored files to /server. Move or rename as needed to ${WORLD_DIR}."
echo "Cleanup $TMPDIR if everything looks good."
