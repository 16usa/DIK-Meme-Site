#!/usr/bin/env bash
set -euo pipefail

PATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"
ASSETS="$TARGET/assets"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing GIGA CAT Replit workspace root."
  exit 1
fi

mkdir -p "$ASSETS"
BACKUP=".giga-cat-3dcoin-v17-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP/assets"
cp "$INDEX" "$BACKUP/index.html"

FILES=(
  "gigacat-coin-front.png"
  "gigacat-coin-back.png"
  "gigacat-coin-3d.css"
  "gigacat-coin-3d.js"
)

for name in "${FILES[@]}"; do
  if [ -f "$ASSETS/$name" ]; then
    cp "$ASSETS/$name" "$BACKUP/assets/$name"
  else
    touch "$BACKUP/.new-$name"
  fi
  cp "$PATCH_DIR/payload/$name" "$ASSETS/$name"
done

python3 - <<'PY'
from pathlib import Path
import re

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text(encoding="utf-8")

CSS = '<link rel="stylesheet" href="assets/gigacat-coin-3d.css?v=17" data-giga-3dcoin-v17="style" />'
JS = '<script src="assets/gigacat-coin-3d.js?v=17" defer data-giga-3dcoin-v17="script"></script>'
CONTENT = '''<!-- GIGA_3D_COIN_V17 -->
        <div class="giga-coin3d" id="gigaCoin3d" tabindex="0" role="img" aria-label="Interactive double-sided 3D Giga Cat coin. Drag to rotate; press Enter to flip.">
          <div class="giga-coin3d-object" aria-hidden="true">
            <div class="giga-coin3d-face giga-coin3d-front"><img src="assets/gigacat-coin-front.png" alt="" draggable="false" /></div>
            <div class="giga-coin3d-face giga-coin3d-back"><img src="assets/gigacat-coin-back.png" alt="" draggable="false" /></div>
          </div>
        </div>'''

# Remove older v17 references so reinstall is idempotent.
html = re.sub(r'\s*<link[^>]*data-giga-3dcoin-v17=["\']style["\'][^>]*>\s*', '\n', html)
html = re.sub(r'\s*<script[^>]*data-giga-3dcoin-v17=["\']script["\'][^>]*></script>\s*', '\n', html)

if "</head>" not in html:
    raise SystemExit("ERROR: </head> not found in index.html")
html = html.replace("</head>", f"  {CSS}\n</head>", 1)

if "</body>" not in html:
    raise SystemExit("ERROR: </body> not found in index.html")
html = html.replace("</body>", f"  {JS}\n</body>", 1)

# Locate the first .coin-mark DIV and replace its complete inner HTML using a
# depth-aware scan, so this works whether the current avatar contains text,
# an <img>, or nested wrapper elements from earlier GIGA CAT patches.
open_re = re.compile(
    r'<div\b[^>]*\bclass\s*=\s*(["\'])[^"\']*\bcoin-mark\b[^"\']*\1[^>]*>',
    re.I | re.S,
)
m = open_re.search(html)
if not m:
    raise SystemExit("ERROR: .coin-mark avatar container not found in index.html")

start_inner = m.end()
token_re = re.compile(r'<div\b[^>]*>|</div\s*>', re.I | re.S)
depth = 1
end_inner = None
closing_end = None
for tok in token_re.finditer(html, start_inner):
    text = tok.group(0).lower()
    if text.startswith('<div'):
        depth += 1
    else:
        depth -= 1
        if depth == 0:
            end_inner = tok.start()
            closing_end = tok.end()
            break

if end_inner is None:
    raise SystemExit("ERROR: could not find closing </div> for .coin-mark")

html = html[:start_inner] + "\n        " + CONTENT + "\n      " + html[end_inner:]

# Sanity checks before writing.
checks = [
    'id="gigaCoin3d"',
    'gigacat-coin-front.png',
    'gigacat-coin-back.png',
    'gigacat-coin-3d.css?v=17',
    'gigacat-coin-3d.js?v=17',
]
for needle in checks:
    if html.count(needle) != 1:
        raise SystemExit(f"ERROR: expected exactly one {needle!r}, found {html.count(needle)}")

p.write_text(html, encoding="utf-8")
PY

# Basic local validation; no server/process restart is performed.
python3 - <<'PY'
from pathlib import Path
p = Path("artifacts/dik-meme-site/site/index.html")
s = p.read_text(encoding="utf-8")
for needle in (
    'id="gigaCoin3d"',
    'assets/gigacat-coin-front.png',
    'assets/gigacat-coin-back.png',
    'assets/gigacat-coin-3d.css?v=17',
    'assets/gigacat-coin-3d.js?v=17',
):
    assert needle in s, needle
print("HTML_OK")
PY

if command -v node >/dev/null 2>&1; then
  node --check "$ASSETS/gigacat-coin-3d.js"
  echo "JS_OK"
fi

echo
echo "GIGA CAT Interactive 3D Coin v17 installed successfully."
echo "Backup: $BACKUP"
echo
echo "Changed only:"
echo "  - Existing round avatar replaced with one double-sided 3D coin module"
echo "  - Front = Giga Cat relief"
echo "  - Back = reverse Giga Cat relief"
echo "  - Finger/mouse drag rotates the coin 360 degrees"
echo "  - Release keeps natural inertia; idle mode turns slowly"
echo "  - Gold highlight moves with rotation"
echo "  - No extra coin inscriptions were added"
echo "  - Existing site content / holder logic / server routing untouched"
echo
echo "No server restart was performed."
echo
echo "Rollback:"
echo "  bash Giga-Cat-Interactive-3D-Coin-Patch-v17/restore-latest.sh"
