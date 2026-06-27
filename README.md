# HYTE Nexus Ticker Widget

A stock ticker widget for the **HYTE Y70 Touch Infinite** display running **HYTE Nexus 2.0**.  
Live prices, responsive layout, touch-friendly settings — and a one-click installer.

## How it works on the Y70 Touch Infinite

1. Run the installer (see Quick start).
2. In **HYTE Nexus**, add a **Web / iFrame** widget and paste the URL the installer gives you.
3. Resize the cell — the layout adapts automatically to any size.
4. Tap the **⚙ gear icon** on the display to change tickers, theme, colors, or timezone without touching any files.

## Features

- Live prices via Yahoo Finance — no API key required
- Tracks any Yahoo Finance ticker: ETFs, stocks, indices, crypto
- Adapts to small, medium, or tall Nexus grid cells (CSS container queries)
- Dark / light theme with custom accent color picker
- Configurable timezone for market timestamps (defaults to OS timezone)
- Touch-friendly settings panel with "Start with Windows" toggle
- One-click installer and uninstaller for non-developers

## Quick start

### Option A — Installer (recommended, no tech knowledge required)

```powershell
# Right-click install.ps1 → "Run with PowerShell"
# Or in a terminal:
.\install.ps1
```

The installer will:
- Install Node.js automatically if not present
- Copy the widget to `%LOCALAPPDATA%\Programs\HyteTickerWidget`
- Set up two background services that start with Windows
- Print (and copy to clipboard) the URL to paste into Nexus

### Option B — Manual (developers)

```powershell
# Terminal 1 — proxy server (handles Yahoo Finance CORS)
node proxy.mjs

# Terminal 2 — widget server
node server.mjs
```

Then find your local IP (`ipconfig` → IPv4 Address) and open `http://YOUR_IP:4000`.

> **Why local IP instead of localhost?** HYTE Nexus does not resolve `localhost` in the iframe URL field. Use your PC's local network IP (e.g. `192.168.1.42`).

---

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
| `tickers` | Yahoo Finance ticker symbols | `["VWRA.L","VOO","SPY"]` |
| `refreshSeconds` | Price refresh interval in seconds | `60` |
| `theme` | `"dark"` or `"light"` | `"dark"` |
| `timezone` | IANA timezone (empty = OS local) | `""` |
| `showChange` | Show price change and % | `true` |
| `showName` | Show asset name | `true` |

### URL query params (override config.json)

```
http://192.168.1.42:4000/?tickers=VWRA.L,VOO,SPY&refresh=30&theme=light&timezone=Europe/London
```

### In-widget settings (touch, persisted to localStorage)

Tap **⚙** on the display to change tickers, theme, accent color, timezone, and the Windows startup toggle — no files to edit.

---

## Ticker symbols

Use Yahoo Finance format exactly:

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
  index.html      Widget markup + settings dialog
  styles.css      Responsive styles (CSS container queries)
  app.js          Config, fetch, render, settings, startup toggle
  config.json     Default configuration
  server.mjs      Static file server (port 4000, no external deps)
  proxy.mjs       Yahoo Finance proxy + startup management API (port 4001)
  install.ps1     One-click Windows installer
  uninstall.ps1   One-click Windows uninstaller
  package.json    npm scripts for manual use
  README.md / SETUP.md / UNINSTALL.md
  LICENSE         MIT
```

## License

MIT — see [LICENSE](LICENSE).
