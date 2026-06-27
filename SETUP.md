# Setup Guide

## Prerequisites

- [Node.js](https://nodejs.org/) v18+ installed on the PC driving the Y70 Touch Infinite
- HYTE Nexus 2.0 installed and your Y70ti display detected

---

## Step 1 — Download the widget

Clone or download this repo into a folder, e.g. `C:\widgets\ticker-widget`.

```
git clone https://github.com/your-username/hyte-nexus-ticker-widget.git C:\widgets\ticker-widget
cd C:\widgets\ticker-widget
```

---

## Step 2 — Start the local server

```
npx serve . -p 3000
```

Leave this terminal running. The widget is now accessible at `http://localhost:3000`.

**Optional: run as a background service on startup**

Use [nssm](https://nssm.cc/) or Windows Task Scheduler to run `npx serve . -p 3000` automatically at login, pointing at the widget folder.

---

## Step 3 — Handle CORS

Stooq does not send CORS headers. The widget needs one of these options:

### Option A — Public CORS proxy (default, easiest)

The default `config.json` uses `https://corsproxy.io/?url=` — no setup required. The widget routes Stooq requests through this free public proxy. Requires internet access.

### Option B — Built-in local proxy (self-contained, no third party)

Run in a second terminal:

```
node proxy.mjs
```

Then update `config.json`:

```json
{
  "corsProxy": "http://localhost:3001/proxy?url="
}
```

This proxy only allowlists `stooq.com` requests.

### Option C — Nexus webview with web security disabled

Some embedded webviews disable CORS enforcement. If yours does (test by setting `corsProxy` to `""` and checking the browser console for errors), you don't need any proxy.

---

## Step 4 — Add the widget to HYTE Nexus

1. Open **HYTE Nexus** on your PC.
2. Click **+** / **Add widget** on the Y70ti display layout.
3. Select **Web** (or **iFrame / URL**) widget type.
4. Paste the URL:
   ```
   http://localhost:3000
   ```
   Or with URL params to override tickers without editing config.json:
   ```
   http://localhost:3000/?tickers=VWRA.L,VOO,SPY&refresh=60
   ```
5. Resize the widget cell to your preference. The widget adapts:
   - **Narrow**: symbol + price only
   - **Standard**: symbol, name, price, change
   - **Tall**: all info + timestamps

---

## Step 5 — Customize tickers

**Via in-widget settings (recommended):** Tap the ⚙ gear icon on the widget. Enter tickers one per line. Tap **Save & Refresh**.

**Via config.json:** Edit `"tickers"` array and restart the server (or the widget auto-refreshes on next cycle).

**Via URL:** Append `?tickers=AAPL,MSFT,TSLA` to the Nexus URL field.

---

## Hosting on Vercel (alternative to local server)

If you prefer a public URL instead of running a local server:

1. Push this repo to GitHub.
2. Sign up at [vercel.com](https://vercel.com) and import the repo.
3. Vercel will detect the static site and deploy automatically.
4. Use the Vercel preview URL in the Nexus widget field.
5. **Note:** With Vercel hosting, you still need a CORS proxy (Option A by default). Option B (local proxy) won't apply since the HTML is served from the cloud.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Widget shows `—` / loading forever | Check browser console in Nexus (if accessible) or a desktop browser pointing at the URL |
| CORS error in console | Ensure `corsProxy` in `config.json` is set, or run `proxy.mjs` (Option B) |
| Ticker shows stale data | Stooq data is delayed; the widget dims the card and shows last known value |
| `VWRA.L` not found | Stooq symbol is `vwra.uk` — the widget converts automatically. Check your ticker string has `.L` suffix |
| Port 3000 in use | Change `-p 3000` to another port; update the Nexus URL accordingly |
