#!/usr/bin/env bash
set -euo pipefail

BEDROCK_BIN="${BEDROCK_BIN:-/server/bedrock_server}"
WORLD_DIR="${WORLD_DIR:-/server/worlds}"
CRASH_RESTARTS="${CRASH_RESTARTS:-5}"
RESTART_DELAY="${RESTART_DELAY:-5}"

if [ ! -x "$BEDROCK_BIN" ]; then
  echo "Bedrock binary not found or not executable at $BEDROCK_BIN"
  exit 1
fi

restart_count=0
while true; do
  echo "Starting bedrock server (attempt $((restart_count+1)))..."
  # run in foreground so we can detect exit status
  "$BEDROCK_BIN" &
  server_pid=$!
  wait $server_pid
  exit_code=$?
  echo "Bedrock server exited with code $exit_code"
  # trigger an immediate backup on crash (best-effort)
  if [ -x ./backup.sh ]; then
    echo "Triggering immediate backup after crash..."
    ./backup.sh || echo "backup.sh returned non-zero"
  fi
  restart_count=$((restart_count+1))
  if [ "$restart_count" -ge "$CRASH_RESTARTS" ]; then
    echo "Reached max restarts ($CRASH_RESTARTS). Exiting."
    break
  fi
  echo "Sleeping $RESTART_DELAY seconds before restart..."
  sleep "$RESTART_DELAY"
done
