# STEAMER Cloudflare Worker

This Worker adds faster cached endpoints for the app:

- `/dashboard-summary?steamId=...`
- `/achievement-summaries?steamId=...`

It also keeps the older per-route Steam proxy endpoints:

- `/player-summary`
- `/steam-level`
- `/owned-games`
- `/game-schema`
- `/player-achievements`
- `/global-achievement-percentages`

## Required bindings

- Secret: `STEAM_API_KEY`
- KV namespace binding: `STEAMER_CACHE`

## Recommended cache keys

- `player-summary:<steamId>`
- `steam-level:<steamId>`
- `owned-games:<steamId>`
- `game-schema:<appId>`
- `player-achievements:<steamId>:<appId>`
- `global-achievement-percentages:<appId>`
- `achievement-summaries:<steamId>`
- `dashboard-summary:<steamId>`

## Why this is faster

The mobile app no longer needs to calculate dashboard totals by fetching full
achievement details for every game on first load. It can load one aggregated
summary endpoint for Home and one lightweight per-game summary endpoint for
Achievements.
