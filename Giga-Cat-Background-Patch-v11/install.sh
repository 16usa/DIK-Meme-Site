#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"
ASSET_DIR="$TARGET/assets"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing Replit workspace root."
  exit 1
fi

BACKUP=".giga-cat-background-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$INDEX" "$BACKUP/index.html"

mkdir -p "$ASSET_DIR"
cp -f "Giga-Cat-Background-Patch-v11/payload/artifacts/dik-meme-site/site/assets/giga-card-bg-space-v11.jpg" \
      "$ASSET_DIR/giga-card-bg-space-v11.jpg"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text()

new_asset = "assets/giga-card-bg-space-v11.jpg"

# Replace any existing background url on the visible buy panel/card.
html = re.sub(
    r"url\(['\"]assets/[^'\"]+['\"]\)\s*center(?:\s+center)?\s*/\s*cover\s*no-repeat",
    f"url('{new_asset}') center center / cover no-repeat",
    html,
    count=1
)

# Fallback replacements if the exact pattern differs.
html = html.replace("url('assets/dik-original.png')", f"url('{new_asset}')")
html = html.replace('url("assets/dik-original.png")', f'url("{new_asset}")')
html = html.replace("url('assets/giga-card-space-solana.jpg')", f"url('{new_asset}')")
html = html.replace('url("assets/giga-card-space-solana.jpg")', f'url("{new_asset}")')

# Make sure the main visible card uses the new asset even if inline style exists.
html = re.sub(
    r'(<div class="buy-panel reveal"[^>]*style="[^"]*url\()[^)]*(\)[^"]*")',
    r"\1'" + new_asset + r"'\2",
    html,
    count=1
)

marker = "<!-- GIGA_CARD_BACKGROUND_V11 -->"
if marker not in html:
    html = html.replace("<body>", "<body>\n  " + marker, 1)

p.write_text(html)
PY

echo
echo "GIGA CAT background patch installed successfully."
echo "Backup: $BACKUP"
echo
echo "Updated:"
echo "  - Replaced the big card background image"
echo "  - Used the new space / Solana / Giga Cat scene"
echo "  - Kept the existing gradient overlay on top"
echo "  - Stored new asset as: assets/giga-card-bg-space-v11.jpg"
echo
echo "No server restart was performed."
echo
grep -nE 'GIGA_CARD_BACKGROUND_V11|giga-card-bg-space-v11|buy-panel reveal' "$INDEX" | head -n 50 || true
