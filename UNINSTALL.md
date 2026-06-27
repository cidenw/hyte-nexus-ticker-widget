# Uninstall Guide

## Remove from HYTE Nexus

Long-press or right-click the ticker widget on your Y70ti layout → **Remove**.

## Remove the Vercel deployment

1. Go to your [Vercel dashboard](https://vercel.com/dashboard)
2. Open the project → **Settings** → **Advanced**
3. Click **Delete Project**

## Clear saved settings

The widget stores your customisations in the Nexus browser's localStorage. These are cleared automatically when Nexus removes the widget. To clear manually while the widget is open, open browser DevTools → Application → Local Storage → delete the `tickerCfg` key.

That's it — nothing is installed on your PC.
