#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"
PAYLOAD="$PATCH_DIR/payload/$TARGET"

if [ ! -d "$TARGET" ] || [ ! -f "$TARGET/index.html" ] || [ ! -f "$TARGET/styles.css" ]; then
  echo "ERROR: DIK site not found at: $TARGET"
  echo "Run this command from the existing Replit workspace root."
  exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP=".giga-cat-backup-$STAMP"
mkdir -p "$BACKUP/$TARGET/assets"

cp "$TARGET/index.html" "$BACKUP/$TARGET/index.html"
cp "$TARGET/config.js" "$BACKUP/$TARGET/config.js"
cp "$TARGET/script.js" "$BACKUP/$TARGET/script.js"
for f in dik-drive.png dik-original.png dik-casino.png dik-morning.png dik-gym.png dik-beach.png dik-penthouse.png; do
  cp "$TARGET/assets/$f" "$BACKUP/$TARGET/assets/$f"
done

cp "$PAYLOAD/index.html" "$TARGET/index.html"
cp "$PAYLOAD/config.js" "$TARGET/config.js"
cp "$PAYLOAD/script.js" "$TARGET/script.js"
cp "$PAYLOAD/assets/"*.png "$TARGET/assets/"

echo
printf '%s\n' "GIGA CAT patch installed successfully."
printf '%s\n' "Backup: $BACKUP"
printf '%s\n' "CSS/design files were not changed."
printf '%s\n' "No server restart was performed. Restart manually from the Replit console when ready."
echo
printf '%s\n' "Quick check:"
grep -nE 'GIGA CAT|Small cat|Big power' "$TARGET/index.html" | head -n 12 || true
