#!/usr/bin/env bash
set -euo pipefail

REPLIT_FILE=".replit"
SERVER="artifacts/dik-meme-site/site/server.js"

if [ ! -f "$REPLIT_FILE" ]; then
  echo "ERROR: .replit not found. Run from the existing Replit workspace root."
  exit 1
fi
if [ ! -f "$SERVER" ]; then
  echo "ERROR: $SERVER not found."
  exit 1
fi

BACKUP=".giga-cat-publishing-v17-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$REPLIT_FILE" "$BACKUP/.replit"

python3 - <<'PY'
from pathlib import Path
import re

p = Path('.replit')
s = p.read_text(encoding='utf-8')

section_re = re.compile(r'(?ms)^\[deployment\]\s*\n(.*?)(?=^\[[^\n]+\]\s*$|\Z)')
m = section_re.search(s)
if not m:
    raise SystemExit('ERROR: [deployment] section not found in .replit')

body = m.group(1)
lines = body.splitlines()
out = []
for line in lines:
    stripped = line.strip()
    # Artifact-router mode is what lets the monorepo choose other services.
    # For this published app we want one deterministic entrypoint only.
    if re.match(r'^router\s*=', stripped):
        continue
    if re.match(r'^run\s*=', stripped):
        continue
    out.append(line)

# Insert deterministic production entrypoint immediately after [deployment].
run_line = 'run = ["node", "artifacts/dik-meme-site/site/server.js"]'
new_body = run_line + '\n' + '\n'.join(out).lstrip('\n')
new_section = '[deployment]\n' + new_body.rstrip() + '\n\n'
s = s[:m.start()] + new_section + s[m.end():].lstrip('\n')
p.write_text(s, encoding='utf-8')
PY

# Validate TOML syntax using Python stdlib.
python3 - <<'PY'
import tomllib
from pathlib import Path
with Path('.replit').open('rb') as f:
    data = tomllib.load(f)
d = data.get('deployment', {})
expected = ['node', 'artifacts/dik-meme-site/site/server.js']
if d.get('run') != expected:
    raise SystemExit(f"ERROR: deployment.run is {d.get('run')!r}, expected {expected!r}")
if 'router' in d:
    raise SystemExit('ERROR: deployment.router still present')
print('REPLIT_CONFIG_OK')
print('deploymentTarget =', d.get('deploymentTarget'))
print('deployment.run =', d.get('run'))
PY

# Confirm the healthcheck patch is actually present in the server file.
grep -q "pathname === '/api'" "$SERVER" || {
  echo "ERROR: /api healthcheck fix is not present in $SERVER"
  echo "Install Giga-Cat-Replit-Healthcheck-Fix-v16 first."
  exit 1
}

echo
echo "GIGA CAT Publishing Entrypoint Fix v17 installed successfully."
echo "Backup: $BACKUP"
echo
echo "Fixed:"
echo "  - Publishing now runs ONLY: node artifacts/dik-meme-site/site/server.js"
echo "  - Removed deployment router=application so another workspace artifact cannot own production"
echo "  - Kept your existing deploymentTarget and postBuild settings"
echo "  - Did not change the Run button/workflows"
echo "  - Did not restart any process"
echo
echo "Next: commit/push .replit and server.js, then Republish."
