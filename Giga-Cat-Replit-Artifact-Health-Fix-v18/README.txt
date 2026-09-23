GIGA CAT Replit Artifact Health Fix v18

Install from the existing Replit workspace root:

  unzip -o Giga-Cat-Replit-Artifact-Health-Fix-v18.zip
  bash Giga-Cat-Replit-Artifact-Health-Fix-v18/install.sh

Then commit/push:

  git add artifacts/api-server/.replit-artifact/artifact.toml artifacts/api-server/src/routes/health.ts
  git commit -m "fix: align Replit API artifact health path"
  git push origin main

Then Republish in Replit Publishing.

No automatic server restart is performed.
