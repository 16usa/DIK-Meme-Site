# DIK Meme Site

A self-contained one-page DIK character site built for Replit. No frameworks and no external npm dependencies.

## Replit install

1. Upload `DIK-Meme-Site-v1.zip` into your Replit project.
2. Open Shell and run:

```bash
cd ~/workspace && rm -rf dik-site && mkdir dik-site && unzip -o DIK-Meme-Site-v1.zip -d dik-site && cd dik-site && bash install.sh
```

3. Edit `config.js` and replace:
   - `PASTE_CONTRACT_ADDRESS_HERE`
   - `PASTE_PUMP_FUN_URL_HERE`
   - `PASTE_X_URL_HERE`
   - optional Telegram URL
4. Press **Run** in Replit, or run `npm start`.

The server uses Replit's `PORT` environment variable automatically, with port 3000 as a fallback.

## Files

- `index.html` – page structure
- `styles.css` – responsive design and animation
- `script.js` – interactions, copy CA, parallax, reveal effects
- `config.js` – token/social links to edit
- `server.js` – dependency-free Node static server
- `.replit` – Run configuration
- `assets/` – DIK images

## Before publishing

Paste the final Pump.fun URL and contract address into `config.js`. Buttons remain disabled while placeholders are present.
