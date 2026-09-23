#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"
ASSETS="$TARGET/assets"
CSS_NAME="gigacat-hero-stack-v20.css"

latest="$(ls -dt .giga-cat-hero-stack-v20-backup-* 2>/dev/null | head -n 1 || true)"
if [ -z "$latest" ]; then
  echo "ERROR: no GIGA CAT Hero Stack v20 backup found."
  exit 1
fi

cp "$latest/index.html" "$INDEX"
if [ -f "$latest/.new-$CSS_NAME" ]; then
  rm -f "$ASSETS/$CSS_NAME"
elif [ -f "$latest/assets/$CSS_NAME" ]; then
  cp "$latest/assets/$CSS_NAME" "$ASSETS/$CSS_NAME"
fi

echo "Restored: $latest"
echo "No server restart was performed."
