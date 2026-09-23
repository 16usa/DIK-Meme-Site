GIGA CAT Publish Real Site Fix v19

This fixes the actual published root artifact:
- Replit was serving artifacts/dik-meme-site/dist/public, whose React App hard-codes
  "Replit Agent is building..."
- The real GIGA CAT page is artifacts/dik-meme-site/site/index.html
- The unrelated api-server artifact was the only runnable artifact and was failing /api health checks

Install from the existing Replit workspace root:
  unzip -o Giga-Cat-Publish-Real-Site-Fix-v19.zip
  bash Giga-Cat-Publish-Real-Site-Fix-v19/install.sh

Then Republish in Replit.
No automatic restart is performed.
