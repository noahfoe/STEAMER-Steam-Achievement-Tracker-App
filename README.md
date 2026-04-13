# STEAMER

STEAMER is a Flutter companion app for viewing a public Steam profile, browsing a Steam library, and tracking achievement progress in a cleaner mobile dashboard.

## Features

- Steam OpenID login flow
- Home dashboard with profile, library, hours played, and achievement totals
- Library browser with per-game details
- Achievement tracking, including perfected games
- Session restore for returning users
- Cloudflare Worker backend for Steam Web API requests
- Android release signing scaffolding for Play Store builds

## Tech Stack

- Flutter
- GetX
- Cloudflare Workers
- Steam Web API

## Project Structure

- `lib/`: Flutter app source
- `android/`: Android build and signing config
- `branding/`: app icon, feature graphic, privacy policy, and Play Store drafts

## Backend

The app is configured to use this Cloudflare Worker base URL:

`https://steam-tracker-api.noahfoley6.workers.dev`

The Worker implementation used for the current performance fixes lives in:

- [cloudflare-worker-fast-api/src/index.js](cloudflare-worker-fast-api/src/index.js)
- [cloudflare-worker-fast-api/README.md](cloudflare-worker-fast-api/README.md)

See [database.dart](lib/services/utils/database.dart) for the current API wiring.

### Backend Performance Enhancements

The original backend flow was functional, but slow for large Steam libraries because
the app had to fetch a lot of per-game data before the Home screen could feel
complete.

The current backend setup fixes that in a few important ways:

- Added Cloudflare KV caching for Steam responses so repeat loads are much faster
- Added aggregated endpoints so the app no longer has to calculate Home totals on-device
- Kept the older proxy endpoints so already-installed app builds remain compatible
- Moved more of the expensive work to the Worker instead of the Flutter client

### Current Worker Endpoints

Existing proxy endpoints:

- `/player-summary`
- `/steam-level`
- `/owned-games`
- `/game-schema`
- `/player-achievements`
- `/global-achievement-percentages`

New fast endpoints:

- `/dashboard-summary?steamId=...`
- `/achievement-summaries?steamId=...`

### What The New Endpoints Do

`/dashboard-summary`

- returns a single summary payload for the Home screen
- includes total games, total hours played, total achievements, unlocked, locked, and perfected games
- lets the app render the dashboard quickly without crawling every game first

`/achievement-summaries`

- returns a lightweight list of per-game achievement totals
- powers the Achievements screen without needing full details for every game up front
- keeps full per-game achievement fetches on-demand when a user opens a specific game

### Cache Strategy

The Worker currently caches both raw Steam responses and aggregated app-friendly
responses. Cached keys include:

- `player-summary:<steamId>`
- `steam-level:<steamId>`
- `owned-games:<steamId>`
- `game-schema:<appId>`
- `player-achievements:<steamId>:<appId>`
- `global-achievement-percentages:<appId>`
- `achievement-summaries:<steamId>`
- `dashboard-summary:<steamId>`

This means:

- first loads for a very large Steam library can still take longer while Cloudflare warms the cache
- repeat loads are dramatically faster
- the app can still clear its local cache independently of the Worker cache for testing

### Cloudflare Bindings

The Worker expects:

- Secret: `STEAM_API_KEY`
- KV binding: `STEAMER_CACHE`

### App-Side Result

On the Flutter side, the Home screen now loads from the aggregated summary endpoint
instead of waiting on a full achievement crawl, and the Achievements screen loads
from cached summary data before deeper per-game requests are made.

## Getting Started

### Prerequisites

- Flutter SDK installed
- A device or emulator for local testing
- A Cloudflare Worker configured with a Steam API key

### Run locally

From the repo root:

```powershell
flutter pub get
flutter run
```

## Release Build

Release signing support is already wired in [build.gradle](android/app/build.gradle).

Before building a release bundle, make sure these exist:

- [keystores/steamer-upload.jks](keystores/steamer-upload.jks)
- [android/key.properties](android/key.properties)

Build the Play Store bundle:

```powershell
flutter build appbundle --release
```

Output:

`build/app/outputs/bundle/release/app-release.aab`

Build a release APK:

```powershell
flutter build apk --release
```

Output:

`build/app/outputs/flutter-apk/app-release.apk`

## Branding And Store Assets

Current release assets live in [branding](branding/), including:

- [play-store-icon-512.png](branding/play-store-icon-512.png)
- [feature-graphic.png](branding/feature-graphic.png)
- [play-store-listing.md](branding/play-store-listing.md)
- [privacy-policy.html](branding/privacy-site/index.html)
- [release-prep.md](branding/release-prep.md)

## Play Store Notes

Android app id:

`com.thepetrichor.steamer`

Expected release version:

`1.1.1+7`

For more detail, see [release-prep.md](branding/release-prep.md).

## Important Notes

- STEAMER requires a public Steam profile to load account data.
- The app is an independent companion app and is not affiliated with Valve.
- Steam profile, library, and achievement data are cached locally for faster loading.

## Development Notes

If you update the Worker API:

- keep response shapes stable
- prefer readable JSON errors
- consider aggregated endpoints for home-screen performance

Backend hardening notes are in [cloudflare-worker-hardening.md](branding/cloudflare-worker-hardening.md).

## Privacy Policy

https://steamer-privacy-site.pages.dev/
