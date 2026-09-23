#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing Replit workspace root."
  exit 1
fi

BACKUP=".giga-cat-official-logos-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$INDEX" "$BACKUP/index.html"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text()

# Replace the current ecosystem row with clean brand marks only.
new_row = """
<div class="ecosystem-row official-brand-row" aria-label="ecosystem links">
  <a class="brand-logo-link solana-logo-link"
     href="https://solana.com"
     target="_blank" rel="noreferrer"
     aria-label="Solana">
    <img src="https://solana.com/src/img/branding/solanaLogoMark.svg"
         alt="Solana" class="brand-logo brand-logo-solana" />
  </a>

  <a class="brand-logo-link pump-logo-link"
     href="https://pump.fun/coin/2jcvq8QcJ8TzEYJKYMCjR61kXVSzib4mEkz89tQxpump"
     target="_blank" rel="noreferrer"
     aria-label="Pump.fun">
    <img src="https://pump.fun/pump-logomark.svg"
         alt="Pump.fun" class="brand-logo brand-logo-pump" />
  </a>

  <a class="brand-logo-link dex-logo-link"
     href="https://dexscreener.com/solana/72tZoSAHAutvD7dP2fNC56aASLxbPXro9jBPohZ8aAvY"
     target="_blank" rel="noreferrer"
     aria-label="DexScreener">
    <img src="https://github.com/dexscreener.png?size=128"
         alt="DexScreener" class="brand-logo brand-logo-dex" />
  </a>

  <a class="brand-logo-link x-logo-link"
     href="https://x.com/i/communities/2039446188739489972"
     target="_blank" rel="noreferrer"
     aria-label="X">
    <img src="https://about.x.com/content/dam/about-twitter/x/brand-toolkit/logo-black.png.twimg.1920.png"
         alt="X" class="brand-logo brand-logo-x" />
  </a>
</div>
""".strip()

# Replace first ecosystem row in the visible card.
row_pattern = r'<div class="ecosystem-row[^"]*"[^>]*>.*?</div>'
if re.search(row_pattern, html, flags=re.S):
    html = re.sub(row_pattern, new_row, html, count=1, flags=re.S)
else:
    # Fallback: insert above the visible Find $GigaCat heading.
    heading_match = re.search(r'(<h2[^>]*>\s*Find\s+\$GigaCat)', html, flags=re.I)
    if heading_match:
        html = html[:heading_match.start()] + new_row + "\n" + html[heading_match.start():]

# Add strong final CSS overrides for centering and removing frames.
start = "<!-- GIGA_OFFICIAL_LOGOS_CENTER_START -->"
end = "<!-- GIGA_OFFICIAL_LOGOS_CENTER_END -->"
css = """
<!-- GIGA_OFFICIAL_LOGOS_CENTER_START -->
<style id="giga-official-logos-center">
  .official-brand-row {
    width: 100% !important;
    display: flex !important;
    justify-content: center !important;
    align-items: center !important;
    gap: 24px !important;
    margin: 0 auto 22px !important;
    padding: 0 !important;
    text-align: center !important;
  }

  .brand-logo-link {
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    width: auto !important;
    height: auto !important;
    min-width: 0 !important;
    min-height: 0 !important;
    padding: 0 !important;
    margin: 0 !important;
    border: 0 !important;
    border-radius: 0 !important;
    outline: 0 !important;
    background: transparent !important;
    box-shadow: none !important;
    backdrop-filter: none !important;
    -webkit-backdrop-filter: none !important;
    overflow: visible !important;
  }

  .brand-logo-link:hover {
    transform: translateY(-1px) scale(1.035) !important;
  }

  .brand-logo {
    display: block !important;
    width: auto !important;
    object-fit: contain !important;
    border: 0 !important;
    border-radius: 0 !important;
    background: transparent !important;
    box-shadow: none !important;
  }

  .brand-logo-solana {
    height: 25px !important;
  }

  .brand-logo-pump {
    height: 29px !important;
  }

  .brand-logo-dex {
    height: 30px !important;
    width: 30px !important;
    border-radius: 6px !important;
  }

  .brand-logo-x {
    height: 22px !important;
    width: 22px !important;
    filter: invert(1) !important;
  }

  /* Center the bottom X / TWITTER + DEXSCREENER links as one group. */
  .social-row {
    width: 100% !important;
    display: flex !important;
    justify-content: center !important;
    align-items: center !important;
    gap: 34px !important;
    margin-left: auto !important;
    margin-right: auto !important;
    text-align: center !important;
  }

  .social-row a {
    text-align: center !important;
  }

  @media (max-width: 520px) {
    .official-brand-row {
      gap: 22px !important;
      margin-bottom: 20px !important;
    }

    .brand-logo-solana {
      height: 23px !important;
    }

    .brand-logo-pump {
      height: 27px !important;
    }

    .brand-logo-dex {
      width: 28px !important;
      height: 28px !important;
    }

    .brand-logo-x {
      width: 21px !important;
      height: 21px !important;
    }

    .social-row {
      gap: 28px !important;
    }
  }
</style>
<!-- GIGA_OFFICIAL_LOGOS_CENTER_END -->
""".strip()

if start in html and end in html:
    html = re.sub(re.escape(start) + r'.*?' + re.escape(end), css, html, flags=re.S)
else:
    html = html.replace("</head>", css + "\n</head>", 1)

marker = "<!-- GIGA_OFFICIAL_LOGOS_CENTER_V9 -->"
if marker not in html:
    html = html.replace("<body>", "<body>\n  " + marker, 1)

p.write_text(html)
PY

echo
echo "GIGA CAT official-logo centering patch installed successfully."
echo "Backup: $BACKUP"
echo
echo "Updated:"
echo "  - Solana / Pump.fun / DexScreener / X centered"
echo "  - Brand marks only, no surrounding frames"
echo "  - Bottom X / TWITTER + DEXSCREENER links centered"
echo "  - Official/brand-source logo assets are used"
echo
echo "No server restart was performed."
echo
grep -nE 'GIGA_OFFICIAL_LOGOS_CENTER_V9|official-brand-row|brand-logo-|social-row' "$INDEX" | head -n 50 || true
