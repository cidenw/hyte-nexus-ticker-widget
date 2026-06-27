# HYTE Nexus Ticker Widget

A stock ticker widget for the **HYTE Y70 Touch Infinite** display running **HYTE Nexus 2.0**.  
Live prices, responsive layout, touch-friendly settings — and a one-click installer.

**No Node.js or third-party software required.** The server runs on PowerShell, which is built into every Windows 11 PC.

---

## How it works on the Y70 Touch Infinite

1. Run the installer (see below).
2. In **HYTE Nexus**, add a **Web / iFrame** widget and paste the URL the installer gives you.
3. Resize the cell — the layout adapts automatically to any size.
4. Tap the **⚙ gear icon** on the display to change tickers, theme, colors, or timezone.

---

## Installation

### For everyone (no technical knowledge needed)

1. [Download the zip](../../archive/refs/heads/master.zip) and extract it anywhere.
2. Right-click **`install.ps1`** → **Run with PowerShell**.
   - If Windows shows a blue security prompt, click **More info → Run anyway**.
3. The installer prints a URL like `http://192.168.1.42:4000` and copies it to your clipboard.
4. Open HYTE Nexus → add a **Web** widget → paste the URL.

That's it. The widget starts automatically every time Windows logs in — no terminal windows, no manual steps.

### For developers (manual run)

```powershell
powershell -File widget.ps1
```

Then use `http://YOUR_LOCAL_IP:4000` in Nexus (`ipconfig` → IPv4 Address).

---

## Uninstall

Right-click **`uninstall.ps1`** → **Run with PowerShell**.  
Then remove the widget from HYTE Nexus manually.

---

## Features

- Live prices via Yahoo Finance — no API key required
- Any Yahoo Finance ticker: ETFs, stocks, indices (`^GSPC`), crypto (`BTC-USD`)
- Adapts to any Nexus grid cell size (CSS container queries)
- Dark / light theme with custom accent color picker
- Configurable timezone for timestamps (defaults to OS local time)
- Touch-friendly settings panel with **"Start with Windows"** toggle
- Pure PowerShell backend — nothing to install

---

## Configuration

### config.json

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
| `refreshSeconds` | Refresh interval in seconds | `60` |
| `theme` | `"dark"` or `"light"` | `"dark"` |
| `timezone` | IANA timezone string, empty = OS local | `""` |
| `showChange` | Show price change and % | `true` |
| `showName` | Show asset name | `true` |

### URL query params (override config.json)

```
http://192.168.1.42:4000/?tickers=VWRA.L,VOO,SPY&theme=light&timezone=Europe/London
```

### In-widget settings (tap ⚙, persisted across restarts)

Change tickers, theme, accent color, timezone, and auto-start toggle directly from the display.

---

## Ticker symbols

Use Yahoo Finance format:

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
  app.js          Config, fetch, render, settings logic
  config.json     Default configuration
  widget.ps1      PowerShell server — static files + Yahoo Finance proxy + startup API
  install.ps1     One-click installer (no Node.js needed)
  uninstall.ps1   One-click uninstaller
  README.md / SETUP.md / UNINSTALL.md
  LICENSE         MIT
```

## License

MIT — see [LICENSE](LICENSE).
