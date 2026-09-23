#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"
ASSETS="$TARGET/assets"
BACKUP="$(ls -dt .giga-cat-3dcoin-v17-backup-* 2>/dev/null | head -n 1 || true)"

if [ -z "$BACKUP" ] || [ ! -f "$BACKUP/index.html" ]; then
  echo "ERROR: no GIGA CAT 3D Coin v17 backup found."
  exit 1
fi

cp "$BACKUP/index.html" "$INDEX"

FILES=(
  "gigacat-coin-front.png"
  "gigacat-coin-back.png"
  "gigacat-coin-3d.css"
  "gigacat-coin-3d.js"
)

for name in "${FILES[@]}"; do
  if [ -f "$BACKUP/.new-$name" ]; then
    rm -f "$ASSETS/$name"
  elif [ -f "$BACKUP/assets/$name" ]; then
    cp "$BACKUP/assets/$name" "$ASSETS/$name"
  fi
done

echo "Restored GIGA CAT state from: $BACKUP"
echo "No server restart was performed."
