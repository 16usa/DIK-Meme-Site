#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing Replit workspace root."
  exit 1
fi

BACKUP=".giga-cat-gold-fullscreen-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$INDEX" "$BACKUP/index.html"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text()

marker_start = "<!-- GIGA_GOLD_FULLSCREEN_OVERRIDES_START -->"
marker_end = "<!-- GIGA_GOLD_FULLSCREEN_OVERRIDES_END -->"

override_block = f"""
{marker_start}
<style id="giga-gold-fullscreen-overrides">
  html, body {{
    min-height: 100%;
    background: #070707 !important;
  }}

  body {{
    overflow-x: hidden;
  }}

  .buy.section {{
    min-height: 100svh !important;
    display: flex !important;
    align-items: stretch !important;
    justify-content: center !important;
    padding: 10px !important;
    background: #070707 !important;
  }}

  .buy.section .wrap {{
    width: 100% !important;
    max-width: 760px !important;
    display: flex !important;
    align-items: stretch !important;
    justify-content: center !important;
  }}

  .buy-panel.reveal {{
    width: min(96vw, 740px) !important;
    min-height: calc(100svh - 20px) !important;
    margin: 0 auto !important;
    border-radius: 34px !important;
    overflow: hidden !important;
    display: flex !important;
    flex-direction: column !important;
    justify-content: flex-end !important;
    padding: 32px !important;
    position: relative !important;
    isolation: isolate !important;
    border: 1px solid rgba(255, 223, 157, 0.16) !important;
    box-shadow:
      inset 0 1px 0 rgba(255, 242, 214, 0.14),
      0 24px 70px rgba(0, 0, 0, 0.46) !important;
    background:
      linear-gradient(180deg,
        rgba(35, 21, 4, 0.18) 0%,
        rgba(196, 144, 58, 0.18) 20%,
        rgba(27, 17, 5, 0.12) 42%,
        rgba(191, 132, 40, 0.20) 72%,
        rgba(10, 8, 6, 0.80) 100%),
      linear-gradient(135deg,
        rgba(255, 242, 214, 0.16) 0%,
        rgba(240, 188, 95, 0.22) 22%,
        rgba(133, 88, 19, 0.28) 52%,
        rgba(255, 214, 126, 0.10) 100%),
      url('assets/dik-original.png') center center / cover no-repeat !important;
  }}

  .buy-panel.reveal::before {{
    content: "" !important;
    position: absolute !important;
    inset: 0 !important;
    z-index: 0 !important;
    background:
      radial-gradient(circle at 20% 12%, rgba(255, 223, 150, 0.38), transparent 32%),
      radial-gradient(circle at 80% 14%, rgba(255, 192, 93, 0.22), transparent 28%),
      linear-gradient(180deg, rgba(255, 225, 170, 0.02), rgba(0,0,0,0.26));
    pointer-events: none !important;
  }}

  .buy-panel.reveal > * {{
    position: relative !important;
    z-index: 1 !important;
  }}

  .buy-panel.reveal .section-kicker,
  .buy-panel.reveal .mini-kicker,
  .buy-panel.reveal .links a,
  .buy-panel.reveal .copy-row,
  .buy-panel.reveal .copy-action {{
    color: rgba(255, 237, 208, 0.88) !important;
  }}

  .buy-panel.reveal .section-kicker {{
    letter-spacing: .18em !important;
  }}

  .buy-panel.reveal h2 {{
    text-shadow: 0 8px 30px rgba(0,0,0,.36) !important;
  }}

  .buy-panel.reveal .copy-shell {{
    background: rgba(20, 14, 9, 0.48) !important;
    border-color: rgba(255, 224, 168, 0.18) !important;
    box-shadow: inset 0 1px 0 rgba(255,255,255,0.04) !important;
  }}

  .buy-panel.reveal .pill,
  .buy-panel.reveal .button,
  .buy-panel.reveal .cta {{
    box-shadow: 0 8px 22px rgba(0,0,0,.22) !important;
  }}

  @media (max-width: 760px) {{
    .buy.section {{
      padding: 0 !important;
    }}

    .buy.section .wrap {{
      max-width: 100% !important;
    }}

    .buy-panel.reveal {{
      width: 100vw !important;
      min-height: 100svh !important;
      border-radius: 0 !important;
      padding: 28px 18px 22px !important;
    }}
  }}
</style>
{marker_end}
"""

# Remove old version of the same block if it exists, then reinsert.
if marker_start in html and marker_end in html:
    html = re.sub(re.escape(marker_start) + r'.*?' + re.escape(marker_end), '', html, flags=re.S)

if "</head>" in html:
    html = html.replace("</head>", override_block + "\n</head>", 1)
else:
    html = override_block + "\n" + html

p.write_text(html)
PY

echo
echo "GIGA CAT gold fullscreen patch installed successfully."
echo "Backup: $BACKUP"
echo
echo "Updated:"
echo "  - Purple fill replaced with a warm gold gradient overlay"
echo "  - Card stretched to screen height"
echo "  - Image fills the card vertically like a full-screen card"
echo
echo "No server restart was performed."
echo
grep -nE 'GIGA_GOLD_FULLSCREEN_OVERRIDES|buy-panel\.reveal|buy section' "$INDEX" || true
