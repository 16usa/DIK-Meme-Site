#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing Replit workspace root."
  exit 1
fi

BACKUP=".giga-cat-stats-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$INDEX" "$BACKUP/index.html"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text()

# 1) Styles for the stats row.
style_start = "<!-- GIGA_STATS_OVERRIDES_START -->"
style_end = "<!-- GIGA_STATS_OVERRIDES_END -->"
style_block = """
<!-- GIGA_STATS_OVERRIDES_START -->
<style id="giga-stats-overrides">
  .token-stats-row {
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: flex-start;
    gap: 34px;
    margin: 2px auto 18px;
    text-align: center;
  }

  .token-stat {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-width: 110px;
    color: rgba(255,255,255,.98);
  }

  .token-stat-top {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 7px;
    margin-bottom: 3px;
    color: rgba(255,255,255,.72);
    font-size: 12px;
    font-weight: 900;
    letter-spacing: .14em;
    line-height: 1;
    text-transform: uppercase;
  }

  .token-stat-icon {
    width: 15px;
    height: 15px;
    display: inline-block;
    flex: 0 0 15px;
  }

  .token-stat-value {
    color: #fff;
    font-weight: 1000;
    letter-spacing: -.05em;
    line-height: .95;
    font-size: clamp(28px, 4.3vw, 44px);
    text-shadow: 0 8px 22px rgba(0,0,0,.28);
    white-space: nowrap;
  }

  .token-stat-value.loading {
    opacity: .82;
  }

  @media (max-width: 520px) {
    .token-stats-row {
      gap: 24px;
      margin-bottom: 16px;
    }

    .token-stat {
      min-width: 96px;
    }

    .token-stat-top {
      font-size: 11px;
      gap: 6px;
    }

    .token-stat-value {
      font-size: clamp(26px, 8vw, 40px);
    }
  }
</style>
<!-- GIGA_STATS_OVERRIDES_END -->
""".strip()

if style_start in html and style_end in html:
    html = re.sub(re.escape(style_start) + r'.*?' + re.escape(style_end), style_block, html, flags=re.S)
else:
    html = html.replace("</head>", style_block + "\n</head>", 1)

# 2) Inject the stats row into the visible buy panel, near the top.
stats_markup = """
<div class="token-stats-row" id="tokenStatsRow" aria-label="token stats">
  <div class="token-stat token-stat-mc">
    <div class="token-stat-top">
      <span>MC</span>
    </div>
    <div class="token-stat-value loading" id="marketCapValue">$--</div>
  </div>

  <div class="token-stat token-stat-holders">
    <div class="token-stat-top">
      <svg class="token-stat-icon" viewBox="0 0 24 24" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
        <path fill="currentColor" d="M9 11a4 4 0 1 0-4-4 4 4 0 0 0 4 4Zm6 1a3 3 0 1 0-3-3 3 3 0 0 0 3 3Zm-6 2c-3.33 0-6 1.34-6 3v1h12v-1c0-1.66-2.67-3-6-3Zm6.6.17A7.73 7.73 0 0 1 18 17v1h3v-.8c0-1.19-1.78-2.24-4.4-2.83Z"/>
      </svg>
    </div>
    <div class="token-stat-value loading" id="holdersValue">--</div>
  </div>
</div>
""".strip()

marker = '<div class="token-stats-row" id="tokenStatsRow"'
if marker not in html:
    html = re.sub(
        r'(<div class="buy-panel reveal"[^>]*>)',
        r'\1' + "\n          " + stats_markup,
        html,
        count=1,
        flags=re.S
    )

# 3) Live fetch script for market cap + holders.
script_start = "<!-- GIGA_STATS_SCRIPT_START -->"
script_end = "<!-- GIGA_STATS_SCRIPT_END -->"
script_block = """
<!-- GIGA_STATS_SCRIPT_START -->
<script id="giga-stats-script">
(function () {
  const mint = "2jcvq8QcJ8TzEYJKYMCjR61kXVSzib4mEkz89tQxpump";
  const pairAddress = "72tZoSAHAutvD7dP2fNC56aASLxbPXro9jBPohZ8aAvY";

  const mcEl = document.getElementById("marketCapValue");
  const holdersEl = document.getElementById("holdersValue");
  if (!mcEl || !holdersEl) return;

  function compactNumber(value) {
    const n = Number(value);
    if (!Number.isFinite(n) || n <= 0) return "--";
    return new Intl.NumberFormat("en", {
      notation: "compact",
      maximumFractionDigits: 2
    }).format(n);
  }

  function setMarketCap(value) {
    mcEl.textContent = value;
    mcEl.classList.remove("loading");
  }

  function setHolders(value) {
    holdersEl.textContent = value;
    holdersEl.classList.remove("loading");
  }

  async function fetchMarketCap() {
    try {
      const res = await fetch("https://api.dexscreener.com/latest/dex/pairs/solana/" + pairAddress, { cache: "no-store" });
      if (!res.ok) throw new Error("dex request failed");
      const data = await res.json();
      const pair = (data && (data.pair || (Array.isArray(data.pairs) ? data.pairs[0] : null))) || null;
      const mc = pair && (pair.marketCap || pair.fdv || pair.fdvUsd || pair.liquidity && pair.liquidity.usd);
      setMarketCap("$" + compactNumber(mc));
    } catch (e) {
      setMarketCap("$--");
    }
  }

  async function fetchHolders() {
    const sources = [
      "https://public-api.solscan.io/token/meta?tokenAddress=" + mint,
      "https://public-api.solscan.io/token/holders?tokenAddress=" + mint + "&offset=0&limit=1"
    ];

    for (const url of sources) {
      try {
        const res = await fetch(url, {
          cache: "no-store",
          headers: { "accept": "application/json" }
        });
        if (!res.ok) continue;
        const data = await res.json();

        const candidates = [
          data && data.holder,
          data && data.holders,
          data && data.holder_count,
          data && data.holderCount,
          data && data.total
        ].filter(Boolean);

        if (candidates.length) {
          setHolders(compactNumber(candidates[0]));
          return;
        }
      } catch (e) {}
    }

    setHolders("--");
  }

  fetchMarketCap();
  fetchHolders();
})();
</script>
<!-- GIGA_STATS_SCRIPT_END -->
""".strip()

if script_start in html and script_end in html:
    html = re.sub(re.escape(script_start) + r'.*?' + re.escape(script_end), script_block, html, flags=re.S)
else:
    html = html.replace("</body>", script_block + "\n</body>", 1)

body_marker = "<!-- GIGA_STATS_V10 -->"
if body_marker not in html:
    html = html.replace("<body>", "<body>\n  " + body_marker, 1)

p.write_text(html)
PY

echo
echo "GIGA CAT stats patch installed successfully."
echo "Backup: $BACKUP"
echo
echo "Added:"
echo "  - Market cap (MC) at the top of the card"
echo "  - Holders count with an icon"
echo "  - Live fetch attempts for MC and holders"
echo
echo "No server restart was performed."
echo
grep -nE 'GIGA_STATS_V10|marketCapValue|holdersValue|token-stats-row|giga-stats-script' "$INDEX" | head -n 50 || true
