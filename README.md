# Yen → USD

A small personal app for converting yen to dollars, with a bill splitter, built from the Claude Design mock `Yen to USD.dc.html`. It comes in two versions:

- **iPhone app** (SwiftUI) in `YenToUSD/`
- **Web app** in `web/`, hosted at **https://rosshettel.github.io/yen-to-usd/**. Open it in Safari and use Share → Add to Home Screen.

Both versions work the same way:

- The rate comes from [Frankfurter](https://frankfurter.dev), which is free and needs no API key. It's fetched on launch and whenever the app returns to the foreground.
- If the fetch fails, the app uses a fixed fallback rate of `149.5` (`RateService.fallbackRate` in the iPhone app, `FALLBACK_RATE` in `web/index.html`).
- The pill in the top right shows a **green** dot for a live rate and a **red** dot for the fallback. Tap it to retry.

## Run in the simulator

```bash
xcodebuild -project YenToUSD.xcodeproj -scheme YenToUSD -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath build build
```

Or open `YenToUSD.xcodeproj` in Xcode and press Run.

## Install on your iPhone

1. Open `YenToUSD.xcodeproj` in Xcode.
2. In Xcode → Settings → Accounts, add your Apple ID.
3. Select the YenToUSD target. Under Signing & Capabilities, set Team to your Personal Team. If Xcode says the bundle ID is taken, change it.
4. Plug in your phone and turn on Developer Mode (Settings → Privacy & Security). Choose your phone as the run destination and press Run.
5. The first time, trust the developer on the phone: Settings → General → VPN & Device Management.

With a free Apple ID, the app expires after 7 days. Run it from Xcode again to refresh it.

## Web app

`web/` is plain HTML, CSS and JS with no build step.

- **Run locally:** `python3 -m http.server 8123 -d web`, then open http://localhost:8123.
- **Deploy:** every push to `main` that changes `web/` publishes it to GitHub Pages (`.github/workflows/pages.yml`).
- **Offline:** `web/sw.js` caches the page, icons and fonts, so the app opens with no signal and falls back to the fixed rate. After you change the list of cached files, bump `CACHE` in `sw.js`. Edits to existing files show up on the second launch after a deploy.
- **Haptics:** Safari has no vibration API, so each key press flips a hidden `<input type="checkbox" switch>`, which plays the iOS toggle tick (iOS 18+). This is an unofficial trick and may stop working in a future iOS. Android uses `navigator.vibrate`.
- **Icons:** `web/icons/` are resized copies of the iPhone app icon (`sips -z <size> <size>`).
