// Local proxy server — run with: node proxy.mjs
// Forwards /proxy?ticker=SPY to Yahoo Finance, adding CORS headers.
import http from 'http';
import https from 'https';

const PORT = 4001;
const ALLOWED_HOST = 'query1.finance.yahoo.com';

http.createServer((req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  const ticker = url.searchParams.get('ticker');

  if (!ticker) {
    res.writeHead(400, corsHeaders()); res.end('Missing ?ticker='); return;
  }

  const target = `https://${ALLOWED_HOST}/v8/finance/chart/${encodeURIComponent(ticker)}?interval=1d&range=1d`;

  https.get(target, { headers: { 'User-Agent': 'Mozilla/5.0' } }, upstream => {
    res.writeHead(upstream.statusCode, { ...corsHeaders(), 'Content-Type': 'application/json', 'Cache-Control': 'no-store' });
    upstream.pipe(res);
  }).on('error', e => { res.writeHead(502, corsHeaders()); res.end(JSON.stringify({ error: e.message })); });
}).listen(PORT, () => console.log(`Proxy running on http://localhost:${PORT}`));

function corsHeaders() {
  return { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Methods': 'GET' };
}
