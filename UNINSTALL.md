# Uninstall Guide

## 1. Remove from HYTE Nexus

1. Open **HYTE Nexus**.
2. Long-press or right-click the ticker widget on your Y70ti layout.
3. Select **Remove** / **Delete widget**.

## 2. Stop the servers

Close both terminals:
- The one running `npx serve . -p 4000`
- The one running `node proxy.mjs`

If you set them up as Task Scheduler tasks:

1. Open **Task Scheduler**.
2. Find the tasks you created for the widget and proxy.
3. Right-click each → **Delete**.

## 3. Clear saved settings

Open a browser tab to `http://localhost:4000` (while the server is still running), open DevTools (`F12`) → **Application** → **Local Storage** → `http://localhost:4000` → delete the `tickerCfg` key.

Or run this in the DevTools console:
```js
localStorage.removeItem('tickerCfg');
```

## 4. Delete the widget files

```powershell
Remove-Item -Recurse -Force C:\widgets\ticker-widget
```

Nothing else is installed system-wide — `npx serve` and `node` are standard tools left untouched.
