#!/usr/bin/env bash
set -euo pipefail

PATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"
ASSETS="$TARGET/assets"
CSS_NAME="gigacat-bottom-stats-v21.css"
CSS="$ASSETS/$CSS_NAME"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing GIGA CAT Replit workspace root."
  exit 1
fi

mkdir -p "$ASSETS"
BACKUP=".giga-cat-bottom-stats-v21-backup-$(date +%Y%m%d-%H%M%S)"
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

# Idempotent V21 stylesheet reference.
html = re.sub(r'\s*<link[^>]*data-gigacat-bottom-stats-v21=["\']css["\'][^>]*>\s*', '\n', html, flags=re.I)
link = '<link rel="stylesheet" href="assets/gigacat-bottom-stats-v21.css?v=21" data-gigacat-bottom-stats-v21="css" />'
if "</head>" not in html:
    raise SystemExit("ERROR: </head> not found in index.html")
html = html.replace("</head>", f"  {link}\n</head>", 1)

# Ensure the holders stat has an icon container class the CSS can target.
# Do not change live values.
required = ['token-stats-row', 'token-stat', 'token-stat-top', 'token-stat-value', 'social-row']
for needle in required:
    if needle not in html:
        raise SystemExit(f"ERROR: expected current selector/content missing: {needle}")

marker = '<!-- GIGA_BOTTOM_STATS_V21 -->'
if marker not in html:
    html = html.replace('<body>', '<body>\n  ' + marker, 1)

p.write_text(html, encoding='utf-8')
print('HTML_PATCH_OK')
PY

grep -q 'GIGA_BOTTOM_STATS_V21' "$INDEX"
grep -q 'gigacat-bottom-stats-v21.css?v=21' "$INDEX"
grep -q 'token-stat:nth-child(2) .token-stat-top::after' "$CSS"
grep -q 'order: 50' "$CSS"

echo
echo "GIGA CAT Bottom Stats v21 installed successfully."
echo "Backup: $BACKUP"
echo
echo "Changes:"
echo "  - MC/value moved to the bottom left, above X/TWITTER"
echo "  - holders icon + HOLDERS + value moved to the bottom right, above DEXSCREENER"
echo "  - stats typography now matches the social-link scale and tone"
echo "  - MC letters and holders icon/label remain gold"
echo "  - 3D coin, title, MINT and social links remain intact"
echo
echo "No server restart was performed."
echo
echo "Rollback:"
echo "  bash Giga-Cat-Bottom-Stats-Patch-v21/restore-latest.sh"
