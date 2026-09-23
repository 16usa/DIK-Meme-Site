#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing Replit workspace root."
  exit 1
fi

BACKUP=".giga-cat-logo-row-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$INDEX" "$BACKUP/index.html"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text()

css_start = "<!-- GIGA_LOGO_ROW_OVERRIDES_START -->"
css_end = "<!-- GIGA_LOGO_ROW_OVERRIDES_END -->"

css_block = """
<!-- GIGA_LOGO_ROW_OVERRIDES_START -->
<style id="giga-logo-row-overrides">
  .ecosystem-row {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;
    margin: 0 0 16px;
  }

  .ecosystem-chip {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    min-height: 34px;
    padding: 8px 12px;
    border-radius: 999px;
    border: 1px solid rgba(255, 236, 205, 0.16);
    background: rgba(10, 10, 12, 0.22);
    backdrop-filter: blur(12px);
    color: rgba(255, 245, 232, 0.95);
    text-decoration: none;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 0.08em;
    line-height: 1;
    box-shadow: inset 0 1px 0 rgba(255,255,255,.03);
  }

  .ecosystem-chip svg {
    display: block;
    width: 16px;
    height: 16px;
    flex: 0 0 16px;
  }

  .ecosystem-chip:hover {
    transform: translateY(-1px);
  }

  .ecosystem-chip-label {
    white-space: nowrap;
  }

  @media (max-width: 520px) {
    .ecosystem-row {
      gap: 6px;
      margin-bottom: 14px;
    }
    .ecosystem-chip {
      min-height: 30px;
      padding: 7px 10px;
      font-size: 10px;
      gap: 7px;
    }
    .ecosystem-chip svg {
      width: 14px;
      height: 14px;
      flex-basis: 14px;
    }
  }
</style>
<!-- GIGA_LOGO_ROW_OVERRIDES_END -->
""".strip()

logo_row = """
<div class="ecosystem-row" aria-label="ecosystem logos">
  <a class="ecosystem-chip" href="https://solana.com" target="_blank" rel="noreferrer" aria-label="Solana">
    <svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <defs>
        <linearGradient id="solg1" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#4de1c1"/>
          <stop offset="100%" stop-color="#9945ff"/>
        </linearGradient>
      </defs>
      <path d="M14 14c1.5-2 4-3 6.5-3h29c2.6 0 3.8 3.1 1.9 4.8l-7.2 6.3c-1.5 1.3-3.4 1.9-5.4 1.9H10.2c-2.7 0-4-3.2-2-4.9z" fill="url(#solg1)"/>
      <path d="M50 28c-1.5 2-4 3-6.5 3h-29c-2.6 0-3.8-3.1-1.9-4.8l7.2-6.3c1.5-1.3 3.4-1.9 5.4-1.9h28.6c2.7 0 4 3.2 2 4.9z" fill="url(#solg1)"/>
      <path d="M14 40c1.5-2 4-3 6.5-3h29c2.6 0 3.8 3.1 1.9 4.8l-7.2 6.3c-1.5 1.3-3.4 1.9-5.4 1.9H10.2c-2.7 0-4-3.2-2-4.9z" fill="url(#solg1)"/>
    </svg>
    <span class="ecosystem-chip-label">SOLANA</span>
  </a>

  <a class="ecosystem-chip" href="https://pump.fun/coin/2jcvq8QcJ8TzEYJKYMCjR61kXVSzib4mEkz89tQxpump" target="_blank" rel="noreferrer" aria-label="Pump Fun">
    <svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <circle cx="32" cy="32" r="26" fill="#9BFF00"/>
      <path d="M24 18h12.5c8 0 13.5 4.8 13.5 11.8 0 7.2-5.5 12-13.5 12H31v8h-7V18zm11.7 18.2c4.3 0 6.9-2.2 6.9-6.4 0-4.1-2.6-6.2-6.9-6.2H31v12.6h4.7z" fill="#0b0b0d"/>
    </svg>
    <span class="ecosystem-chip-label">PUMP.FUN</span>
  </a>

  <a class="ecosystem-chip" href="https://dexscreener.com/solana/72tZoSAHAutvD7dP2fNC56aASLxbPXro9jBPohZ8aAvY" target="_blank" rel="noreferrer" aria-label="DexScreener">
    <svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <rect x="8" y="10" width="48" height="44" rx="10" fill="#111319" stroke="rgba(255,255,255,.22)"/>
      <path d="M18 42l9-10 7 5 12-15" fill="none" stroke="#e9f0ff" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>
      <circle cx="18" cy="42" r="3" fill="#e9f0ff"/>
      <circle cx="27" cy="32" r="3" fill="#e9f0ff"/>
      <circle cx="34" cy="37" r="3" fill="#e9f0ff"/>
      <circle cx="46" cy="22" r="3" fill="#e9f0ff"/>
    </svg>
    <span class="ecosystem-chip-label">DEX</span>
  </a>

  <a class="ecosystem-chip" href="https://x.com/i/communities/2039446188739489972" target="_blank" rel="noreferrer" aria-label="X">
    <svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <path d="M14 14h10l13 16 13-16h8L42 33l18 17H49L35 33 20 50H6l21-20z" fill="#f5f5f2"/>
    </svg>
    <span class="ecosystem-chip-label">X</span>
  </a>
</div>
""".strip()

# Insert or replace the CSS block.
if css_start in html and css_end in html:
    html = re.sub(re.escape(css_start) + r'.*?' + re.escape(css_end), css_block, html, flags=re.S)
else:
    if "</head>" in html:
        html = html.replace("</head>", css_block + "\n</head>", 1)
    else:
        html = css_block + "\n" + html

# Replace the ON SOLANA kicker in the visible card.
replaced = False
patterns = [
    r'<div class="section-kicker">ON SOLANA</div>',
    r'<div class="section-kicker">\s*ON SOLANA\s*</div>',
    r'<div class="mini-kicker">\s*ON SOLANA\s*</div>',
]
for pat in patterns:
    if re.search(pat, html, flags=re.S):
        html = re.sub(pat, logo_row, html, count=1, flags=re.S)
        replaced = True
        break

# Fallback: replace the first section-kicker within the buy panel block.
if not replaced:
    buy_block = re.search(r'(<section[^>]*class="buy section"[^>]*>.*?</section>)', html, flags=re.S)
    if buy_block:
        block = buy_block.group(1)
        new_block, n = re.subn(r'<div class="section-kicker">.*?</div>', logo_row, block, count=1, flags=re.S)
        if n:
            html = html.replace(block, new_block, 1)
            replaced = True

marker = "<!-- GIGA_LOGO_ROW_V7 -->"
if marker not in html:
    html = html.replace("<body>", "<body>\n  " + marker, 1)

p.write_text(html)
PY

echo
echo "GIGA CAT logo-row patch installed successfully."
echo "Backup: $BACKUP"
echo
echo "Updated:"
echo "  - Replaced the ON SOLANA row with logos"
echo "  - Added logos for Solana, Pump.fun, Dex, and X"
echo "  - Existing buttons and avatar were left unchanged"
echo
echo "No server restart was performed."
echo
grep -nE 'GIGA_LOGO_ROW_V7|ecosystem-row|PUMP\.FUN|SOLANA|DEX|X' "$INDEX" | head -n 40 || true
