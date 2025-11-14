#!/usr/bin/env bash
set -euo pipefail

BACKUP_INTERVAL_SECONDS="${BACKUP_INTERVAL_SECONDS:-86400}"
WORLD_DIR="${WORLD_DIR:-/server/worlds}"

while true; do
  if [ ! -d "$WORLD_DIR" ]; then
    echo "World does not exist yet, waiting..."
    sleep "$BACKUP_INTERVAL_SECONDS"
    continue
  fi

  echo "$(date -Is) Starting periodic backup..."
  ./backup.sh || echo "backup failed"

  echo "$(date -Is) Sleeping $BACKUP_INTERVAL_SECONDS seconds until next backup..."
  sleep "$BACKUP_INTERVAL_SECONDS"
done
