// Local proxy server — run with: node proxy.mjs
// Forwards /proxy?ticker=SPY to Yahoo Finance (avoids browser CORS).
// Also exposes /api/startup for the in-widget auto-start toggle.
import http from 'http';
import https from 'https';
import { exec } from 'child_process';

const PORT = process.env.PROXY_PORT || 4001;
const YAHOO_HOST = 'query1.finance.yahoo.com';
const TASK_NAMES = ['HyteTickerWidget-Server', 'HyteTickerWidget-Proxy'];

// ── Startup management helpers ──────────────────────────────────────────────

function runCmd(cmd) {
  return new Promise((resolve, reject) =>
    exec(cmd, { shell: 'powershell.exe' }, (err, stdout, stderr) =>
      err ? reject(stderr || err.message) : resolve(stdout.trim())
    )
  );
}

async function getStartupEnabled() {
  try {
    const out = await runCmd(`schtasks /Query /TN "${TASK_NAMES[0]}" /FO LIST 2>$null`);
    return out.includes('Ready') || out.includes('Running');
  } catch {
    return false;
  }
}

async function setStartup(enable) {
  const flag = enable ? '/ENABLE' : '/DISABLE';
  for (const name of TASK_NAMES) {
    await runCmd(`schtasks /Change /TN "${name}" ${flag}`).catch(() => {});
  }
}

// ── HTTP server ─────────────────────────────────────────────────────────────

http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);

  // CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, corsHeaders()); res.end(); return;
  }

  // ── Yahoo Finance proxy ──
  if (url.pathname === '/proxy') {
    const ticker = url.searchParams.get('ticker');
    if (!ticker) { res.writeHead(400, corsHeaders()); res.end('Missing ?ticker='); return; }

    const target = `https://${YAHOO_HOST}/v8/finance/chart/${encodeURIComponent(ticker)}?interval=1d&range=1d`;
    https.get(target, { headers: { 'User-Agent': 'Mozilla/5.0' } }, upstream => {
      res.writeHead(upstream.statusCode, { ...corsHeaders(), 'Content-Type': 'application/json', 'Cache-Control': 'no-store' });
      upstream.pipe(res);
    }).on('error', e => { res.writeHead(502, corsHeaders()); res.end(JSON.stringify({ error: e.message })); });
    return;
  }

  // ── Startup status ──
  if (url.pathname === '/api/startup' && req.method === 'GET') {
    const enabled = await getStartupEnabled();
    res.writeHead(200, { ...corsHeaders(), 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ enabled }));
    return;
  }

  // ── Toggle startup ──
  if (url.pathname === '/api/startup' && req.method === 'POST') {
    let body = '';
    req.on('data', d => { body += d; });
    req.on('end', async () => {
      try {
        const { enabled } = JSON.parse(body);
        await setStartup(enabled);
        res.writeHead(200, { ...corsHeaders(), 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ ok: true, enabled }));
      } catch (e) {
        res.writeHead(500, corsHeaders());
        res.end(JSON.stringify({ error: e.toString() }));
      }
    });
    return;
  }

  res.writeHead(404, corsHeaders()); res.end('Not found');

}).listen(PORT, () => console.log(`Proxy running on http://localhost:${PORT}`));

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };
}
