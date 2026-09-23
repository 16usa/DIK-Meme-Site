#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
CFG="$TARGET/config.js"
HTML="$TARGET/index.html"
JS="$TARGET/script.js"

for f in "$CFG" "$HTML" "$JS"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: missing $f"
    exit 1
  fi
done

BACKUP=".giga-cat-links-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$CFG" "$HTML" "$JS" "$BACKUP"/

python3 - <<'PY'
from pathlib import Path
import re

target = Path("artifacts/dik-meme-site/site")
cfg_path = target / "config.js"
html_path = target / "index.html"
js_path = target / "script.js"

mint = "2jcvq8QcJ8TzEYJKYMCjR61kXVSzib4mEkz89tQxpump"
pump = f"https://pump.fun/coin/{mint}"
dex = "https://dexscreener.com/solana/72tZoSAHAutvD7dP2fNC56aASLxbPXro9jBPohZ8aAvY"
xurl = "https://x.com/i/communities/2039446188739489972"

# config.js
cfg = cfg_path.read_text()
cfg = re.sub(r'contractAddress:\s*"[^"]*"', f'contractAddress: "{mint}"', cfg)
cfg = re.sub(r'pumpUrl:\s*"[^"]*"', f'pumpUrl: "{pump}"', cfg)
cfg = re.sub(r'xUrl:\s*"[^"]*"', f'xUrl: "{xurl}"', cfg)

if re.search(r'dexUrl:\s*"[^"]*"', cfg):
    cfg = re.sub(r'dexUrl:\s*"[^"]*"', f'dexUrl: "{dex}"', cfg)
else:
    cfg = re.sub(r'(xUrl:\s*"[^"]*",?\n)', r'\1  dexUrl: "' + dex + '",\n', cfg)

# Telegram stays disabled/empty for compatibility, but no Telegram link is shown.
if re.search(r'telegramUrl:\s*"[^"]*"', cfg):
    cfg = re.sub(r'telegramUrl:\s*"[^"]*"', 'telegramUrl: ""', cfg)

cfg_path.write_text(cfg)

# index.html: show X + Dex only.
html = html_path.read_text()
html = html.replace(
    '<a id="xLink" href="#">X / TWITTER</a>\n            <a id="telegramLink" href="#">TELEGRAM</a>',
    '<a id="xLink" href="#">X / TWITTER</a>\n            <a id="dexLink" href="#">DEXSCREENER</a>'
)
html = re.sub(r'\s*<a id="telegramLink"[^>]*>TELEGRAM</a>', '', html)
if 'id="dexLink"' not in html:
    html = html.replace(
        '<a id="xLink" href="#">X / TWITTER</a>',
        '<a id="xLink" href="#">X / TWITTER</a>\n            <a id="dexLink" href="#">DEXSCREENER</a>'
    )

# Make OG metadata point to the actual GIGA CAT project while keeping layout untouched.
html = re.sub(r'<meta property="og:title" content="[^"]*" />',
              '<meta property="og:title" content="GIGA CAT" />', html)
html_path.write_text(html)

# script.js: bind Dex, not Telegram.
js = js_path.read_text()
js = js.replace("bindExternal('telegramLink', cfg.telegramUrl);",
                "bindExternal('dexLink', cfg.dexUrl);")
if "bindExternal('dexLink', cfg.dexUrl);" not in js:
    js = js.replace("bindExternal('xLink', cfg.xUrl);",
                    "bindExternal('xLink', cfg.xUrl);\n  bindExternal('dexLink', cfg.dexUrl);")
js_path.write_text(js)
PY

echo
echo "GIGA CAT links patch installed successfully."
echo "Backup: $BACKUP"
echo "Added:"
echo "  Mint: 2jcvq8QcJ8TzEYJKYMCjR61kXVSzib4mEkz89tQxpump"
echo "  Pump.fun: https://pump.fun/coin/2jcvq8QcJ8TzEYJKYMCjR61kXVSzib4mEkz89tQxpump"
echo "  DexScreener: https://dexscreener.com/solana/72tZoSAHAutvD7dP2fNC56aASLxbPXro9jBPohZ8aAvY"
echo "  X: https://x.com/i/communities/2039446188739489972"
echo "Telegram link removed from the page."
echo "No CSS/design files were changed."
echo "No server restart was performed."
echo
echo "Quick check:"
grep -nE 'contractAddress|pumpUrl|dexUrl|xUrl|dexLink|telegramLink' "$CFG" "$HTML" "$JS" || true
