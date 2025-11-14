#!/usr/bin/env bash
set -euo pipefail

# Config
WORLD_DIR="${WORLD_DIR:-/server/worlds}"
CHUNK_SIZE="${BACKUP_CHUNK_SIZE:-90M}"
GITHUB_REPO="${GITHUB_REPO:-}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
TMPDIR="/tmp/backup_$TIMESTAMP"
ARCHIVE_NAME="world_$TIMESTAMP.tar.gz"
MANIFEST="manifest_$TIMESTAMP.json"
REMOTE_BASE_PATH="backups/${TIMESTAMP}"

if [ -z "$GITHUB_REPO" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_REPO and GITHUB_TOKEN must be set in environment" >&2
  exit 1
fi

mkdir -p "$TMPDIR"
cd "$TMPDIR"

echo "Creating tar.gz of world dir: $WORLD_DIR"
tar -czf "$ARCHIVE_NAME" -C "$(dirname "$WORLD_DIR")" "$(basename "$WORLD_DIR")"
ARCHIVE_SIZE=$(stat -c%s "$ARCHIVE_NAME")
echo "Archive created: $ARCHIVE_NAME (${ARCHIVE_SIZE} bytes)"

echo "Splitting into chunks of ${CHUNK_SIZE}..."
split -b "$CHUNK_SIZE" -a 3 --numeric-suffixes=0 "$ARCHIVE_NAME" "${ARCHIVE_NAME}.part-"
ls -lh

# Prepare list of parts
parts=( $(ls -1 ${ARCHIVE_NAME}.part-* | sort) )
if [ ${#parts[@]} -eq 0 ]; then
  echo "No parts created. Exiting." >&2
  exit 1
fi

# Upload each part to GitHub via Contents API (create new file under backups/<timestamp>/)
upload_file() {
  local file="$1"
  local remote_path="$2" # e.g. backups/2025.../part-000
  echo "Uploading $file -> $remote_path"
  content_base64=$(base64 -w 0 "$file")
  data=$(jq -n --arg msg "backup $TIMESTAMP $file" --arg content "$content_base64" --arg branch "main" \
        '{message:$msg,content:$content,branch:$branch}')
  curl -s -X PUT \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/${GITHUB_REPO}/contents/${remote_path} \
    -d "$data" | jq -r '.commit.sha // .message'
}

echo "Uploading parts to repo ${GITHUB_REPO} under ${REMOTE_BASE_PATH}/"
for p in "${parts[@]}"; do
  filename="$(basename "$p")"
  remote_path="${REMOTE_BASE_PATH}/${filename}"
  upload_file "$p" "$remote_path" || echo "upload of $p failed"
done

# Create manifest
jq -n --arg ts "$TIMESTAMP" --arg arch "$ARCHIVE_NAME" --argjson size "$ARCHIVE_SIZE" \
  --arg repo "$GITHUB_REPO" --arg basepath "$REMOTE_BASE_PATH" \
  '{timestamp:$ts,archive:$arch,archive_size:$size,repo:$repo,basepath:$basepath,parts:[]}' > $MANIFEST

for p in "${parts[@]}"; do
  fname="$(basename "$p")"
  fsize=$(stat -c%s "$p")
  jq --arg fn "$fname" --argjson s "$fsize" '.parts += [{"file":$fn,"size":$s}]' $MANIFEST > ${MANIFEST}.tmp && mv ${MANIFEST}.tmp $MANIFEST
done

# Upload manifest
upload_file "$MANIFEST" "${REMOTE_BASE_PATH}/${MANIFEST}" || echo "manifest upload failed"

echo "Backup complete. Cleaning up local tmp files."
cd /
rm -rf "$TMPDIR"

echo "Backup finished: $TIMESTAMP"
