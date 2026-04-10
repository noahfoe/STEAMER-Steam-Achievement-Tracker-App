# STEAMER Release Prep

## What is already done in the repo
- Android package id set to `com.thepetrichor.steamer`
- release signing scaffolding added in `android/app/build.gradle`
- `android/key.properties.example` added
- release keystore files ignored in `.gitignore`
- metadata cleanup completed across Android/web/desktop starter files
- Play Store icon and feature graphic added in `branding/`

## Still required from you
- create the upload keystore locally
- create `android/key.properties`
- provide a support email
- publish a privacy policy URL
- capture Play Store screenshots
- run closed testing and fix any device-specific issues

## Recommended versioning strategy
- First production release: `1.0.0+1`
- Bug fix updates: `1.0.1+2`, `1.0.2+3`
- Small feature updates: `1.1.0+4`
- Larger milestones: `1.2.0+5`

Keep `versionName` user-facing and always increment `versionCode` for every Play upload.
