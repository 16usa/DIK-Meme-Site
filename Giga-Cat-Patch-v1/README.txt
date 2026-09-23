GIGA CAT PATCH v1

What it changes:
- Replaces DIK character images with GIGA CAT artwork.
- Replaces visible DIK text/descriptions with GIGA CAT copy.
- Changes token display content to GIGA CAT / $GIGA placeholders.

What it does NOT change:
- styles.css
- fonts
- colors
- spacing/layout
- animations
- site structure
- server startup

Install from the existing Replit workspace root:
  unzip -o Giga-Cat-Patch-v1.zip && bash Giga-Cat-Patch-v1/install.sh

The installer makes a timestamped backup automatically.
It does NOT restart the server.

Optional Git push after you inspect the site:
  git add artifacts/dik-meme-site/site/index.html artifacts/dik-meme-site/site/config.js artifacts/dik-meme-site/site/script.js artifacts/dik-meme-site/site/assets && git commit -m "Replace DIK with Giga Cat" && git push
