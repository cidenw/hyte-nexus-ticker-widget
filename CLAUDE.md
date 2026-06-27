# ticker-widget

Stock ticker widget for the HYTE Y70 Touch Infinite display via HYTE Nexus 2.0 iframe widget.

## Architecture

- **Frontend**: vanilla JS + CSS, no framework, no build step
- **Backend**: single Vercel serverless function (`api/quote.js`) that proxies Yahoo Finance to avoid CORS
- **Hosting**: Vercel (free tier) — `https://ticker-widget-eight.vercel.app`
- **Repo**: `https://github.com/cidenw/hyte-nexus-ticker-widget`

## Local dev

```
vercel dev --listen 4000
```

Port 3000 is taken by Docker. Always use 4000.

## Deploy

```
vercel --prod --yes
```

Only deploy when the user explicitly says to.

## Data source

Yahoo Finance v8 chart API — no API key needed. Proxied via `api/quote.js` because browsers block direct fetch (CORS).

```
https://query1.finance.yahoo.com/v8/finance/chart/TICKER?interval=1d&range=1d
```

## Config priority (lowest → highest)

1. `config.json` — baked-in defaults
2. `localStorage` — saved from in-widget settings panel
3. URL query params — always win, used for Nexus iframe URL

## Key files

| File | Purpose |
|---|---|
| `api/quote.js` | Vercel serverless proxy for Yahoo Finance |
| `app.js` | Config loading, data fetching, rendering, settings logic |
| `index.html` | Widget markup + settings panel |
| `styles.css` | Layout (CSS container queries), theming, responsive |
| `config.json` | Default tickers/settings |

## Settings panel features

All touch-friendly (no keyboard needed for anything except adding tickers):
- Add/remove tickers with chips + text input
- Refresh interval stepper (no typing)
- Dark/light theme toggle
- Accent color picker + preset swatches
- Background opacity slider (works with Nexus iframe transparency)
- "Copy Nexus URL" button — generates full URL with all settings baked in as params

## Nexus constraints

- Nexus does not resolve `localhost` — must use a public URL (Vercel) or local IP
- Tickers and all settings can be set via URL params pasted into the Nexus widget URL field
- Touch display has no keyboard — settings panel is designed around tap/swipe interactions
- iframe transparency works — Nexus composites the iframe with a transparent background
