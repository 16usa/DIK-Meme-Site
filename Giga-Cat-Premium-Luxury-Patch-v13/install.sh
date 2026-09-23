#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing Replit workspace root."
  exit 1
fi

BACKUP=".giga-cat-premium-v13-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$INDEX" "$BACKUP/index.html"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text()

start = "<!-- GIGA_PREMIUM_V13_START -->"
end = "<!-- GIGA_PREMIUM_V13_END -->"

css = r'''
<!-- GIGA_PREMIUM_V13_START -->
<style id="giga-premium-v13">
  :root {
    --giga-champagne: #E9C98D;
    --giga-champagne-soft: #F3DDAF;
    --giga-ink: #070707;
  }

  .buy-panel.reveal {
    border: 1px solid rgba(233, 201, 141, .18) !important;
    box-shadow:
      inset 0 1px 0 rgba(255,255,255,.055),
      inset 0 0 0 1px rgba(233,201,141,.025),
      0 26px 80px rgba(0,0,0,.48) !important;
  }

  .buy-panel.reveal::before {
    content: "" !important;
    position: absolute !important;
    inset: 0 !important;
    z-index: 0 !important;
    pointer-events: none !important;
    background:
      radial-gradient(circle at 16% 7%, rgba(236,195,111,.15), transparent 28%),
      radial-gradient(circle at 82% 26%, rgba(226,183,96,.06), transparent 30%),
      linear-gradient(
        180deg,
        rgba(4,4,4,.34) 0%,
        rgba(8,6,4,.20) 26%,
        rgba(7,5,3,.31) 58%,
        rgba(5,4,3,.72) 100%
      ) !important;
  }

  .buy-panel.reveal > * {
    position: relative !important;
    z-index: 1 !important;
  }

  .token-stats-row {
    width: 100% !important;
    max-width: 520px !important;
    display: flex !important;
    justify-content: center !important;
    align-items: flex-start !important;
    gap: clamp(42px, 9vw, 84px) !important;
    margin: 0 auto 24px !important;
    text-align: center !important;
  }

  .token-stat {
    min-width: 128px !important;
    align-items: center !important;
  }

  .token-stat-top {
    min-height: 16px !important;
    margin-bottom: 7px !important;
    color: rgba(243,221,175,.76) !important;
    font-size: 10px !important;
    font-weight: 850 !important;
    letter-spacing: .18em !important;
  }

  .token-stat-icon {
    width: 16px !important;
    height: 16px !important;
    color: rgba(243,221,175,.80) !important;
  }

  .token-stat-value {
    color: rgba(255,255,255,.98) !important;
    font-size: clamp(30px, 5.2vw, 42px) !important;
    font-weight: 900 !important;
    letter-spacing: -.035em !important;
    line-height: .92 !important;
    text-shadow: 0 9px 28px rgba(0,0,0,.30) !important;
  }

  .coin-mark {
    width: 126px !important;
    height: 126px !important;
    flex: 0 0 126px !important;
    margin: 0 auto !important;
    padding: 2px !important;
    border: 0 !important;
    border-radius: 50% !important;
    background:
      linear-gradient(
        135deg,
        #8B642A 0%,
        #F0D9A6 24%,
        #B98B42 52%,
        #F6E5BF 75%,
        #8E662B 100%
      ) !important;
    box-shadow:
      0 10px 28px rgba(0,0,0,.32),
      0 0 0 1px rgba(236,207,148,.22) !important;
  }

  .coin-mark::after {
    content: "" !important;
    position: absolute !important;
    inset: 2px !important;
    border-radius: 50% !important;
    pointer-events: none !important;
    box-shadow:
      inset 0 1px 0 rgba(255,255,255,.28),
      inset 0 0 0 1px rgba(0,0,0,.24) !important;
  }

  .coin-mark img {
    width: 100% !important;
    height: 100% !important;
    object-fit: cover !important;
    border-radius: 50% !important;
    display: block !important;
  }

  .official-brand-row,
  .ecosystem-row {
    width: 100% !important;
    display: flex !important;
    justify-content: center !important;
    align-items: center !important;
    gap: 26px !important;
    margin: 20px auto 18px !important;
    padding: 0 !important;
  }

  .official-brand-row .brand-logo-link,
  .ecosystem-row .brand-logo-link,
  .ecosystem-row .ecosystem-chip {
    width: auto !important;
    height: auto !important;
    min-width: 0 !important;
    min-height: 0 !important;
    padding: 0 !important;
    margin: 0 !important;
    border: 0 !important;
    border-radius: 0 !important;
    background: transparent !important;
    box-shadow: none !important;
    backdrop-filter: none !important;
    -webkit-backdrop-filter: none !important;
  }

  .official-brand-row .brand-logo,
  .ecosystem-row .brand-logo,
  .ecosystem-row svg {
    filter: grayscale(1) brightness(0) invert(1) !important;
    opacity: .88 !important;
    box-shadow: none !important;
  }

  .official-brand-row .brand-logo-solana,
  .official-brand-row .brand-logo-pump,
  .official-brand-row .brand-logo-dex,
  .official-brand-row .brand-logo-x {
    max-width: 28px !important;
    max-height: 28px !important;
  }

  .ecosystem-chip-label {
    display: none !important;
  }

  .buy-panel h2,
  .buy h2 {
    width: 100% !important;
    max-width: 640px !important;
    margin: 6px auto 22px !important;
    text-align: center !important;
    color: #fff !important;
    font-size: clamp(56px, 9vw, 82px) !important;
    font-weight: 920 !important;
    letter-spacing: -.055em !important;
    line-height: .90 !important;
    text-shadow: 0 11px 30px rgba(0,0,0,.30) !important;
  }

  .contract {
    width: min(94%, 620px) !important;
    min-height: 56px !important;
    margin: 0 auto !important;
    padding: 12px 18px !important;
    border-radius: 16px !important;
    border: 1px solid rgba(233,201,141,.12) !important;
    background: rgba(7,7,7,.24) !important;
    box-shadow: inset 0 1px 0 rgba(255,255,255,.025) !important;
    backdrop-filter: blur(10px) !important;
    -webkit-backdrop-filter: blur(10px) !important;
  }

  .contract-value {
    color: rgba(255,255,255,.70) !important;
    font-size: 11px !important;
    letter-spacing: .01em !important;
  }

  .contract-copy {
    color: rgba(233,201,141,.78) !important;
    font-size: 9px !important;
    letter-spacing: .16em !important;
  }

  .social-row {
    width: 100% !important;
    display: flex !important;
    justify-content: center !important;
    align-items: center !important;
    gap: 28px !important;
    margin: 17px auto 0 !important;
    text-align: center !important;
    font-size: 10px !important;
    letter-spacing: .16em !important;
    color: rgba(255,255,255,.58) !important;
  }

  .social-row a {
    color: rgba(255,255,255,.58) !important;
  }

  .social-row a:hover {
    color: rgba(243,221,175,.92) !important;
  }

  @media (max-width: 760px) {
    .buy-panel.reveal {
      padding: 26px 20px 24px !important;
    }

    .token-stats-row {
      max-width: 440px !important;
      gap: 40px !important;
      margin-bottom: 23px !important;
    }

    .token-stat {
      min-width: 116px !important;
    }

    .coin-mark {
      width: 122px !important;
      height: 122px !important;
      flex-basis: 122px !important;
    }

    .official-brand-row,
    .ecosystem-row {
      gap: 24px !important;
      margin-top: 19px !important;
      margin-bottom: 18px !important;
    }

    .buy-panel h2,
    .buy h2 {
      font-size: clamp(54px, 14.5vw, 76px) !important;
      margin-bottom: 21px !important;
    }

    .contract {
      width: 96% !important;
    }
  }

  @media (max-width: 420px) {
    .token-stats-row {
      gap: 26px !important;
    }

    .token-stat {
      min-width: 106px !important;
    }

    .token-stat-value {
      font-size: 29px !important;
    }

    .coin-mark {
      width: 116px !important;
      height: 116px !important;
      flex-basis: 116px !important;
    }

    .official-brand-row,
    .ecosystem-row {
      gap: 22px !important;
    }

    .buy-panel h2,
    .buy h2 {
      font-size: 55px !important;
    }
  }
</style>
<!-- GIGA_PREMIUM_V13_END -->
'''.strip()

if start in html and end in html:
    html = re.sub(re.escape(start) + r'.*?' + re.escape(end), css, html, flags=re.S)
else:
    if "</head>" in html:
        html = html.replace("</head>", css + "\n</head>", 1)
    else:
        html = css + "\n" + html

marker = "<!-- GIGA_PREMIUM_V13 -->"
if marker not in html:
    html = html.replace("<body>", "<body>\n  " + marker, 1)

p.write_text(html)
PY

echo
echo "GIGA CAT Premium Luxury v13 installed successfully."
echo "Backup: $BACKUP"
echo
echo "Changed:"
echo "  - Darker, cleaner background treatment"
echo "  - More symmetrical MC / holders row"
echo "  - Thinner champagne-gold avatar frame"
echo "  - Monochrome platinum ecosystem logos"
echo "  - Cleaner \$GigaCat typography/spacing"
echo "  - Quieter contract block"
echo "  - Centered secondary X / Dex links"
echo
echo "Nothing was deleted."
echo "No server restart was performed."
echo
echo "Restore this exact step:"
echo "  bash Giga-Cat-Premium-Luxury-Patch-v13/restore-latest.sh"
