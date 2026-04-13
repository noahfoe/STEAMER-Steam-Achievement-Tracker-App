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

See [database.dart](lib/services/utils/database.dart) for the current API wiring.

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

Recommended first production version:

`1.1.0+6`

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
