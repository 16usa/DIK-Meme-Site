#!/usr/bin/env bash
set -euo pipefail

WEB_MANIFEST="artifacts/dik-meme-site/.replit-artifact/artifact.toml"
API_MANIFEST="artifacts/api-server/.replit-artifact/artifact.toml"
SITE_INDEX="artifacts/dik-meme-site/site/index.html"

for f in "$WEB_MANIFEST" "$API_MANIFEST" "$SITE_INDEX"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: expected file not found: $f"
    exit 1
  fi
done

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP=".giga-cat-publish-v19-backup-$STAMP"
mkdir -p "$BACKUP/artifacts/dik-meme-site/.replit-artifact" "$BACKUP/artifacts/api-server/.replit-artifact"
cp "$WEB_MANIFEST" "$BACKUP/artifacts/dik-meme-site/.replit-artifact/artifact.toml"
cp "$API_MANIFEST" "$BACKUP/artifacts/api-server/.replit-artifact/artifact.toml"

PATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$PATCH_DIR/payload/dik-meme-site-artifact.toml" "$WEB_MANIFEST"

# The GIGA CAT page is fully static/client-side. The API artifact is unrelated
# to the landing page and is the only runnable artifact failing deployment
# health checks. Disable only its Replit artifact manifest; keep all source code.
mv "$API_MANIFEST" "${API_MANIFEST}.disabled-v19"

# Hard checks: the published root must now be the real GIGA CAT site directory,
# and no runnable API artifact manifest may remain discoverable.
grep -q 'publicDir = "artifacts/dik-meme-site/site"' "$WEB_MANIFEST"
grep -q 'previewPath = "/"' "$WEB_MANIFEST"
[ -f "$SITE_INDEX" ]
[ ! -f "$API_MANIFEST" ]
[ -f "${API_MANIFEST}.disabled-v19" ]

# Show the exact phrase in the old React placeholder so the reason is auditable.
echo
echo "=== CONFIRMED ROOT CAUSE ==="
if grep -R -n -m1 'Replit Agent is building' artifacts/dik-meme-site/src 2>/dev/null; then
  echo "Old Vite/React artifact contains the placeholder shown in Safari."
else
  echo "Placeholder source not found locally (may differ from repo snapshot)."
fi

echo
echo "=== NEW PUBLISH TARGET ==="
grep -E '^(kind|previewPath|version|publicDir|serve)' "$WEB_MANIFEST" || true

echo
echo "=== DISCOVERABLE ARTIFACT MANIFESTS ==="
find artifacts -path '*/.replit-artifact/artifact.toml' -print | sort

echo
echo "GIGA CAT Publish Real Site Fix v19 installed successfully."
echo "Backup: $BACKUP"
echo
echo "What changed:"
echo "  - / now publishes artifacts/dik-meme-site/site (the real GIGA CAT site)"
echo "  - API artifact manifest disabled so its failing /api healthcheck cannot kill publishing"
echo "  - API source code was NOT deleted"
echo "  - no server/process restart was performed"
echo
echo "Next: Republish in Replit. GitHub push is optional for the Replit publish test."
echo "Rollback: bash Giga-Cat-Publish-Real-Site-Fix-v19/restore-latest.sh"
