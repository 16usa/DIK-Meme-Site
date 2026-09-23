#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing Replit workspace root."
  exit 1
fi

BACKUP=".giga-cat-icon-only-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$INDEX" "$BACKUP/index.html"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text()

# 1) Visible title: Find $GigaCat on Pump.fun.
html = re.sub(
    r'Find\s+GIGA\s*CAT\s*<br>\s*on\s+Pump\.fun\.',
    'Find $GigaCat<br>on Pump.fun.',
    html,
    flags=re.I
)
html = re.sub(
    r'Find\s+GIGA\s*CAT\s+on\s+Pump\.fun\.',
    'Find $GigaCat on Pump.fun.',
    html,
    flags=re.I
)

# 2) Replace old logo-row CSS with icon-only sizing.
start = "<!-- GIGA_ICON_ONLY_OVERRIDES_START -->"
end = "<!-- GIGA_ICON_ONLY_OVERRIDES_END -->"
css = """
<!-- GIGA_ICON_ONLY_OVERRIDES_START -->
<style id="giga-icon-only-overrides">
  .ecosystem-row {
    display: flex !important;
    align-items: center !important;
    gap: 10px !important;
    margin: 0 0 18px !important;
  }

  .ecosystem-chip {
    width: 38px !important;
    height: 38px !important;
    min-width: 38px !important;
    min-height: 38px !important;
    padding: 0 !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    border-radius: 12px !important;
    border: 1px solid rgba(255,255,255,.14) !important;
    background: rgba(10,10,12,.28) !important;
    backdrop-filter: blur(12px) !important;
    box-shadow: inset 0 1px 0 rgba(255,255,255,.04) !important;
    overflow: hidden !important;
  }

  .ecosystem-chip svg {
    width: 20px !important;
    height: 20px !important;
    flex: 0 0 20px !important;
    display: block !important;
  }

  .ecosystem-chip-label {
    display: none !important;
  }

  .ecosystem-chip:hover {
    transform: translateY(-1px) !important;
  }

  @media (max-width: 520px) {
    .ecosystem-row {
      gap: 8px !important;
    }
    .ecosystem-chip {
      width: 36px !important;
      height: 36px !important;
      min-width: 36px !important;
      min-height: 36px !important;
      border-radius: 11px !important;
    }
    .ecosystem-chip svg {
      width: 19px !important;
      height: 19px !important;
      flex-basis: 19px !important;
    }
  }
</style>
<!-- GIGA_ICON_ONLY_OVERRIDES_END -->
""".strip()

if start in html and end in html:
    html = re.sub(re.escape(start) + r'.*?' + re.escape(end), css, html, flags=re.S)
else:
    html = html.replace("</head>", css + "\n</head>", 1)

# 3) If v7 row exists, strip text labels but preserve links/icons.
html = re.sub(
    r'<span class="ecosystem-chip-label">.*?</span>',
    '',
    html,
    flags=re.S
)

# 4) Make aria-labels explicit so icon-only links remain accessible.
html = re.sub(r'aria-label="Pump Fun"', 'aria-label="Pump.fun"', html)
html = re.sub(r'aria-label="DexScreener"', 'aria-label="DexScreener"', html)

marker = "<!-- GIGA_ICON_ONLY_V8 -->"
if marker not in html:
    html = html.replace("<body>", "<body>\n  " + marker, 1)

p.write_text(html)
PY

echo
echo "GIGA CAT icon-only patch installed successfully."
echo "Backup: $BACKUP"
echo
echo 'Changed:'
echo '  - "Find GIGA CAT" -> "Find $GigaCat"'
echo '  - Solana / Pump.fun / DexScreener / X row now shows icons only'
echo '  - All four links remain clickable'
echo
echo "No server restart was performed."
echo
grep -nE 'Find \$GigaCat|GIGA_ICON_ONLY_V8|ecosystem-chip-label|aria-label="(Solana|Pump\.fun|DexScreener|X)"' "$INDEX" | head -n 40 || true
