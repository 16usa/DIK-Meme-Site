#!/usr/bin/env bash
set -euo pipefail
latest="$(ls -dt .giga-cat-publish-v19-backup-* 2>/dev/null | head -1 || true)"
[ -n "$latest" ] || { echo "No v19 backup found"; exit 1; }
cp "$latest/artifacts/dik-meme-site/.replit-artifact/artifact.toml" artifacts/dik-meme-site/.replit-artifact/artifact.toml
cp "$latest/artifacts/api-server/.replit-artifact/artifact.toml" artifacts/api-server/.replit-artifact/artifact.toml
rm -f artifacts/api-server/.replit-artifact/artifact.toml.disabled-v19
echo "Restored from $latest"
