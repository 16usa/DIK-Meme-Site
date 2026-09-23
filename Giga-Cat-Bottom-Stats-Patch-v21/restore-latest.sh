#!/usr/bin/env bash
set -euo pipefail
latest="$(ls -dt .giga-cat-bottom-stats-v21-backup-* 2>/dev/null | head -1 || true)"
[ -n "$latest" ] || { echo "No v21 backup found"; exit 1; }
cp "$latest/index.html" artifacts/dik-meme-site/site/index.html
if [ -f "$latest/assets/gigacat-bottom-stats-v21.css" ]; then
  cp "$latest/assets/gigacat-bottom-stats-v21.css" artifacts/dik-meme-site/site/assets/gigacat-bottom-stats-v21.css
else
  rm -f artifacts/dik-meme-site/site/assets/gigacat-bottom-stats-v21.css
fi
echo "Restored from $latest"
