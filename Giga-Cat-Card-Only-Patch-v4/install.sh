#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing Replit workspace root."
  exit 1
fi

BACKUP=".giga-cat-card-only-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$INDEX" "$BACKUP/index.html"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text()

def force_hide_opening_tag(html, tag, class_value=None):
    if class_value:
        pattern = rf'<{tag}\b([^>]*\bclass="{re.escape(class_value)}"[^>]*)>'
    else:
        pattern = rf'<{tag}\b([^>]*)>'
    def repl(m):
        attrs = m.group(1)
        # Remove any existing style attr so we can make this deterministic.
        attrs = re.sub(r'\sstyle="[^"]*"', '', attrs)
        return f'<{tag}{attrs} style="display:none !important;">'
    return re.sub(pattern, repl, html, count=1)

# Hide absolutely everything above the purple buy card.
html = force_hide_opening_tag(html, "header", "topbar")
html = force_hide_opening_tag(html, "section", "hero")
html = force_hide_opening_tag(html, "section", "story section")
html = force_hide_opening_tag(html, "section", "life section")
html = force_hide_opening_tag(html, "section", "meme-banner")

# Hide the site footer / bottom area.
html = force_hide_opening_tag(html, "footer")

# Make sure the purple buy section itself stays visible.
buy_pattern = r'<section\b([^>]*\bclass="buy section"[^>]*)>'
def show_buy(m):
    attrs = m.group(1)
    attrs = re.sub(r'\shidden\b', '', attrs)
    attrs = re.sub(r'\sstyle="[^"]*"', '', attrs)
    return f'<section{attrs}>'
html = re.sub(buy_pattern, show_buy, html, count=1)

# Also make sure its purple card is not accidentally hidden.
panel_pattern = r'<div\b([^>]*\bclass="buy-panel reveal"[^>]*)>'
def show_panel(m):
    attrs = m.group(1)
    attrs = re.sub(r'\shidden\b', '', attrs)
    return f'<div{attrs}>'
html = re.sub(panel_pattern, show_panel, html, count=1)

marker = '<!-- GIGA_CAT_CARD_ONLY_MODE_V4 -->'
if marker not in html:
    html = html.replace('<body>', '<body>\n  ' + marker, 1)

p.write_text(html)
PY

echo
echo "GIGA CAT card-only patch installed successfully."
echo "Backup: $BACKUP"
echo
echo "VISIBLE:"
echo "  - Purple GIGA CAT / Pump.fun card"
echo
echo "HIDDEN:"
echo "  - Header"
echo "  - Top GIGA hero"
echo "  - Small Cat. Big Power."
echo "  - Top Buy on Pump.fun / Copy CA"
echo "  - Story / Life / Meme sections"
echo "  - Footer / bottom of site"
echo
echo "Nothing was deleted."
echo "No CSS file was changed."
echo "No server restart was performed."
echo
grep -nE 'GIGA_CAT_CARD_ONLY_MODE|class="topbar"|class="hero"|class="buy section"|<footer' "$INDEX" || true
