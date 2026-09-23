#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
SERVER="$TARGET/server.js"

if [ ! -f "$SERVER" ]; then
  echo "ERROR: $SERVER not found."
  echo "Run this from the existing Replit workspace root."
  exit 1
fi

BACKUP=".giga-cat-healthcheck-v16-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$SERVER" "$BACKUP/server.js"

python3 - <<'PY'
from pathlib import Path

p = Path("artifacts/dik-meme-site/site/server.js")
s = p.read_text()

needle = """const server = http.createServer((req, res) => {
  let pathname = decodeURIComponent((req.url || '/').split('?')[0]);
"""

replacement = """const server = http.createServer((req, res) => {
  let pathname = decodeURIComponent((req.url || '/').split('?')[0]);

  // Replit deployment health checks may probe /api.
  // Return a lightweight 200 so the deployment is considered healthy.
  if (pathname === '/api' || pathname === '/health' || pathname === '/healthz') {
    res.writeHead(200, {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store'
    });
    res.end(JSON.stringify({ ok: true, service: 'giga-cat' }));
    return;
  }
"""

if "pathname === '/api'" not in s:
    if needle not in s:
        raise SystemExit("ERROR: could not find server request handler to patch")
    s = s.replace(needle, replacement, 1)

p.write_text(s)
PY

echo
echo "GIGA CAT Replit healthcheck fix v16 installed successfully."
echo "Backup: $BACKUP"
echo
echo "Fixed:"
echo "  - /api now returns HTTP 200"
echo "  - /health now returns HTTP 200"
echo "  - /healthz now returns HTTP 200"
echo "  - Normal website/static file routing stays unchanged"
echo
echo "No server restart was performed."
echo
grep -nE "pathname === '/api'|pathname === '/health'|pathname === '/healthz'" "$SERVER" || true
