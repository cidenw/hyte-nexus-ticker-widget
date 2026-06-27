// Vercel serverless function — same origin, no CORS issues
const PROXY_BASE = '/api/quote?ticker=';

// Preset accent swatches
const COLOR_PRESETS = ['#3b82f6', '#8b5cf6', '#ec4899', '#f97316', '#22c55e', '#06b6d4', '#f59e0b', '#ffffff'];

// --- Color utilities ---
function hexToHsl(hex) {
  let r = parseInt(hex.slice(1, 3), 16) / 255;
  let g = parseInt(hex.slice(3, 5), 16) / 255;
  let b = parseInt(hex.slice(5, 7), 16) / 255;
  const max = Math.max(r, g, b), min = Math.min(r, g, b);
  let h, s, l = (max + min) / 2;
  if (max === min) { h = s = 0; }
  else {
    const d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    switch (max) {
      case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6; break;
      case g: h = ((b - r) / d + 2) / 6; break;
      case b: h = ((r - g) / d + 4) / 6; break;
    }
  }
  return [Math.round(h * 360), Math.round(s * 100), Math.round(l * 100)];
}

function applyOpacity(pct) {
  const a = (pct / 100).toFixed(2);
  document.documentElement.style.setProperty('--bg-alpha', a);
  document.documentElement.style.setProperty('--surface-alpha', a);
}

function applyAccentColor(hex) {
  const [h, s] = hexToHsl(hex);
  const root = document.documentElement;
  root.style.setProperty('--accent', hex);
  const isDark = document.documentElement.getAttribute('data-theme') !== 'light';
  if (isDark) {
    root.style.setProperty('--bg',      `hsl(${h},${Math.min(s, 20)}%,6%)`);
    root.style.setProperty('--surface', `hsl(${h},${Math.min(s, 15)}%,11%)`);
    root.style.setProperty('--border',  `hsl(${h},${Math.min(s, 12)}%,20%)`);
  } else {
    root.style.setProperty('--bg',      `hsl(${h},${Math.min(s, 15)}%,95%)`);
    root.style.setProperty('--surface', `hsl(${h},${Math.min(s, 10)}%,100%)`);
    root.style.setProperty('--border',  `hsl(${h},${Math.min(s, 10)}%,85%)`);
  }
}

// --- Config resolution ---
let CFG = {};

async function loadConfig() {
  try {
    const res = await fetch('./config.json');
    CFG = await res.json();
  } catch {
    CFG = { tickers: ['VWRA.L', 'VOO', 'SPY'], refreshSeconds: 60, theme: 'dark', showChange: true, showName: true };
  }

  // localStorage next (user's saved preferences)
  try {
    const saved = JSON.parse(localStorage.getItem('tickerCfg') || '{}');
    Object.assign(CFG, saved);
  } catch {}

  // URL params last — always override everything so the Nexus URL is the source of truth
  const p = new URLSearchParams(location.search);
  if (p.has('tickers'))    CFG.tickers        = p.get('tickers').split(',').map(t => t.trim()).filter(Boolean);
  if (p.has('refresh'))    CFG.refreshSeconds  = parseInt(p.get('refresh'), 10) || CFG.refreshSeconds;
  if (p.has('theme'))      CFG.theme           = p.get('theme');
  if (p.has('timezone'))   CFG.timezone        = p.get('timezone');
  if (p.has('showChange')) CFG.showChange      = p.get('showChange') !== 'false';
  if (p.has('showName'))   CFG.showName        = p.get('showName') !== 'false';
  if (p.has('accent'))     CFG.accentColor     = p.get('accent');
  if (p.has('opacity'))    CFG.opacity         = parseInt(p.get('opacity'), 10);

  applyTheme(CFG.theme);
  if (CFG.accentColor) applyAccentColor(CFG.accentColor);
  applyOpacity(CFG.opacity ?? 100);
}

function saveCfgToStorage(patch) {
  try {
    const saved = JSON.parse(localStorage.getItem('tickerCfg') || '{}');
    Object.assign(saved, patch);
    localStorage.setItem('tickerCfg', JSON.stringify(saved));
  } catch {}
}

function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme === 'light' ? 'light' : 'dark');
  if (CFG.accentColor) applyAccentColor(CFG.accentColor);
}

// --- Data fetching ---
let lastQuotes = {};

async function fetchOneTicker(ticker) {
  const url = `${PROXY_BASE}${encodeURIComponent(ticker)}`;
  const res = await fetch(url, { cache: 'no-store' });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const json = await res.json();
  const result = json?.chart?.result?.[0];
  if (!result) throw new Error('No data');
  const meta = result.meta;
  const price = meta.regularMarketPrice;
  const prev  = meta.chartPreviousClose ?? meta.previousClose ?? price;
  const change = price - prev;
  const changePct = prev !== 0 ? (change / prev) * 100 : 0;
  return {
    symbol: meta.symbol,
    name: meta.longName || meta.shortName || '',
    price, change, changePct,
    currency: meta.currency || '',
    time: formatTime(meta.regularMarketTime * 1000),
    stale: false,
  };
}

async function fetchQuotes() {
  const results = await Promise.allSettled(CFG.tickers.map(fetchOneTicker));
  let anyError = false;

  results.forEach((r, i) => {
    const key = CFG.tickers[i].toUpperCase();
    if (r.status === 'fulfilled') {
      lastQuotes[key] = r.value;
    } else {
      anyError = true;
      if (lastQuotes[key]) lastQuotes[key].stale = true;
      console.warn(`Failed to fetch ${key}:`, r.reason);
    }
  });

  setStatus(anyError ? 'Some tickers failed to load. Showing last known data.' : '');
  renderTickers();
  document.getElementById('last-update').textContent = 'Updated ' + new Date().toLocaleTimeString();
}

// --- Rendering ---
function renderTickers() {
  const list = document.getElementById('ticker-list');
  list.innerHTML = '';

  CFG.tickers.forEach(ticker => {
    const key = ticker.toUpperCase();
    const q   = lastQuotes[key];
    const card = document.createElement('div');
    card.className = 'ticker-card' + (q?.stale ? ' stale' : '');

    if (!q) {
      card.innerHTML = `
        <div class="ticker-top"><span class="ticker-symbol">${ticker}</span></div>
        <div class="ticker-bottom"><span class="ticker-price loading">—</span></div>`;
    } else {
      const pos = q.change >= 0;
      card.innerHTML = `
        <div class="ticker-top">
          <span class="ticker-symbol">${q.symbol}</span>
          ${CFG.showName && q.name ? `<span class="ticker-name">${q.name}</span>` : ''}
        </div>
        <div class="ticker-bottom">
          <span class="ticker-price">${formatPrice(q.price)}</span>
          ${CFG.showChange ? `<span class="ticker-change ${pos ? 'pos' : 'neg'}">
            ${pos ? '+' : ''}${q.change.toFixed(2)} (${pos ? '+' : ''}${q.changePct.toFixed(2)}%)
          </span>` : ''}
        </div>
        <div class="ticker-meta">${q.currency} · ${q.time}${q.stale ? ' · stale' : ''}</div>`;
    }

    list.appendChild(card);
  });
}

function formatPrice(n) {
  if (n >= 1000) return n.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  if (n >= 1)    return n.toFixed(2);
  return n.toFixed(4);
}

function formatTime(ms) {
  const tz = CFG.timezone || undefined;
  try {
    return new Date(ms).toLocaleTimeString(undefined, { timeZone: tz, hour: '2-digit', minute: '2-digit' });
  } catch {
    return new Date(ms).toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' });
  }
}

function setStatus(msg) {
  const el = document.getElementById('status');
  el.textContent = msg;
  el.style.display = msg ? '' : 'none';
}

// --- Settings panel ---
// --- Settings helpers ---

const REFRESH_STEPS = [10, 15, 30, 60, 120, 300, 600];

function buildSwatches() {
  const container = document.getElementById('color-swatches');
  container.innerHTML = '';
  const current = CFG.accentColor || '#3b82f6';
  COLOR_PRESETS.forEach(hex => {
    const s = document.createElement('button');
    s.className = 'swatch' + (hex === current ? ' active' : '');
    s.style.background = hex;
    s.title = hex;
    s.addEventListener('click', () => {
      document.getElementById('settings-accent').value = hex;
      container.querySelectorAll('.swatch').forEach(el => el.classList.remove('active'));
      s.classList.add('active');
    });
    container.appendChild(s);
  });
  document.getElementById('settings-accent').addEventListener('input', e => {
    container.querySelectorAll('.swatch').forEach(el => {
      el.classList.toggle('active', el.title === e.target.value);
    });
  });
}

function buildTickerChips() {
  const el = document.getElementById('settings-ticker-chips');
  el.innerHTML = '';
  CFG.tickers.forEach((t, i) => {
    const chip = document.createElement('span');
    chip.className = 'ticker-chip';
    chip.innerHTML = `${t}<button class="chip-remove" aria-label="Remove ${t}" data-index="${i}">&times;</button>`;
    el.appendChild(chip);
  });
  el.querySelectorAll('.chip-remove').forEach(btn => {
    btn.addEventListener('click', () => {
      CFG.tickers.splice(Number(btn.dataset.index), 1);
      buildTickerChips();
    });
  });
}

function addTicker() {
  const input = document.getElementById('ticker-add-input');
  const symbols = input.value.split(/[\s,]+/).map(s => s.trim().toUpperCase()).filter(Boolean);
  symbols.forEach(s => { if (!CFG.tickers.includes(s)) CFG.tickers.push(s); });
  input.value = '';
  buildTickerChips();
}

function formatRefresh(s) {
  return s >= 60 ? `${s / 60} min` : `${s} sec`;
}

function updateRefreshDisplay() {
  document.getElementById('refresh-display').textContent = formatRefresh(CFG.refreshSeconds);
}

function updateThemeToggle(theme) {
  document.querySelectorAll('#theme-toggle .toggle-btn').forEach(b => {
    b.classList.toggle('active', b.dataset.value === theme);
  });
}

function buildCopyUrl() {
  const accent  = document.getElementById('settings-accent').value;
  const theme   = document.querySelector('#theme-toggle .toggle-btn.active')?.dataset.value || CFG.theme;
  const showChange = document.getElementById('settings-showchange').checked;
  const showName   = document.getElementById('settings-showname').checked;

  const base = `${location.origin}${location.pathname}`;
  const p = new URLSearchParams({
    tickers:    CFG.tickers.join(','),
    refresh:    CFG.refreshSeconds,
    theme,
    showChange,
    showName,
  });
  if (CFG.timezone) p.set('timezone', CFG.timezone);
  if (accent && accent !== '#3b82f6') p.set('accent', accent);
  if (CFG.opacity != null && CFG.opacity !== 100) p.set('opacity', CFG.opacity);
  return `${base}?${p.toString()}`;
}

function openSettings() {
  document.getElementById('settings-panel').classList.add('open');
  document.getElementById('settings-accent').value        = CFG.accentColor || '#3b82f6';
  document.getElementById('settings-showchange').checked  = CFG.showChange !== false;
  document.getElementById('settings-showname').checked    = CFG.showName  !== false;
  const opacityVal = CFG.opacity ?? 100;
  document.getElementById('settings-opacity').value       = opacityVal;
  document.getElementById('opacity-value').textContent    = `${opacityVal}%`;
  document.getElementById('copy-url-label').textContent   = 'Copy Nexus URL';
  buildTickerChips();
  updateRefreshDisplay();
  updateThemeToggle(CFG.theme);
  buildSwatches();
}

function closeSettings() {
  document.getElementById('settings-panel').classList.remove('open');
}

function saveSettings() {
  const theme      = document.querySelector('#theme-toggle .toggle-btn.active')?.dataset.value || CFG.theme;
  const accentColor = document.getElementById('settings-accent').value;
  const showChange  = document.getElementById('settings-showchange').checked;
  const showName    = document.getElementById('settings-showname').checked;

  const opacity = parseInt(document.getElementById('settings-opacity').value, 10);
  CFG.opacity = opacity;
  applyOpacity(opacity);
  const patch = { tickers: CFG.tickers, theme, accentColor, showChange, showName, refreshSeconds: CFG.refreshSeconds, opacity };
  Object.assign(CFG, patch);
  saveCfgToStorage(patch);
  applyTheme(theme);
  if (accentColor) applyAccentColor(accentColor);
  closeSettings();
  resetTimer();
  fetchQuotes();
}

// --- Timer ---
let timer = null;

function resetTimer() {
  if (timer) clearInterval(timer);
  timer = setInterval(() => {
    if (!document.hidden) fetchQuotes();
  }, (CFG.refreshSeconds || 60) * 1000);
}

// --- Boot ---
async function init() {
  await loadConfig();

  const refreshBtn = document.getElementById('refresh-btn');
  refreshBtn.addEventListener('click', () => {
    refreshBtn.classList.add('spinning');
    refreshBtn.addEventListener('animationend', () => refreshBtn.classList.remove('spinning'), { once: true });
    fetchQuotes();
  });

  document.getElementById('gear-btn').addEventListener('click', openSettings);
  document.getElementById('settings-close').addEventListener('click', closeSettings);
  document.getElementById('settings-save').addEventListener('click', saveSettings);
  document.getElementById('settings-overlay').addEventListener('click', closeSettings);

  // Refresh stepper
  document.getElementById('refresh-minus').addEventListener('click', () => {
    const idx = REFRESH_STEPS.indexOf(CFG.refreshSeconds);
    if (idx > 0) { CFG.refreshSeconds = REFRESH_STEPS[idx - 1]; updateRefreshDisplay(); }
  });
  document.getElementById('refresh-plus').addEventListener('click', () => {
    const idx = REFRESH_STEPS.indexOf(CFG.refreshSeconds);
    if (idx < REFRESH_STEPS.length - 1) { CFG.refreshSeconds = REFRESH_STEPS[idx + 1]; updateRefreshDisplay(); }
    else if (idx === -1) { CFG.refreshSeconds = 60; updateRefreshDisplay(); }
  });

  // Theme toggle
  document.querySelectorAll('#theme-toggle .toggle-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      updateThemeToggle(btn.dataset.value);
      applyTheme(btn.dataset.value);
    });
  });

  // Opacity slider live preview
  document.getElementById('settings-opacity').addEventListener('input', e => {
    const v = parseInt(e.target.value, 10);
    document.getElementById('opacity-value').textContent = `${v}%`;
    applyOpacity(v);
  });

  // Add ticker
  document.getElementById('ticker-add-btn').addEventListener('click', addTicker);
  document.getElementById('ticker-add-input').addEventListener('keydown', e => {
    if (e.key === 'Enter') { e.preventDefault(); addTicker(); }
  });

  // Ticker directory collapsible
  document.getElementById('ticker-dir-toggle').addEventListener('click', () => {
    const body = document.getElementById('ticker-dir');
    const btn  = document.getElementById('ticker-dir-toggle');
    const open = body.hidden;
    body.hidden = !open;
    btn.setAttribute('aria-expanded', open);
    btn.classList.toggle('open', open);
  });

  // Copy URL
  document.getElementById('copy-url-btn').addEventListener('click', () => {
    const url = buildCopyUrl();
    navigator.clipboard.writeText(url).then(() => {
      document.getElementById('copy-url-label').textContent = 'Copied!';
      setTimeout(() => document.getElementById('copy-url-label').textContent = 'Copy Nexus URL', 2000);
    }).catch(() => {
      document.getElementById('copy-url-label').textContent = url;
    });
  });

  await fetchQuotes();
  resetTimer();

  document.addEventListener('visibilitychange', () => {
    if (!document.hidden) fetchQuotes();
  });
}

init();
