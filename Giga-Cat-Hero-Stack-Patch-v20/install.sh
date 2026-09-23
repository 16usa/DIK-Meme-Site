#!/usr/bin/env bash
set -euo pipefail

PATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"
ASSETS="$TARGET/assets"
CSS_NAME="gigacat-hero-stack-v20.css"
CSS="$ASSETS/$CSS_NAME"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing GIGA CAT Replit workspace root."
  exit 1
fi

mkdir -p "$ASSETS"
BACKUP=".giga-cat-hero-stack-v20-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP/assets"
cp "$INDEX" "$BACKUP/index.html"
if [ -f "$CSS" ]; then
  cp "$CSS" "$BACKUP/assets/$CSS_NAME"
else
  touch "$BACKUP/.new-$CSS_NAME"
fi

cp "$PATCH_DIR/payload/$CSS_NAME" "$CSS"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text(encoding="utf-8")

# Remove any uninstalled/partial V19 references so V20 is the only layout owner.
html = re.sub(r'\s*<link[^>]*gigacat-hero-layout-v19\.css[^>]*>\s*', '\n', html, flags=re.I)
html = re.sub(r'\s*<script[^>]*gigacat-hero-layout-v19\.js[^>]*></script>\s*', '\n', html, flags=re.I)

# Idempotent V20 stylesheet reference.
html = re.sub(r'\s*<link[^>]*data-gigacat-hero-stack-v20=["\']css["\'][^>]*>\s*', '\n', html, flags=re.I)
link = '<link rel="stylesheet" href="assets/gigacat-hero-stack-v20.css?v=20" data-gigacat-hero-stack-v20="css" />'
if "</head>" not in html:
    raise SystemExit("ERROR: </head> not found in index.html")
html = html.replace("</head>", f"  {link}\n</head>", 1)

# Make the visible title actual uppercase text, not only CSS-transform.
h2_pattern = re.compile(r'(<h2\b[^>]*>)(.*?)(</h2>)', re.I | re.S)
replaced_title = False

def title_repl(m):
    global replaced_title
    inner = m.group(2)
    plain = re.sub(r'<[^>]+>', '', inner)
    if 'gigacat' in re.sub(r'\s+', '', plain).lower():
        replaced_title = True
        return m.group(1) + '$GIGACAT' + m.group(3)
    return m.group(0)

html = h2_pattern.sub(title_repl, html)
if not replaced_title:
    raise SystemExit("ERROR: GigaCat <h2> title not found; no files were finalized")

# Make the existing contract label read MINT. Preserve the existing address and copy behavior.
label_pattern = re.compile(r'(<span\b[^>]*class=["\'][^"\']*\bcontract-label\b[^"\']*["\'][^>]*>)(.*?)(</span>)', re.I | re.S)
if label_pattern.search(html):
    html = label_pattern.sub(lambda m: m.group(1) + 'MINT' + m.group(3), html, count=1)
else:
    button_pattern = re.compile(r'(<button\b[^>]*class=["\'][^"\']*\bcontract\b[^"\']*["\'][^>]*>)', re.I | re.S)
    if not button_pattern.search(html):
        raise SystemExit("ERROR: contract button not found")
    html = button_pattern.sub(r'\1\n            <span class="contract-label">MINT</span>', html, count=1)

# Normalize the copy label without touching the button's click handler.
copy_pattern = re.compile(r'(<span\b[^>]*class=["\'][^"\']*\bcontract-copy\b[^"\']*["\'][^>]*>)(.*?)(</span>)', re.I | re.S)
if copy_pattern.search(html):
    html = copy_pattern.sub(lambda m: m.group(1) + 'COPY' + m.group(3), html, count=1)

marker = '<!-- GIGA_HERO_STACK_V20 -->'
if marker not in html:
    html = html.replace('<body>', '<body>\n  ' + marker, 1)

# Baseline selector checks. These protect the user from applying to the wrong site snapshot.
required = [
    'token-stats-row',
    'token-stat',
    'coin-mark',
    'contract-value',
    'contract-copy',
    '$GIGACAT',
]
for needle in required:
    if needle not in html:
        raise SystemExit(f"ERROR: expected current GIGA CAT selector/content missing: {needle}")

p.write_text(html, encoding="utf-8")
print("HTML_PATCH_OK")
PY

# Validation only; no server/process restart.
grep -q 'GIGA_HERO_STACK_V20' "$INDEX"
grep -q 'gigacat-hero-stack-v20.css?v=20' "$INDEX"
grep -q '\$GIGACAT' "$INDEX"
grep -q '>MINT<' "$INDEX"
grep -q 'official-brand-row' "$CSS"
grep -q 'flex-direction: column' "$CSS"
grep -q 'rotateX(0deg) rotateY(0deg)' "$CSS"

echo
echo "GIGA CAT Hero Stack v20 installed successfully."
echo "Backup: $BACKUP"
echo
echo "One patch applied all requested layout changes:"
echo "  - MC moved to the top as MC + value"
echo "  - holders moved below as icon + value (icon on the LEFT)"
echo "  - interactive 3D coin remains below the stats"
echo "  - four ecosystem icons beneath the coin are hidden"
echo "  - title is now exactly \$GIGACAT"
echo "  - MINT + address + COPY is frameless and transparent"
echo "  - 3D coin starts level; touch/inertia/idle rotation are not disabled"
echo "  - existing live MC / holders logic is untouched"
echo
echo "No server restart was performed."
echo
echo "Rollback:"
echo "  bash Giga-Cat-Hero-Stack-Patch-v20/restore-latest.sh"
