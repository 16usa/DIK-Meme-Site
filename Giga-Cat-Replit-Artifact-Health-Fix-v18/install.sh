#!/usr/bin/env bash
set -euo pipefail

ARTIFACT_CFG="artifacts/api-server/.replit-artifact/artifact.toml"
HEALTH_TS="artifacts/api-server/src/routes/health.ts"

if [ ! -f "$ARTIFACT_CFG" ] || [ ! -f "$HEALTH_TS" ]; then
  echo "ERROR: GigaCat Replit API artifact files not found."
  echo "Run from the existing Replit workspace root."
  exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP=".giga-cat-artifact-health-v18-backup-$STAMP"
mkdir -p "$BACKUP/artifacts/api-server/.replit-artifact" "$BACKUP/artifacts/api-server/src/routes"
cp "$ARTIFACT_CFG" "$BACKUP/$ARTIFACT_CFG"
cp "$HEALTH_TS" "$BACKUP/$HEALTH_TS"

python3 - <<'PY'
from pathlib import Path

cfg = Path("artifacts/api-server/.replit-artifact/artifact.toml")
s = cfg.read_text(encoding="utf-8")
old = 'previewPath = "/api"'
new = 'previewPath = "/api/healthz"'
if old in s:
    s = s.replace(old, new, 1)
elif new not in s:
    raise SystemExit("ERROR: expected previewPath entry not found")
cfg.write_text(s, encoding="utf-8")

p = Path("artifacts/api-server/src/routes/health.ts")
s = p.read_text(encoding="utf-8")
needle = 'const router: IRouter = Router();\n'
route = '''\n// Replit may probe the API artifact root (/api) in addition to /api/healthz.\n// Because this router is mounted at /api, "/" must return 200 as well.\nrouter.get("/", (_req, res) => {\n  const data = HealthCheckResponse.parse({ status: "ok" });\n  res.json(data);\n});\n'''
if 'router.get("/", (_req, res)' not in s:
    if needle not in s:
        raise SystemExit("ERROR: health router declaration not found")
    s = s.replace(needle, needle + route, 1)
p.write_text(s, encoding="utf-8")
PY

# Validate only. No process/server restart.
grep -q 'previewPath = "/api/healthz"' "$ARTIFACT_CFG"
grep -q 'router.get("/", (_req, res)' "$HEALTH_TS"
grep -q 'path = "/api/healthz"' "$ARTIFACT_CFG"

echo
echo "GIGA CAT Replit Artifact Health Fix v18 installed successfully."
echo "Backup: $BACKUP"
echo
echo "Fixed the actual Replit artifact configuration:"
echo "  - API artifact previewPath: /api -> /api/healthz"
echo "  - /api itself now also returns HTTP 200"
echo "  - existing /api/healthz remains HTTP 200"
echo "  - no server/process restart was performed"
echo
echo "Next: commit + push these 2 files, then Republish."
