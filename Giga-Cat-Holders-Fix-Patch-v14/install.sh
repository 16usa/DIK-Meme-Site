#!/usr/bin/env bash
set -euo pipefail

TARGET="artifacts/dik-meme-site/site"
INDEX="$TARGET/index.html"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found."
  echo "Run this from the existing Replit workspace root."
  exit 1
fi

BACKUP=".giga-cat-holders-v14-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cp "$INDEX" "$BACKUP/index.html"

python3 - <<'PY'
from pathlib import Path

p = Path("artifacts/dik-meme-site/site/index.html")
html = p.read_text()

new_code = r'''
  const BASE58_ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

  function base58Encode(bytes) {
    if (!bytes || !bytes.length) return "";
    const digits = [0];

    for (const byte of bytes) {
      let carry = byte;
      for (let j = 0; j < digits.length; j++) {
        const x = digits[j] * 256 + carry;
        digits[j] = x % 58;
        carry = (x / 58) | 0;
      }
      while (carry > 0) {
        digits.push(carry % 58);
        carry = (carry / 58) | 0;
      }
    }

    let zeros = 0;
    while (zeros < bytes.length && bytes[zeros] === 0) zeros++;

    let out = "1".repeat(zeros);
    for (let i = digits.length - 1; i >= 0; i--) {
      out += BASE58_ALPHABET[digits[i]];
    }
    return out;
  }

  function readU64LE(bytes, offset) {
    let value = 0n;
    for (let i = 7; i >= 0; i--) {
      value = (value << 8n) + BigInt(bytes[offset + i] || 0);
    }
    return value;
  }

  async function rpcCall(endpoint, programId, filters) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 12000);

    try {
      const res = await fetch(endpoint, {
        method: "POST",
        cache: "no-store",
        signal: controller.signal,
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          jsonrpc: "2.0",
          id: 1,
          method: "getProgramAccounts",
          params: [
            programId,
            {
              commitment: "confirmed",
              encoding: "base64",
              dataSlice: { offset: 32, length: 40 },
              filters
            }
          ]
        })
      });

      if (!res.ok) throw new Error("RPC HTTP " + res.status);
      const json = await res.json();
      if (json.error) throw new Error(json.error.message || "RPC error");
      if (!Array.isArray(json.result)) throw new Error("Bad RPC result");
      return json.result;
    } finally {
      clearTimeout(timer);
    }
  }

  function uniquePositiveOwners(accounts) {
    const owners = new Set();

    for (const row of accounts || []) {
      try {
        const encoded = row &&
          row.account &&
          Array.isArray(row.account.data) &&
          row.account.data[0];

        if (!encoded) continue;

        const binary = atob(encoded);
        const bytes = Uint8Array.from(binary, ch => ch.charCodeAt(0));

        // dataSlice begins at token-account byte 32:
        // bytes 0..31 = owner; bytes 32..39 = token amount (u64 LE).
        if (bytes.length < 40) continue;

        const amount = readU64LE(bytes, 32);
        if (amount <= 0n) continue;

        const owner = base58Encode(bytes.slice(0, 32));
        if (owner) owners.add(owner);
      } catch (_) {}
    }

    return owners;
  }

  async function holdersFromOnChainRpc() {
    const rpcEndpoints = [
      "https://solana-rpc.publicnode.com",
      "https://api.mainnet.solana.com",
      "https://api.mainnet-beta.solana.com"
    ];

    const tokenPrograms = [
      {
        id: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
        filters: [
          { dataSize: 165 },
          { memcmp: { offset: 0, bytes: mint } }
        ]
      },
      {
        id: "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb",
        filters: [
          { memcmp: { offset: 0, bytes: mint } }
        ]
      }
    ];

    for (const endpoint of rpcEndpoints) {
      const allOwners = new Set();
      let gotSuccessfulResponse = false;

      for (const program of tokenPrograms) {
        try {
          const accounts = await rpcCall(endpoint, program.id, program.filters);
          gotSuccessfulResponse = true;

          for (const owner of uniquePositiveOwners(accounts)) {
            allOwners.add(owner);
          }
        } catch (_) {}
      }

      if (gotSuccessfulResponse && allOwners.size > 0) {
        return allOwners.size;
      }
    }

    throw new Error("No RPC returned holder accounts");
  }

  async function holdersFromGeckoTerminal() {
    const url =
      "https://api.geckoterminal.com/api/v2/networks/solana/tokens/" +
      mint +
      "/info";

    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 8000);

    try {
      const res = await fetch(url, {
        cache: "no-store",
        signal: controller.signal,
        headers: { accept: "application/json" }
      });

      if (!res.ok) throw new Error("GeckoTerminal HTTP " + res.status);
      const json = await res.json();
      const attrs = json && json.data && json.data.attributes;

      const possible = [
        attrs && attrs.holders && attrs.holders.count,
        attrs && attrs.holder_count,
        attrs && attrs.holders_count
      ];

      for (const value of possible) {
        const n = Number(value);
        if (Number.isFinite(n) && n > 0) return n;
      }

      throw new Error("No holder count in GeckoTerminal response");
    } finally {
      clearTimeout(timer);
    }
  }

  async function fetchHolders() {
    holdersEl.textContent = "--";
    holdersEl.classList.add("loading");

    try {
      const total = await holdersFromGeckoTerminal();
      setHolders(compactNumber(total));
      return;
    } catch (_) {}

    try {
      const total = await holdersFromOnChainRpc();
      setHolders(compactNumber(total));
      return;
    } catch (err) {
      console.warn("GIGA holder count unavailable:", err);
    }

    setHolders("--");
  }
'''.strip("\n")

needle = "  async function fetchHolders() {"
start = html.find(needle)
if start == -1:
    raise SystemExit("ERROR: existing fetchHolders() function was not found in index.html")

brace_start = html.find("{", start)
if brace_start == -1:
    raise SystemExit("ERROR: fetchHolders() opening brace not found")

depth = 0
end_pos = None
in_single = False
in_double = False
in_template = False
escape = False

for i in range(brace_start, len(html)):
    ch = html[i]

    if escape:
        escape = False
        continue

    if ch == "\\" and (in_single or in_double or in_template):
        escape = True
        continue

    if not in_double and not in_template and ch == "'":
        in_single = not in_single
        continue
    if not in_single and not in_template and ch == '"':
        in_double = not in_double
        continue
    if not in_single and not in_double and ch == "`":
        in_template = not in_template
        continue

    if in_single or in_double or in_template:
        continue

    if ch == "{":
        depth += 1
    elif ch == "}":
        depth -= 1
        if depth == 0:
            end_pos = i + 1
            break

if end_pos is None:
    raise SystemExit("ERROR: could not determine end of fetchHolders()")

html = html[:start] + new_code + html[end_pos:]

if "setInterval(fetchHolders, 60000);" not in html:
    html = html.replace(
        "  fetchHolders();",
        "  fetchHolders();\n  setInterval(fetchHolders, 60000);",
        1
    )

marker = "<!-- GIGA_HOLDERS_FIX_V14 -->"
if marker not in html:
    html = html.replace("<body>", "<body>\n  " + marker, 1)

p.write_text(html)
PY

echo
echo "GIGA CAT holders fix v14 installed successfully."
echo "Backup: $BACKUP"
echo
echo "Holder logic now:"
echo "  1. GeckoTerminal holder snapshot when available"
echo "  2. Direct Solana on-chain holder counting fallback"
echo "  3. Zero token balances ignored"
echo "  4. Wallet owners deduplicated"
echo "  5. Refresh every 60 seconds"
echo
echo "No API key is required."
echo "No server restart was performed."
echo
grep -nE 'GIGA_HOLDERS_FIX_V14|holdersFromOnChainRpc|holdersFromGeckoTerminal|setInterval\(fetchHolders' "$INDEX" | head -n 30 || true
