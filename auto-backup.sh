#!/usr/bin/env bash
set -euo pipefail
BACKUP_INTERVAL_SECONDS="${BACKUP_INTERVAL_SECONDS:-86400}"
while true; do
  echo "$(date -Is) Starting periodic backup..."
  ./backup.sh || echo "backup failed"
  echo "$(date -Is) Sleeping $BACKUP_INTERVAL_SECONDS seconds until next backup..."
  sleep "$BACKUP_INTERVAL_SECONDS"
done
