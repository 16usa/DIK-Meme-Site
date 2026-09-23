#!/usr/bin/env bash
set -euo pipefail
latest="$(ls -dt .giga-cat-publishing-v17-backup-* 2>/dev/null | head -1 || true)"
[ -n "$latest" ] || { echo "No v17 backup found"; exit 1; }
cp "$latest/.replit" .replit
echo "Restored .replit from $latest"
