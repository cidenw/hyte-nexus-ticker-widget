# Setup Guide

## Requirements

- Windows 11 (PowerShell is built in — nothing else to install)
- HYTE Nexus 2.0 with your Y70 Touch Infinite connected

---

## Installer (recommended)

1. Download or clone this repo to your PC.
2. Right-click **`install.ps1`** → **Run with PowerShell**.
   - If you see a blue security warning, click **More info → Run anyway**.
3. Wait for the installer to finish — it prints something like:

   ```
   Paste this URL into HYTE Nexus as a Web widget:

      http://192.168.1.42:4000

   (URL copied to clipboard)
   ```

4. Open **HYTE Nexus** on your PC.
5. On the Y70ti layout, click **+ Add widget** → choose **Web** (or **iFrame / URL**).
6. Paste the URL from step 3 into the URL field.
7. Resize the widget cell to your liking — the layout adapts automatically.

> **Why not `localhost`?** HYTE Nexus resolves the URL from the display's own context and doesn't recognise `localhost`. The installer automatically finds and gives you your PC's local network IP.

---

## What the installer does

- Copies widget files to `%LOCALAPPDATA%\Programs\HyteTickerWidget`
- Creates a Windows Task Scheduler task called **HyteTickerWidget** that starts `widget.ps1` silently at login
- Starts the server immediately so you don't need to reboot
- Prints and copies the Nexus URL to your clipboard

---

## Customising the widget

### From the touch display (easiest)

Tap the **⚙ gear icon** on the widget to open the settings panel:

| Setting | What it does |
|---|---|
| Tickers | Add/remove tickers (one per line, use Yahoo Finance symbols) |
| Refresh interval | How often prices update (seconds) |
| Theme | Dark or light |
| Accent color | Pick a color — backgrounds are derived automatically |
| Timezone | Leave blank for your PC's local time, or enter e.g. `Europe/London` |
| Start with Windows | Toggle auto-start on or off without touching any files |

### Via URL params

Append parameters to the Nexus URL:

```
http://192.168.1.42:4000/?tickers=VWRA.L,VOO,SPY&refresh=30&theme=light
```

### Via config.json

Edit `%LOCALAPPDATA%\Programs\HyteTickerWidget\config.json` and refresh the widget.

---

## Manual run (developers)

No installer needed — just run:

```powershell
powershell -File widget.ps1
```

The terminal will print the URL to use. Press `Ctrl+C` to stop.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Widget shows `—` / loading forever | The server isn't running. Re-run `install.ps1` or start `widget.ps1` manually |
| Nexus shows blank / can't connect | Make sure you're using the local IP (e.g. `192.168.1.42`), not `localhost` |
| IP changed and widget stopped working | Re-run `install.ps1` — it detects the current IP |
| "Start with Windows" toggle greyed out | Run `install.ps1` first to register the scheduled task |
| PowerShell script blocked | Open PowerShell and run: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| Port 4000 already in use | Edit `widget.ps1`, change `$Port = 4000` to another port, update Nexus URL |
