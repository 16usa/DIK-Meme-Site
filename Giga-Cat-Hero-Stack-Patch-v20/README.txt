GIGA CAT Hero Stack Patch v20

Purpose
-------
Single Replit patch for the complete requested hero re-layout:

1. MC + market-cap value at the top.
2. Holders directly below, with the holders icon on the LEFT of the value.
3. Existing interactive double-sided 3D coin below the stats.
4. Remove/hide the four ecosystem icon row below the coin.
5. Change the visible token title to exactly: $GIGACAT
6. Show MINT + address + COPY below the title.
7. Remove the frame/background from the Mint/Copy row.
8. Keep the coin level at rest without disabling swipe, inertia, or idle rotation.

Install from the existing Replit workspace root
----------------------------------------------
unzip -o Giga-Cat-Hero-Stack-Patch-v20.zip
bash Giga-Cat-Hero-Stack-Patch-v20/install.sh

Push
----
git add artifacts/dik-meme-site/site/index.html artifacts/dik-meme-site/site/assets/gigacat-hero-stack-v20.css
git commit -m "feat: restack GigaCat hero layout"
git push origin "$(git branch --show-current)"

Rollback
--------
bash Giga-Cat-Hero-Stack-Patch-v20/restore-latest.sh

No restart is included in the patch.
