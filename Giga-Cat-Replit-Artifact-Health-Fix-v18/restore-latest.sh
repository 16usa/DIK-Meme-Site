#!/usr/bin/env bash
set -euo pipefail
latest="$(ls -dt .giga-cat-artifact-health-v18-backup-* 2>/dev/null | head -1 || true)"
[ -n "$latest" ] || { echo "No v18 backup found"; exit 1; }
cp "$latest/artifacts/api-server/.replit-artifact/artifact.toml" artifacts/api-server/.replit-artifact/artifact.toml
cp "$latest/artifacts/api-server/src/routes/health.ts" artifacts/api-server/src/routes/health.ts
echo "Restored from $latest"
