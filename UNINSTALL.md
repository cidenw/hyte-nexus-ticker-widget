# Uninstall Guide

## Easy way

1. Right-click **`uninstall.ps1`** → **Run with PowerShell**.
2. Remove the widget tile from **HYTE Nexus** manually (long-press → Remove).

Done. Nothing else is left on your PC.

---

## What the uninstaller does

- Stops the running widget server
- Deletes the **HyteTickerWidget** scheduled task (removes it from auto-start)
- Removes all installed files from `%LOCALAPPDATA%\Programs\HyteTickerWidget`

---

## Manual uninstall

### 1 — Remove from HYTE Nexus

Long-press or right-click the widget tile → **Remove**.

### 2 — Delete the scheduled task

```powershell
schtasks /End    /TN HyteTickerWidget
schtasks /Delete /TN HyteTickerWidget /F
```

### 3 — Stop the server

```powershell
Get-Process powershell | Where-Object {
    (Get-WmiObject Win32_Process -Filter "ProcessId=$($_.Id)").CommandLine -like "*HyteTickerWidget*"
} | Stop-Process -Force
```

### 4 — Delete files

```powershell
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Programs\HyteTickerWidget"
```

### 5 — Clear saved settings (optional)

The widget stores your customisations in the browser's localStorage. These are cleared automatically when Nexus removes the widget tile. To clear manually, open the widget URL in a browser → DevTools (`F12`) → Application → Local Storage → delete `tickerCfg`.
