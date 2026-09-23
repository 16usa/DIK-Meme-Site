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

BACKUP=".giga-cat-minimal-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$INDEX" "$BACKUP/index.html"

mkdir -p "$ASSET_DIR"
cp -f "Giga-Cat-Minimal-Patch-v3/payload/artifacts/dik-meme-site/site/assets/giga-original-photo.jpg" \
      "$ASSET_DIR/giga-original-photo.jpg"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text()

def add_hidden_to_class(html, tag, class_name):
    # Idempotently adds hidden to an opening tag that has the requested class.
    pattern = rf'<{tag}\b([^>]*\bclass="{re.escape(class_name)}"[^>]*)>'
    def repl(m):
        attrs = m.group(1)
        if re.search(r'\bhidden\b', attrs):
            return m.group(0)
        return f'<{tag}{attrs} hidden>'
    return re.sub(pattern, repl, html, count=1)

# Keep the header + the essential buy/info block only.
for tag, cls in [
    ("section", "hero"),
    ("section", "story section"),
    ("section", "life section"),
    ("section", "meme-banner"),
]:
    html = add_hidden_to_class(html, tag, cls)

# Hide the now-unused middle navigation, but keep the header/brand and Buy button.
html = add_hidden_to_class(html, "nav", "nav")

# Hide footer for the temporary minimal version.
if "<footer hidden>" not in html:
    html = re.sub(r'<footer\b([^>]*)>', lambda m: '<footer' + m.group(1) + ' hidden>', html, count=1)

# Replace the circular GIGA text coin with the real/original cat photo.
coin_re = r'<div class="coin-mark"[^>]*>.*?</div>'
coin_new = (
    '<div class="coin-mark" style="overflow:hidden;padding:0;background:#0b0b0d;">'
    '<img src="assets/giga-original-photo.jpg" '
    'alt="GIGA CAT original photo" '
    'style="width:100%;height:100%;object-fit:cover;border-radius:50%;display:block;" />'
    '</div>'
)
html = re.sub(coin_re, coin_new, html, count=1, flags=re.S)

# Put the existing GIGA CAT avatar/artwork softly in the background of the retained panel.
panel_pattern = r'<div class="buy-panel reveal"(?:\s+style="[^"]*")?>'
panel_new = (
    '<div class="buy-panel reveal" '
    'style="background:linear-gradient(rgba(7,7,7,.72),rgba(7,7,7,.90)),'
    'url(\'assets/dik-original.png\') center/cover no-repeat;">'
)
html = re.sub(panel_pattern, panel_new, html, count=1)

# Mark the minimized version so it is easy to recognize later.
marker = '<!-- GIGA_CAT_MINIMAL_MODE_V3 -->'
if marker not in html:
    html = html.replace('<body>', '<body>\n  ' + marker, 1)

p.write_text(html)
PY

echo
echo "GIGA CAT minimal patch installed successfully."
echo "Backup: $BACKUP"
echo
echo "Visible now:"
echo "  - Header"
echo "  - GIGA CAT / Find GIGA CAT on Pump.fun block"
echo "  - Original cat photo inside the round avatar"
echo "  - Pump.fun / contract / X / Dex links"
echo
echo "Temporarily hidden (NOT deleted):"
echo "  - Hero"
echo "  - Story"
echo "  - Life scenes"
echo "  - Meme section"
echo "  - Footer"
echo
echo "Background uses the existing GIGA CAT avatar artwork."
echo "No server restart was performed."
echo
grep -nE 'GIGA_CAT_MINIMAL_MODE|giga-original-photo|buy-panel reveal|section class="(hero|story|life|meme-banner)' "$INDEX" || true
