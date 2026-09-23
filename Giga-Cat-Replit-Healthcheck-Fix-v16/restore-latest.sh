#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site/server.js"
LATEST="$(ls -dt .giga-cat-healthcheck-v16-backup-* 2>/dev/null | head -n 1 || true)"

if [ -z "$LATEST" ] || [ ! -f "$LATEST/server.js" ]; then
  echo "No GIGA CAT healthcheck v16 backup found."
  exit 1
fi

cp "$LATEST/server.js" "$TARGET"
echo "Restored server.js from: $LATEST"
echo "No server restart was performed."
