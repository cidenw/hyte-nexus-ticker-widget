# HYTE Nexus Ticker Widget

A stock ticker widget for the **HYTE Y70 Touch Infinite** display running **HYTE Nexus 2.0**.  
Hosted on Vercel — no installation, no local server, nothing to maintain.

---

## Setup (3 steps)

### 1 — Deploy your own instance

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/cidenw/hyte-nexus-ticker-widget)

Click the button, sign in with GitHub, and Vercel deploys it in ~30 seconds.  
You get a URL like `https://hyte-nexus-ticker-widget.vercel.app`.

> **Why your own instance?** The widget's serverless function proxies Yahoo Finance from Vercel's servers. Each user should deploy their own so they're not sharing bandwidth limits.

### 2 — Add to HYTE Nexus

1. Open **HYTE Nexus** → Y70ti display layout → **+ Add widget**
2. Choose **Web** / **iFrame** widget type
3. Paste your Vercel URL
4. Resize the cell to your liking — the layout adapts automatically

### 3 — Customise

Tap the **⚙ gear icon** directly on the display to change tickers, theme, colors, and timezone. Settings save to the widget's local storage and persist across restarts.

---

## Features

- Live prices via Yahoo Finance — no API key needed
- Any Yahoo Finance symbol: ETFs, stocks, indices (`^GSPC`), crypto (`BTC-USD`)
- Adapts to any Nexus grid cell size (CSS container queries)
- Dark / light theme with custom accent color picker
- Configurable timezone (defaults to your OS local time)
- Touch-friendly settings panel

---

## Configuration

### config.json (baked-in defaults)

```json
{
  "tickers": ["VWRA.L", "VOO", "SPY"],
  "refreshSeconds": 60,
  "theme": "dark",
  "timezone": "",
  "showChange": true,
  "showName": true
}
```

Fork the repo, edit this file, and redeploy to change defaults permanently.

### URL query params (override config.json)

Append to the Nexus URL field:

```
https://your-app.vercel.app/?tickers=VWRA.L,VOO,SPY&theme=light&timezone=Europe/London
```

| Param | Example |
|---|---|
| `tickers` | `VWRA.L,VOO,SPY,BTC-USD` |
| `refresh` | `30` (seconds) |
| `theme` | `light` or `dark` |
| `timezone` | `Europe/London`, `America/New_York` |
| `showChange` | `true` / `false` |
| `showName` | `true` / `false` |

### In-widget settings (tap ⚙, saved to localStorage)

Change anything without touching the URL or code.

---

## Ticker symbols

| Asset | Symbol |
|---|---|
| US ETFs / stocks | `VOO`, `SPY`, `AAPL` |
| London-listed | `VWRA.L`, `VWRL.L` |
| Indices | `^GSPC`, `^NDX`, `^FTSE` |
| Crypto | `BTC-USD`, `ETH-USD` |

---

## Project structure

```
ticker-widget/
  api/
    quote.js      Vercel serverless function — proxies Yahoo Finance
  index.html      Widget markup + settings dialog
  styles.css      Responsive styles (CSS container queries)
  app.js          Config, fetch, render, settings logic
  config.json     Default configuration
  README.md / SETUP.md / UNINSTALL.md
  LICENSE         MIT
```

---

## License

MIT — see [LICENSE](LICENSE).
