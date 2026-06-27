# HYTE Nexus Ticker Widget

A lightweight, open-source stock ticker widget for the **HYTE Y70 Touch Infinite** display running **HYTE Nexus 2.0**. It renders live-ish price quotes in a responsive layout that adapts to any grid cell size you assign in Nexus.

![Widget screenshot placeholder](https://via.placeholder.com/300x400/0d0d0d/22c55e?text=Ticker+Widget)

## Features

- Tracks any ticker available on [Stooq.com](https://stooq.com) (stocks, ETFs, indices)
- No API key required — uses Stooq's free delayed/EOD CSV feed
- Adapts automatically to small, medium, or tall Nexus grid cells (CSS container queries)
- Dark / light theme
- Touch-friendly settings panel — change tickers without redeploying
- Three-layer config: `config.json` → URL params → in-widget touch settings
- Optional built-in local CORS proxy (`proxy.mjs`) for full offline control

## Default tickers

`VWRA.L` (Vanguard FTSE All-World, London), `VOO` (Vanguard S&P 500, US), `SPY` (SPDR S&P 500, US)

## Data source caveat

Data is sourced from **stooq.com** and is typically **delayed 15–20 minutes** or end-of-day. This is not a realtime feed. If you need realtime data, replace `fetchQuotes()` in `app.js` with a call to a keyed API (Finnhub, Polygon, Twelve Data) — the function interface is isolated for exactly this.

## Ticker symbol format

| Exchange | Display ticker | Stooq symbol |
|---|---|---|
| US (default) | `VOO`, `SPY`, `AAPL` | `voo.us`, `spy.us`, `aapl.us` |
| London | `VWRA.L`, `LLOY.L` | `vwra.uk`, `lloy.uk` |
| Frankfurt | `IWDA.DE` | `iwda.de` |
| Amsterdam | `VWRL.AS` | `vwrl.nl` |

The widget auto-converts from display format. Add more suffix mappings in `SUFFIX_MAP` inside `app.js`.

## Configuration

### config.json (defaults)

```json
{
  "tickers": ["VWRA.L", "VOO", "SPY"],
  "refreshSeconds": 60,
  "theme": "dark",
  "corsProxy": "https://corsproxy.io/?url=",
  "showChange": true,
  "showName": true
}
```

| Key | Description | Default |
|---|---|---|
| `tickers` | Array of ticker symbols to display | `["VWRA.L","VOO","SPY"]` |
| `refreshSeconds` | Price refresh interval in seconds | `60` |
| `theme` | `"dark"` or `"light"` | `"dark"` |
| `corsProxy` | CORS proxy prefix (see SETUP.md) | `"https://corsproxy.io/?url="` |
| `showChange` | Show price change and % | `true` |
| `showName` | Show asset name below symbol | `true` |

### URL query params (override config.json)

Append to the widget URL in the Nexus iframe field:

```
http://localhost:3000/?tickers=VWRA.L,VOO,SPY&refresh=30&theme=light
```

| Param | Example |
|---|---|
| `tickers` | `VWRA.L,VOO,SPY` |
| `refresh` | `30` (seconds) |
| `theme` | `light` or `dark` |
| `proxy` | `https://corsproxy.io/?url=` or empty |
| `showChange` | `true` / `false` |
| `showName` | `true` / `false` |

### In-widget settings panel (override everything, persisted)

Tap the ⚙ gear icon on the widget to open a touch-friendly panel. Settings are saved to `localStorage` and survive refreshes.

## Project structure

```
ticker-widget/
  index.html     # Widget markup
  styles.css     # Responsive styles (CSS container queries)
  app.js         # Config, fetch, CSV parse, render, settings
  config.json    # Default configuration
  proxy.mjs      # Optional local CORS proxy (Node.js, no deps)
  package.json   # npm scripts: serve, proxy
  README.md
  SETUP.md
  UNINSTALL.md
  LICENSE        # MIT
```

## License

MIT — see [LICENSE](LICENSE).
