# Uninstall Guide

## The easy way — Uninstaller

1. Right-click **`uninstall.ps1`** → **"Run with PowerShell"**.
2. The uninstaller will:
   - Stop and delete the Windows startup tasks
   - Kill any running widget/proxy server processes
   - Delete all installed files from `%LOCALAPPDATA%\Programs\HyteTickerWidget`
3. Remove the widget from **HYTE Nexus** manually (long-press → Remove).

---

## Manual uninstall

### 1 — Remove from HYTE Nexus

Long-press or right-click the ticker widget on your Y70ti layout → **Remove**.

### 2 — Stop and delete scheduled tasks

```powershell
schtasks /End    /TN HyteTickerWidget-Server
schtasks /End    /TN HyteTickerWidget-Proxy
schtasks /Delete /TN HyteTickerWidget-Server /F
schtasks /Delete /TN HyteTickerWidget-Proxy  /F
```

### 3 — Kill running servers

Close any terminals running `node server.mjs` or `node proxy.mjs`, or:

```powershell
Get-Process node | Stop-Process -Force
```

(Only do this if you have no other Node.js processes you want to keep running.)

### 4 — Delete installed files

```powershell
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Programs\HyteTickerWidget"
```

### 5 — Clear saved settings (optional)

Open a browser at `http://localhost:4000` → DevTools (`F12`) → Application → Local Storage → delete the `tickerCfg` key.

Or paste in the console:
```js
localStorage.removeItem('tickerCfg');
```

Nothing else is installed system-wide. Node.js itself is left untouched.
