GIGA CAT Holders Fix Patch v14

Fixes the holder counter that was showing "--".

Logic:
1. GeckoTerminal holder snapshot.
2. Direct Solana RPC fallback with getProgramAccounts.
3. Ignore zero token balances.
4. Deduplicate wallet owners.
5. Refresh every 60 seconds.

No API key required.

Install:
unzip -o Giga-Cat-Holders-Fix-Patch-v14.zip && bash Giga-Cat-Holders-Fix-Patch-v14/install.sh

Restore:
bash Giga-Cat-Holders-Fix-Patch-v14/restore-latest.sh

No automatic server restart.
