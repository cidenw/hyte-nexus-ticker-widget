# HYTE Nexus Ticker Widget

A lightweight, open-source stock ticker widget for the **HYTE Y70 Touch Infinite** display running **HYTE Nexus 2.0**. It renders live prices in a responsive layout that adapts to any grid cell size you assign in Nexus.

## Features

- Live prices via Yahoo Finance — no API key required
- Tracks any ticker Yahoo supports: ETFs, stocks, indices (`^GSPC`, `^NDX`)
- Responsive layout via CSS container queries — adapts from a tiny cell to a tall column
- Dark / light theme
- Configurable timezone for market timestamps (defaults to your OS timezone)
- Touch-friendly settings panel — change tickers without redeploying
- Three-layer config: `config.json` → URL params → in-widget touch settings

## How it works on the Y70 Touch Infinite

1. Run the two servers on your PC (see Quick start below).
2. In **HYTE Nexus**, add a **Web / iFrame** widget and paste `http://localhost:4000` as the URL.
3. Resize the cell on the display — the widget layout adapts automatically.
4. Tap the **⚙ gear icon** directly on the display to change tickers, theme, or timezone without touching any files.

See [SETUP.md](SETUP.md) for step-by-step Nexus instructions and startup automation.

---

## Default tickers

`VWRA.L` · `VOO` · `SPY`

## Quick start

```powershell
git clone https://github.com/YOUR_USERNAME/hyte-nexus-ticker-widget.git
cd hyte-nexus-ticker-widget

# Terminal 1 — serve the widget
npx serve . -p 4000

# Terminal 2 — local proxy (required, handles Yahoo Finance CORS)
node proxy.mjs
```

Then open `http://localhost:4000` in a browser to verify it works.

> **Nexus URL:** Use your PC's local IP instead of `localhost` — Nexus doesn't resolve it.
> Find it with `ipconfig` (look for IPv4 Address), e.g. `http://192.168.1.42:4000`.

See [SETUP.md](SETUP.md) for full Nexus integration steps.

## Configuration

### config.json (defaults)

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

| Key | Description | Default |
|---|---|---|
| `tickers` | Array of Yahoo Finance ticker symbols | `["VWRA.L","VOO","SPY"]` |
| `refreshSeconds` | Price refresh interval in seconds | `60` |
| `theme` | `"dark"` or `"light"` | `"dark"` |
| `timezone` | IANA timezone string for timestamps. Empty = OS local | `""` |
| `showChange` | Show price change and % | `true` |
| `showName` | Show asset name | `true` |

### URL query params (override config.json)

Append to the Nexus iframe URL:

```
http://localhost:4000/?tickers=VWRA.L,VOO,SPY&refresh=30&theme=light&timezone=Europe/London
```

| Param | Example |
|---|---|
| `tickers` | `VWRA.L,VOO,SPY` |
| `refresh` | `30` |
| `theme` | `light` or `dark` |
| `timezone` | `Europe/London`, `America/New_York` |
| `showChange` | `true` / `false` |
| `showName` | `true` / `false` |

### In-widget settings panel

Tap the ⚙ gear icon to open a touch-friendly panel. All settings are saved to `localStorage` and persist across refreshes.

## Ticker symbols

Use Yahoo Finance symbol format exactly:

| Asset | Symbol |
|---|---|
| US ETFs / stocks | `VOO`, `SPY`, `AAPL` |
| London-listed | `VWRA.L`, `VWRL.L` |
| Indices | `^GSPC`, `^NDX`, `^FTSE` |
| Crypto | `BTC-USD`, `ETH-USD` |

## Architecture

```
ticker-widget/
  index.html     # Widget markup + settings dialog
  styles.css     # Responsive styles (CSS container queries)
  app.js         # Config resolution, fetch, render, settings
  config.json    # Default configuration
  proxy.mjs      # Local proxy — forwards requests to Yahoo Finance (avoids CORS)
  package.json   # npm scripts: serve, proxy
  README.md
  SETUP.md
  UNINSTALL.md
  LICENSE        # MIT
```

**Why a local proxy?** Browsers block direct `fetch()` calls to Yahoo Finance due to CORS restrictions. `proxy.mjs` is a minimal Node.js server that forwards requests server-side and adds the required CORS headers. It only allowlists `query1.finance.yahoo.com`.

## License

MIT — see [LICENSE](LICENSE).
