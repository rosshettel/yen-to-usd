# Yen → USD

A small personal iPhone app for converting yen to dollars, with a bill splitter. Built in SwiftUI from the Claude Design mock `Yen to USD.dc.html`.

- The rate comes from [Frankfurter](https://frankfurter.dev), which is free and needs no API key. It's fetched on launch and whenever the app returns to the foreground.
- If the fetch fails, the app uses a fixed fallback rate of `149.5` (`RateService.fallbackRate`).
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
