#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site/index.html"
LATEST="$(ls -dt .giga-cat-stats-backup-* 2>/dev/null | head -n 1 || true)"

if [ -z "$LATEST" ] || [ ! -f "$LATEST/index.html" ]; then
  echo "No GIGA CAT stats backup found."
  exit 1
fi

cp "$LATEST/index.html" "$TARGET"
echo "Restored index.html from: $LATEST"
echo "No server restart was performed."
