GIGA CAT Replit Healthcheck Fix v16

Problem:
Replit Publishing logs show:
healthcheck failed
/api returned status 500

Fix:
server.js now returns HTTP 200 JSON for:
- /api
- /health
- /healthz

Normal static site routing is unchanged.

Install:
unzip -o Giga-Cat-Replit-Healthcheck-Fix-v16.zip && bash Giga-Cat-Replit-Healthcheck-Fix-v16/install.sh

Then restart manually and Republish.

Restore:
bash Giga-Cat-Replit-Healthcheck-Fix-v16/restore-latest.sh

No automatic restart.
