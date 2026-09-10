#!/usr/bin/env node
/**
 * Minimal JSON-RPC proxy that rewrites EIP-1898 block references
 * (`{ blockHash, requireCanonical }`) into plain block tags.
 *
 * Foundry pins a fork by block hash and then issues calls such as
 * `eth_getTransactionCount(addr, { blockHash })`. Some chains (Somnia, at least)
 * only accept plain block numbers or tags and answer `-32602 invalid parameters`,
 * which makes `forge script` unusable against them.
 *
 * Usage:
 *   node scripts/eip1898Proxy.mjs <upstream-rpc-url> [port]
 *   forge script ... --rpc-url http://127.0.0.1:8545
 */
import http from "node:http";

const UPSTREAM = process.argv[2];
const PORT = Number(process.argv[3] ?? 8545);

if (!UPSTREAM) {
  console.error("usage: node scripts/eip1898Proxy.mjs <upstream-rpc-url> [port]");
  process.exit(1);
}

const hashToTag = new Map();

/** Resolve a block hash to its hex block number, caching the lookup. */
async function resolveBlockHash(hash) {
  if (hashToTag.has(hash)) return hashToTag.get(hash);
  const res = await fetch(UPSTREAM, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ jsonrpc: "2.0", id: 1, method: "eth_getBlockByHash", params: [hash, false] }),
  });
  const body = await res.json();
  const tag = body?.result?.number ?? "latest";
  hashToTag.set(hash, tag);
  return tag;
}

async function rewrite(value) {
  if (Array.isArray(value)) return Promise.all(value.map(rewrite));
  if (value && typeof value === "object") {
    if (
      typeof value.blockHash === "string" &&
      Object.keys(value).every((k) => k === "blockHash" || k === "requireCanonical")
    ) {
      return resolveBlockHash(value.blockHash);
    }
    const out = {};
    for (const [k, v] of Object.entries(value)) out[k] = await rewrite(v);
    return out;
  }
  return value;
}

const server = http.createServer((req, res) => {
  const chunks = [];
  req.on("data", (c) => chunks.push(c));
  req.on("end", async () => {
    let payload = Buffer.concat(chunks).toString("utf8");
    try {
      const parsed = JSON.parse(payload);
      const calls = Array.isArray(parsed) ? parsed : [parsed];
      for (const call of calls) {
        if (call?.params) call.params = await rewrite(call.params);
      }
      payload = JSON.stringify(parsed);
    } catch {
      // pass the body through untouched if it is not JSON we understand
    }

    try {
      const upstream = await fetch(UPSTREAM, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: payload,
      });
      const text = await upstream.text();
      res.writeHead(upstream.status, { "content-type": "application/json" });
      res.end(text);
    } catch (err) {
      res.writeHead(502, { "content-type": "application/json" });
      res.end(JSON.stringify({ jsonrpc: "2.0", id: null, error: { code: -32000, message: String(err) } }));
    }
  });
});

server.listen(PORT, "127.0.0.1", () => {
  console.log(`EIP-1898 rewriting proxy: http://127.0.0.1:${PORT} -> ${UPSTREAM}`);
});
