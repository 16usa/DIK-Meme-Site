#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing Replit workspace root."
  exit 1
fi

BACKUP=".giga-cat-minimal-title-gold-avatar-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$INDEX" "$BACKUP/index.html"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text()

# 1) Replace title text with only $GigaCat
patterns = [
    r'Find\s*\$GigaCat\s*<br>\s*on\s*Pump\.fun\.?',
    r'Find\s*\$GigaCat\s*on\s*Pump\.fun\.?',
    r'Find\s*\$GigaCat',
    r'Find\s*GIGA\s*CAT\s*<br>\s*on\s*Pump\.fun\.?',
    r'Find\s*GIGA\s*CAT\s*on\s*Pump\.fun\.?'
]
for pat in patterns:
    html = re.sub(pat, '$GigaCat', html, flags=re.I)

# Also normalize the main heading content if wrapped strangely.
html = re.sub(
    r'(<h2[^>]*>)(.*?)(</h2>)',
    lambda m: m.group(1) + re.sub(r'Find\s*\$?GigaCat(?:\s*<br>\s*|\s+)on\s*Pump\.fun\.?', '$GigaCat', m.group(2), flags=re.I) + m.group(3),
    html,
    count=1,
    flags=re.S
)

# 2) Hide the Open Pump.fun button block/text without deleting
# Try direct button text replacement with hidden style.
html = re.sub(
    r'(<a[^>]*class="[^"]*(?:pill|button|cta)[^"]*"[^>]*>\s*OPEN\s*PUMP\.FUN\s*</a>)',
    r'<div style="display:none !important;">\1</div>',
    html,
    flags=re.I
)
html = re.sub(
    r'(<button[^>]*>\s*OPEN\s*PUMP\.FUN\s*</button>)',
    r'<div style="display:none !important;">\1</div>',
    html,
    flags=re.I
)

# Fallback: if there's a specific open pump link id, hide it by CSS later.
# 3) Add final CSS overrides.
start = "<!-- GIGA_TITLE_GOLD_AVATAR_V12_START -->"
end = "<!-- GIGA_TITLE_GOLD_AVATAR_V12_END -->"
css = """
<!-- GIGA_TITLE_GOLD_AVATAR_V12_START -->
<style id="giga-title-gold-avatar-v12">
  /* Hide main open pump button if still present */
  a[href*="pump.fun"].pill,
  a[href*="pump.fun"].button,
  a[href*="pump.fun"].cta,
  #openPumpBtn,
  #pumpLinkMain {
    display: none !important;
  }

  /* Keep the main title centered and clean */
  .buy-panel h2,
  .buy-panel .title,
  .buy-panel .hero-title {
    text-align: center !important;
    width: 100% !important;
    margin-left: auto !important;
    margin-right: auto !important;
  }

  /* Gold gradient frame around the round avatar */
  .coin-mark {
    position: relative !important;
    overflow: visible !important;
    border-radius: 999px !important;
    padding: 4px !important;
    background:
      linear-gradient(135deg,
        rgba(255, 242, 206, 1) 0%,
        rgba(236, 193, 95, 1) 22%,
        rgba(164, 112, 28, 1) 52%,
        rgba(255, 220, 142, 1) 76%,
        rgba(255, 244, 214, 1) 100%) !important;
    box-shadow:
      0 8px 22px rgba(0,0,0,.28),
      0 0 0 1px rgba(255, 233, 170, .55),
      inset 0 1px 0 rgba(255,255,255,.55) !important;
  }

  .coin-mark img,
  .coin-mark > div,
  .coin-mark > picture,
  .coin-mark > span {
    border-radius: 999px !important;
    overflow: hidden !important;
    display: block !important;
    background: #0a0a0c !important;
  }

  /* Make the avatar feel more premium */
  .coin-mark::after {
    content: "" !important;
    position: absolute !important;
    inset: 1px !important;
    border-radius: 999px !important;
    pointer-events: none !important;
    box-shadow:
      inset 0 1px 1px rgba(255,255,255,.26),
      inset 0 -10px 20px rgba(0,0,0,.08) !important;
  }

  /* Ensure heading is visually prominent after removing extra words */
  .buy-panel h2 {
    letter-spacing: -.06em !important;
    line-height: .9 !important;
  }
</style>
<!-- GIGA_TITLE_GOLD_AVATAR_V12_END -->
""".strip()

if start in html and end in html:
    html = re.sub(re.escape(start) + r'.*?' + re.escape(end), css, html, flags=re.S)
else:
    if "</head>" in html:
        html = html.replace("</head>", css + "\n</head>", 1)
    else:
        html = css + "\n" + html

marker = "<!-- GIGA_TITLE_GOLD_AVATAR_V12 -->"
if marker not in html:
    html = html.replace("<body>", "<body>\n  " + marker, 1)

p.write_text(html)
PY

echo
echo "GIGA CAT minimal title + gold avatar patch installed successfully."
echo "Backup: $BACKUP"
echo
echo "Updated:"
echo "  - Hid the OPEN PUMP.FUN button"
echo '  - Changed the main title to only "$GigaCat"'
echo "  - Added a premium gold gradient frame around the round avatar"
echo
echo "No server restart was performed."
echo
grep -nE 'GIGA_TITLE_GOLD_AVATAR_V12|\\$GigaCat|OPEN PUMP\\.FUN|coin-mark' "$INDEX" | head -n 60 || true
