# Setup Guide

## The easy way — Installer

1. Download or clone this repo to your PC.
2. Right-click **`install.ps1`** → **"Run with PowerShell"**.
   - If you see a blue security prompt, click **"Run anyway"** (or **"More info" → "Run anyway"**).
3. The installer will:
   - Install Node.js automatically if it's not already on your PC
   - Copy the widget files to `%LOCALAPPDATA%\Programs\HyteTickerWidget`
   - Create two background services that start silently with Windows
   - Start both services immediately
   - Print your URL and copy it to the clipboard
4. Open **HYTE Nexus**, add a **Web** / **iFrame** widget, and paste the URL.
5. Done — resize the cell and use the ⚙ gear icon to customise.

---

## Step by step (manual, for developers)

### Prerequisites

- [Node.js](https://nodejs.org/) v18+ on the PC driving the Y70 Touch Infinite
- HYTE Nexus 2.0 installed and your Y70ti display detected

### 1 — Start the proxy server

```powershell
node proxy.mjs
```

Leave this terminal open. The proxy fetches Yahoo Finance data server-side (required to avoid browser CORS restrictions) and also handles the "Start with Windows" toggle in the settings panel.

### 2 — Start the widget server

In a second terminal:

```powershell
node server.mjs
```

### 3 — Find your local IP

HYTE Nexus does not resolve `localhost` in iframe URLs. You need your PC's network IP:

```powershell
ipconfig
```

Look for **IPv4 Address** under your active adapter (Wi-Fi or Ethernet), e.g. `192.168.1.42`.

### 4 — Add to HYTE Nexus

1. Open **HYTE Nexus** → your Y70ti layout → **+ Add widget**.
2. Select **Web** (or **iFrame / URL**) widget type.
3. Paste the URL using your local IP:
   ```
   http://192.168.1.42:4000
   ```
4. Resize the cell — the layout adapts automatically:
   - **Narrow** → symbol + price only
   - **Standard** → symbol, name, price, change
   - **Tall** → all info + market timestamps

### 5 — Customise

Tap the **⚙ gear icon** on the widget to open the settings panel:
- Add or remove tickers (one per line, use Yahoo Finance symbols)
- Change refresh interval, theme, accent color, timezone
- Toggle **"Start with Windows"** (only works when installed via `install.ps1`)

---

## Run on startup (manual, without installer)

Use Task Scheduler to run both servers at login with no visible window:

1. Open **Task Scheduler** → **Create Basic Task**.
2. Trigger: **At log on** (current user only).
3. Action: **Start a program**
   - Program: `node` (full path, e.g. `C:\Program Files\nodejs\node.exe`)
   - Arguments: `"C:\path\to\ticker-widget\proxy.mjs"`
4. In **Properties → Settings**: uncheck "Stop task if it runs longer than".
5. Repeat for `server.mjs` with a 5-second delay.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Widget shows `—` forever | Make sure both servers are running (ports 4000 and 4001) |
| CORS error | `proxy.mjs` not running — start it with `node proxy.mjs` |
| Nexus shows blank / won't load | Use your local IP, not `localhost` |
| "Start with Windows" greyed out | Run `install.ps1` first to register the scheduled tasks |
| Port already in use | Change `PORT` in `server.mjs` / `PROXY_PORT` in `proxy.mjs` and update Nexus URL |
| Wrong timezone on timestamps | Open ⚙ settings → enter IANA timezone e.g. `Europe/London` |
| PowerShell blocked by policy | Run: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` then retry |
