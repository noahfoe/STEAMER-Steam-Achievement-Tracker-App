# STEAMER Release Prep

## What is already done in the repo

- Android package id set to `com.thepetrichor.steamer`
- release signing scaffolding added in `android/app/build.gradle`
- `android/key.properties.example` added
- release keystore files ignored in `.gitignore`
- metadata cleanup completed across Android/web/desktop starter files
- Play Store icon and feature graphic added in `branding/`

## Still required

- upload youtube video for STEAMER Play Store video
- complete closed testing and fix any device-specific issues

## Versioning strategy

- First test release: `1.0.0`
- Estimated first prod release: `1.1.1`
- Bug fix updates: `1.0.1`, `1.0.2`, etc.
- Small feature updates: `1.1.0`, `1.2.0`, etc.
- Large feature updates: `2.0.0`, `3.0.0`, etc.

Keep `versionName` user-facing and always increment `versionCode` for every Play upload.
