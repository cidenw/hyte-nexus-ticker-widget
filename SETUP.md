# Setup Guide

## Prerequisites

- [Node.js](https://nodejs.org/) v18+ installed on the PC driving the Y70 Touch Infinite
- HYTE Nexus 2.0 installed and your Y70ti display detected

---

## Step 1 — Download the widget

```powershell
git clone https://github.com/YOUR_USERNAME/hyte-nexus-ticker-widget.git C:\widgets\ticker-widget
cd C:\widgets\ticker-widget
```

---

## Step 2 — Start both servers

You need two terminals running side by side.

**Terminal 1 — widget server:**
```powershell
npx serve . -p 4000
```

**Terminal 2 — local proxy** (handles Yahoo Finance CORS):
```powershell
node proxy.mjs
```

Leave both terminals open. The widget is now at `http://localhost:4000`.

---

## Step 3 — Add the widget to HYTE Nexus

1. Open **HYTE Nexus** on your PC.
2. Go to your Y70ti display layout and click **+ Add widget**.
3. Select **Web** (or **iFrame / URL**) as the widget type.
4. Paste the URL:
   ```
   http://localhost:4000
   ```
5. Resize the widget cell to your preference — the layout adapts automatically:
   - **Narrow cell** → symbol + price only
   - **Standard cell** → symbol, name, price, change
   - **Tall cell** → all info + market timestamps

---

## Step 4 — Customize tickers

**Touch the ⚙ gear icon** on the widget to open the settings panel. You can change tickers, refresh interval, theme, and timezone directly from the display. Settings persist across restarts.

**Via URL params** — edit the Nexus URL field directly:
```
http://localhost:4000/?tickers=VWRA.L,VOO,SPY,BTC-USD&refresh=30&theme=light
```

**Via config.json** — edit the file and refresh the widget.

---

## Step 5 — Run on startup (optional)

To start both servers automatically when Windows boots, use Task Scheduler:

1. Open **Task Scheduler** → Create Basic Task.
2. Trigger: **At log on**.
3. Action: **Start a program**
   - Program: `node`
   - Arguments: `C:\widgets\ticker-widget\proxy.mjs`
4. Repeat for the widget server, using:
   - Program: `npx`
   - Arguments: `serve C:\widgets\ticker-widget -p 4000`

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Widget shows `—` forever | Make sure both servers are running (ports 4000 and 4001) |
| CORS error in browser console | `proxy.mjs` is not running — start it with `node proxy.mjs` |
| `proxy.mjs` port 4001 already in use | Change `PORT` in `proxy.mjs` and update `PROXY_BASE` in `app.js` to match |
| Ticker not found / wrong price | Verify the symbol on [finance.yahoo.com](https://finance.yahoo.com) — use the exact Yahoo symbol |
| Timestamps in wrong timezone | Open ⚙ settings and enter your timezone, e.g. `Europe/London` |
| Port 4000 already in use | Change `-p 4000` in the serve command and update the Nexus URL |
