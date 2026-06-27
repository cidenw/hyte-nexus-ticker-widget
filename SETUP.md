# Setup Guide

## Prerequisites

- A free [Vercel account](https://vercel.com) (sign up with GitHub)
- HYTE Nexus 2.0 with your Y70 Touch Infinite connected

---

## Step 1 — Deploy to Vercel

Click the deploy button in the README, or:

1. Fork this repo on GitHub
2. Go to [vercel.com/new](https://vercel.com/new)
3. Import your forked repo
4. Click **Deploy** — no settings to change

Vercel gives you a URL like `https://hyte-nexus-ticker-widget-abc123.vercel.app`.

---

## Step 2 — Add to HYTE Nexus

1. Open **HYTE Nexus** on your PC
2. On the Y70ti layout, click **+ Add widget**
3. Select **Web** (or **iFrame / URL**) widget type
4. Paste your Vercel URL into the URL field
5. Resize the cell — the widget adapts automatically:
   - **Narrow cell** → symbol + price only
   - **Standard** → symbol, name, price, change
   - **Tall** → all info + timestamps

---

## Step 3 — Customise

### From the display (tap ⚙)

| Setting | What it does |
|---|---|
| Tickers | One per line — use Yahoo Finance symbols |
| Refresh interval | How often prices update (seconds) |
| Theme | Dark or light |
| Accent color | Pick any color — backgrounds derive from it |
| Timezone | Blank = your PC's local time, or e.g. `Europe/London` |
| Show change / name | Toggle extra info |

Settings are saved to the widget's local storage and survive page refreshes.

### Via URL (no redeploy needed)

Edit the URL in the Nexus widget field:

```
https://your-app.vercel.app/?tickers=VWRA.L,VOO,SPY&timezone=Europe/London&theme=dark
```

### Change defaults permanently

Fork the repo → edit `config.json` → Vercel redeploys automatically on push.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Prices not loading | Check your Vercel deployment logs — Yahoo Finance may be rate-limiting |
| Widget shows blank in Nexus | Make sure the URL starts with `https://` |
| Timestamps in wrong timezone | Open ⚙ settings → enter IANA timezone e.g. `Europe/London` |
| Want different default tickers | Edit `config.json` in your fork and push — Vercel redeploys automatically |
