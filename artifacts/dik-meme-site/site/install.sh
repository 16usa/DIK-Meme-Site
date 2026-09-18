#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
echo "DIK site installer"
if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: Node.js is required. In Replit, use a Node.js project."
  exit 1
fi
node -v
chmod +x install.sh start.sh 2>/dev/null || true
echo "No npm packages are required."
echo "Edit config.js and paste your Pump.fun URL, contract address and X link."
echo "Installation verified: PASS"
echo "Press Run in Replit, or run: npm start"
