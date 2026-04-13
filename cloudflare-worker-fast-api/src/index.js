const API_BASE = "https://api.steampowered.com";

const TTL = {
  playerSummary: 60 * 30,
  steamLevel: 60 * 30,
  ownedGames: 60 * 30,
  gameSchema: 60 * 60 * 24 * 14,
  playerAchievements: 60 * 60 * 12,
  globalAchievementPercentages: 60 * 60 * 24 * 14,
  achievementSummaries: 60 * 30,
  dashboardSummary: 60 * 15,
};

export default {
  async fetch(request, env, ctx) {
    try {
      const url = new URL(request.url);
      const steamId = url.searchParams.get("steamId");
      const appId = url.searchParams.get("appId");

      switch (url.pathname) {
        case "/player-summary":
          return jsonResponse(
            await getPlayerSummary(env, requireSteamId(steamId)),
          );
        case "/steam-level":
          return jsonResponse(await getSteamLevel(env, requireSteamId(steamId)));
        case "/owned-games":
          return jsonResponse(await getOwnedGames(env, requireSteamId(steamId)));
        case "/game-schema":
          return jsonResponse(await getGameSchema(env, requireAppId(appId)));
        case "/player-achievements":
          return jsonResponse(
            await getPlayerAchievements(
              env,
              requireSteamId(steamId),
              requireAppId(appId),
            ),
          );
        case "/global-achievement-percentages":
          return jsonResponse(
            await getGlobalAchievementPercentages(env, requireAppId(appId)),
          );
        case "/achievement-summaries":
          return jsonResponse(
            await getAchievementSummaries(env, requireSteamId(steamId), ctx),
          );
        case "/dashboard-summary":
          return jsonResponse(
            await getDashboardSummary(env, requireSteamId(steamId), ctx),
          );
        default:
          return jsonError("Not found", 404, "not_found");
      }
    } catch (error) {
      return jsonError(
        error.message || "Unexpected error",
        error.status || 500,
        error.code || "worker_error",
      );
    }
  },
};

function requireSteamId(steamId) {
  if (!steamId) {
    throw appError("Missing steamId", 400, "missing_steam_id");
  }
  return steamId;
}

function requireAppId(appId) {
  if (!appId) {
    throw appError("Missing appId", 400, "missing_app_id");
  }
  return Number(appId);
}

function appError(message, status, code) {
  const error = new Error(message);
  error.status = status;
  error.code = code;
  return error;
}

function jsonResponse(payload, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "content-type": "application/json; charset=UTF-8",
      "cache-control": "no-store",
    },
  });
}

function jsonError(message, status = 500, code = "worker_error") {
  return jsonResponse({ error: message, code }, status);
}

async function getPlayerSummary(env, steamId) {
  return getOrCacheJson(
    env,
    `player-summary:${steamId}`,
    TTL.playerSummary,
    () =>
      steamGet(
        env,
        "/ISteamUser/GetPlayerSummaries/v2/",
        { steamids: steamId },
      ),
  );
}

async function getSteamLevel(env, steamId) {
  return getOrCacheJson(
    env,
    `steam-level:${steamId}`,
    TTL.steamLevel,
    () =>
      steamGet(
        env,
        "/IPlayerService/GetSteamLevel/v1/",
        { steamid: steamId },
      ),
  );
}

async function getOwnedGames(env, steamId) {
  return getOrCacheJson(
    env,
    `owned-games:${steamId}`,
    TTL.ownedGames,
    () =>
      steamGet(
        env,
        "/IPlayerService/GetOwnedGames/v1/",
        {
          steamid: steamId,
          include_appinfo: "true",
          include_played_free_games: "true",
        },
      ),
  );
}

async function getGameSchema(env, appId) {
  return getOrCacheJson(
    env,
    `game-schema:${appId}`,
    TTL.gameSchema,
    () =>
      steamGet(
        env,
        "/ISteamUserStats/GetSchemaForGame/v2/",
        { appid: String(appId), l: "english" },
      ),
  );
}

async function getPlayerAchievements(env, steamId, appId) {
  return getOrCacheJson(
    env,
    `player-achievements:${steamId}:${appId}`,
    TTL.playerAchievements,
    () =>
      steamGet(
        env,
        "/ISteamUserStats/GetPlayerAchievements/v1/",
        {
          steamid: steamId,
          appid: String(appId),
          l: "english",
        },
      ),
  );
}

async function getGlobalAchievementPercentages(env, appId) {
  return getOrCacheJson(
    env,
    `global-achievement-percentages:${appId}`,
    TTL.globalAchievementPercentages,
    () =>
      steamGet(
        env,
        "/ISteamUserStats/GetGlobalAchievementPercentagesForApp/v2/",
        { gameid: String(appId) },
      ),
  );
}

async function getAchievementSummaries(env, steamId) {
  return getOrCacheJson(
    env,
    `achievement-summaries:${steamId}`,
    TTL.achievementSummaries,
    async () => {
      const ownedGamesPayload = await getOwnedGames(env, steamId);
      const games = ownedGamesPayload?.response?.games ?? [];

      const filteredGames = games.filter(
        (game) => game?.appid && game?.has_community_visible_stats,
      );

      const summaries = (
        await mapWithConcurrency(filteredGames, 16, async (game) => {
          try {
            const [schemaPayload, achievementsPayload] = await Promise.all([
              getGameSchema(env, game.appid),
              getPlayerAchievements(env, steamId, game.appid),
            ]);

            const achievementSchema =
              schemaPayload?.game?.availableGameStats?.achievements ?? [];
            if (!achievementSchema.length) {
              return null;
            }

            const unlockedLookup = new Map(
              (achievementsPayload?.playerstats?.achievements ?? []).map(
                (achievement) => [achievement.apiname, achievement.achieved ?? 0],
              ),
            );

            const totalAchievements = achievementSchema.length;
            let unlockedAchievements = 0;

            for (const achievement of achievementSchema) {
              if ((unlockedLookup.get(achievement.name) ?? 0) === 1) {
                unlockedAchievements += 1;
              }
            }

            const lockedAchievements =
              totalAchievements - unlockedAchievements;

            return {
              appId: game.appid,
              gameName: game.name,
              imageUrl: game.img_icon_url
                ? `https://media.steampowered.com/steamcommunity/public/images/apps/${game.appid}/${game.img_icon_url}.jpg`
                : "",
              totalAchievements,
              unlockedAchievements,
              lockedAchievements,
            };
          } catch (_) {
            return null;
          }
        })
      )
        .filter(Boolean)
        .sort((a, b) => a.gameName.localeCompare(b.gameName));

      return { games: summaries };
    },
  );
}

async function getDashboardSummary(env, steamId) {
  return getOrCacheJson(
    env,
    `dashboard-summary:${steamId}`,
    TTL.dashboardSummary,
    async () => {
      const [ownedGamesPayload, achievementSummaryPayload] = await Promise.all([
        getOwnedGames(env, steamId),
        getAchievementSummaries(env, steamId),
      ]);

      const games = ownedGamesPayload?.response?.games ?? [];
      const summaries = achievementSummaryPayload?.games ?? [];

      const totalGames = games.length;
      const totalHoursPlayed = Math.floor(
        games.reduce(
          (sum, game) => sum + Number(game.playtime_forever || 0),
          0,
        ),
      );
      const totalAchievements = summaries.reduce(
        (sum, game) => sum + Number(game.totalAchievements || 0),
        0,
      );
      const unlockedAchievements = summaries.reduce(
        (sum, game) => sum + Number(game.unlockedAchievements || 0),
        0,
      );
      const lockedAchievements = summaries.reduce(
        (sum, game) => sum + Number(game.lockedAchievements || 0),
        0,
      );
      const perfectedGames = summaries.filter(
        (game) =>
          Number(game.totalAchievements || 0) > 0 &&
          Number(game.lockedAchievements || 0) === 0,
      ).length;

      return {
        summary: {
          totalGames,
          totalHoursPlayed,
          totalAchievements,
          unlockedAchievements,
          lockedAchievements,
          perfectedGames,
          gamesWithAchievements: summaries.length,
        },
      };
    },
  );
}

async function steamGet(env, path, params) {
  if (!env.STEAM_API_KEY) {
    throw appError("Missing STEAM_API_KEY secret", 500, "missing_steam_key");
  }

  const url = new URL(`${API_BASE}${path}`);
  url.searchParams.set("key", env.STEAM_API_KEY);

  for (const [key, value] of Object.entries(params)) {
    url.searchParams.set(key, value);
  }

  const response = await fetch(url.toString(), {
    headers: {
      accept: "application/json",
    },
  });

  if (!response.ok) {
    throw appError(
      `Steam returned ${response.status}`,
      502,
      "steam_api_error",
    );
  }

  const data = await response.json();

  if (data?.playerstats?.success === false) {
    throw appError(
      data?.playerstats?.error || "Steam could not return player stats",
      404,
      "steam_playerstats_error",
    );
  }

  return data;
}

async function getOrCacheJson(env, key, ttlSeconds, producer) {
  const cached = await env.STEAMER_CACHE.get(key, "json");
  if (cached) {
    return cached;
  }

  const fresh = await producer();
  await env.STEAMER_CACHE.put(key, JSON.stringify(fresh), {
    expirationTtl: ttlSeconds,
  });
  return fresh;
}

async function mapWithConcurrency(items, concurrency, mapper) {
  const results = new Array(items.length);
  let currentIndex = 0;

  async function worker() {
    while (currentIndex < items.length) {
      const index = currentIndex++;
      results[index] = await mapper(items[index], index);
    }
  }

  const workers = Array.from(
    { length: Math.min(concurrency, items.length) },
    () => worker(),
  );

  await Promise.all(workers);
  return results;
}
