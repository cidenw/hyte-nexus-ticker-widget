# Uninstall Guide

## Remove from HYTE Nexus

1. Open **HYTE Nexus**.
2. Long-press or right-click the ticker widget on your Y70ti display layout.
3. Select **Remove** / **Delete widget**.

## Stop the local server

Close the terminal running `npx serve . -p 3000`.

If you set it up as a Windows startup task/service:
- **Task Scheduler**: open Task Scheduler → find the task → right-click → Delete.
- **nssm**: run `nssm remove ticker-widget confirm` in an admin terminal.

## Stop the local CORS proxy (if used)

Close the terminal running `node proxy.mjs` (or remove its startup task the same way).

## Clear stored settings

Open a browser, navigate to `http://localhost:3000`, open DevTools → Application → Local Storage → `http://localhost:3000` → delete the `tickerCfg` key.

Or paste this into the browser console while on the widget page:

```js
localStorage.removeItem('tickerCfg');
```

## Delete the widget files

```
rmdir /s /q C:\widgets\ticker-widget
```

That's it — nothing else is installed system-wide.
