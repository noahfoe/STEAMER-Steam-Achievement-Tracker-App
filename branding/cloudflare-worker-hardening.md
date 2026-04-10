# Cloudflare Worker Hardening Notes

Recommended next backend improvements before broad release:

## 1. Add request logging
Log:
- route name
- Steam ID hash or truncated identifier
- app id when applicable
- response status
- request duration

Avoid logging full personal identifiers when unnecessary.

## 2. Add lightweight rate limiting
Protect endpoints from abuse by limiting:
- repeated requests from the same IP
- repeated requests for the same Steam ID over a short period

## 3. Add aggregated home stats endpoint
Create one Worker route that returns:
- total achievements
- unlocked achievements
- locked achievements
- total games
- total hours played
- perfected games

This will reduce the number of requests the mobile app needs for the home dashboard.

## 4. Normalize error responses
Return a consistent JSON shape, for example:

```json
{
  "error": "Readable message",
  "code": "steam_unavailable"
}
```

## 5. Cache safe responses
Short cache windows can help for:
- player summary
- owned games
- steam level
- global achievement percentages

Be more careful with per-user achievement progress if you want near-real-time freshness.
