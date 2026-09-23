GIGA CAT Stats Patch v10

Adds a large top stats row inside the visible card:
- MC (market cap)
- Holders count with icon

Style:
- White text
- No background
- Sized to visually match the card/title style

Data:
- Attempts to fetch market cap from DexScreener
- Attempts to fetch holders from Solscan
- Falls back gracefully to -- if a source is unavailable

Install:
unzip -o Giga-Cat-Stats-Patch-v10.zip && bash Giga-Cat-Stats-Patch-v10/install.sh

Restore:
bash Giga-Cat-Stats-Patch-v10/restore-latest.sh
