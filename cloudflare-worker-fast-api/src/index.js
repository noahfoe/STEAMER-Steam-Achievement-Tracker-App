const API_BASE = "https://api.steampowered.com";

const TTL = {
  playerSummary: 60 * 30,
  steamLevel: 60 * 30,
  ownedGames: 60 * 30,
  gameSchema: 60 * 60 * 24 * 14,
  playerAchievements: 60 * 60 * 12,
  globalAchievementPercentages: 60 * 60 * 24 * 14,
  achievementSummaries: 60 * 30,
  profilePerfectGames: 60 * 30,
  dashboardSummary: 60 * 15,
};

const ACHIEVEMENT_SUMMARY_CONCURRENCY = 4;
const TOP_ACHIEVEMENTS_PRIMARY_CHUNK_SIZE = 50;
const TOP_ACHIEVEMENTS_FALLBACK_CHUNK_SIZE = 10;
const TOP_ACHIEVEMENTS_MAX_ACHIEVEMENTS = 100000;
const STEAM_FETCH_TIMEOUT_MS = 20000;
const STEAM_FETCH_RETRIES = 3;

export default {
  async fetch(request, env, ctx) {
    try {
      const url = new URL(request.url);
      const steamId = url.searchParams.get("steamId");
      const appId = url.searchParams.get("appId");
      const skipCache = url.searchParams.get("refresh") === "1";

      switch (url.pathname) {
        case "/player-summary":
          return jsonResponse(
            await getPlayerSummary(env, requireSteamId(steamId), skipCache),
          );
        case "/steam-level":
          return jsonResponse(
            await getSteamLevel(env, requireSteamId(steamId), skipCache),
          );
        case "/owned-games":
          return jsonResponse(
            await getOwnedGames(env, requireSteamId(steamId), skipCache),
          );
        case "/game-schema":
          return jsonResponse(
            await getGameSchema(env, requireAppId(appId), skipCache),
          );
        case "/player-achievements":
          return jsonResponse(
            await getPlayerAchievements(
              env,
              requireSteamId(steamId),
              requireAppId(appId),
              skipCache,
            ),
          );
        case "/global-achievement-percentages":
          return jsonResponse(
            await getGlobalAchievementPercentages(
              env,
              requireAppId(appId),
              skipCache,
            ),
          );
        case "/achievement-summaries":
          return jsonResponse(
            await getAchievementSummaries(
              env,
              requireSteamId(steamId),
              skipCache,
            ),
          );
        case "/dashboard-summary":
          return jsonResponse(
            await getDashboardSummary(env, requireSteamId(steamId), skipCache),
          );
        case "/debug-achievement-summaries":
          return jsonResponse(
            await getAchievementSummariesDebug(
              env,
              requireSteamId(steamId),
              skipCache,
            ),
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

async function getPlayerSummary(env, steamId, skipCache = false) {
  return getOrCacheJson(
    env,
    `player-summary:${steamId}`,
    TTL.playerSummary,
    () =>
      steamGet(env, "/ISteamUser/GetPlayerSummaries/v2/", {
        steamids: steamId,
      }),
    skipCache,
  );
}

async function getSteamLevel(env, steamId, skipCache = false) {
  return getOrCacheJson(
    env,
    `steam-level:${steamId}`,
    TTL.steamLevel,
    () =>
      steamGet(env, "/IPlayerService/GetSteamLevel/v1/", { steamid: steamId }),
    skipCache,
  );
}

async function getOwnedGames(env, steamId, skipCache = false) {
  return getOrCacheJson(
    env,
    `owned-games:${steamId}`,
    TTL.ownedGames,
    async () => {
      const apiPayload = await steamGet(
        env,
        "/IPlayerService/GetOwnedGames/v1/",
        {
          steamid: steamId,
          include_appinfo: "true",
          include_played_free_games: "true",
        },
      );

      const apiGames = Array.isArray(apiPayload?.response?.games)
        ? apiPayload.response.games
        : [];

      const communityGames = await getCommunityOwnedGames(steamId).catch(
        () => [],
      );
      const mergedGames = mergeOwnedGames(apiGames, communityGames);

      return {
        response: {
          game_count: mergedGames.length,
          games: mergedGames,
        },
      };
    },
    skipCache,
  );
}

async function getGameSchema(env, appId, skipCache = false) {
  return getOrCacheJson(
    env,
    `game-schema:${appId}`,
    TTL.gameSchema,
    () =>
      steamGet(env, "/ISteamUserStats/GetSchemaForGame/v2/", {
        appid: String(appId),
        l: "english",
      }),
    skipCache,
  );
}

async function getPlayerAchievements(env, steamId, appId, skipCache = false) {
  return getOrCacheJson(
    env,
    `player-achievements:${steamId}:${appId}`,
    TTL.playerAchievements,
    () =>
      steamGet(env, "/ISteamUserStats/GetPlayerAchievements/v1/", {
        steamid: steamId,
        appid: String(appId),
        l: "english",
      }),
    skipCache,
  );
}

async function getGlobalAchievementPercentages(env, appId, skipCache = false) {
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
    skipCache,
  );
}

async function getAchievementSummaries(env, steamId, skipCache = false) {
  return getOrCacheJson(
    env,
    `achievement-summaries:${steamId}`,
    TTL.achievementSummaries,
    async () => {
      const collection = await collectAchievementSummaries(
        env,
        steamId,
        skipCache,
      );

      return {
        games: collection.summaries,
      };
    },
    skipCache,
  );
}

async function getDashboardSummary(env, steamId, skipCache = false) {
  return getOrCacheJson(
    env,
    `dashboard-summary:${steamId}`,
    TTL.dashboardSummary,
    async () => {
      const [
        ownedGamesPayload,
        achievementSummaryPayload,
        profilePerfectGamesCount,
      ] = await Promise.all([
        getOwnedGames(env, steamId, skipCache),
        getAchievementSummaries(env, steamId, skipCache),
        getProfilePerfectGamesCount(env, steamId, skipCache),
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
      const apiPerfectedGames = summaries.filter(
        (game) =>
          Number(game.totalAchievements || 0) > 0 &&
          Number(game.lockedAchievements || 0) === 0,
      ).length;
      const perfectedGames = profilePerfectGamesCount ?? apiPerfectedGames;

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
    skipCache,
  );
}

async function getProfilePerfectGamesCount(env, steamId, skipCache = false) {
  return getOrCacheJson(
    env,
    `profile-perfect-games:${steamId}`,
    TTL.profilePerfectGames,
    async () => {
      const html = await fetchSteamCommunityProfileHtml(steamId);
      const matches = [...html.matchAll(/([\d,]+)\s+Perfect Games/gi)];

      if (!matches.length) {
        return null;
      }

      const values = matches
        .map((match) => Number((match[1] || "").replaceAll(",", "")))
        .filter((value) => Number.isFinite(value) && value >= 0);

      if (!values.length) {
        return null;
      }

      return Math.max(...values);
    },
    skipCache,
  );
}

async function getAchievementSummariesDebug(env, steamId, skipCache = false) {
  const collection = await collectAchievementSummaries(env, steamId, skipCache);
  const includedGames = collection.summaries.map((summary) => ({
    ...summary,
    status: "included",
    isPerfected:
      Number(summary.totalAchievements || 0) > 0 &&
      Number(summary.lockedAchievements || 0) === 0,
  }));
  const failedGames = collection.failures;
  const noSchemaGames = collection.noAchievementGames;

  return {
    steamId,
    debug: {
      cacheBypassed: skipCache,
      totalOwnedGames: collection.totalOwnedGames,
      includedGames: includedGames.length,
      failedGames: failedGames.length,
      noSchemaGames: noSchemaGames.length,
      perfectedGames: includedGames.filter((entry) => entry.isPerfected).length,
      concurrency: ACHIEVEMENT_SUMMARY_CONCURRENCY,
      retries: STEAM_FETCH_RETRIES,
      primaryChunkSize: TOP_ACHIEVEMENTS_PRIMARY_CHUNK_SIZE,
      fallbackChunkSize: TOP_ACHIEVEMENTS_FALLBACK_CHUNK_SIZE,
    },
    includedGames,
    failedGames,
    noSchemaGames: noSchemaGames.slice(0, 200),
  };
}

async function collectAchievementSummaries(env, steamId, skipCache = false) {
  const ownedGamesPayload = await getOwnedGames(env, steamId, skipCache);
  const ownedGames = (ownedGamesPayload?.response?.games ?? []).filter(
    (game) => game?.appid,
  );
  const gameMetadataByAppId = new Map(
    ownedGames.map((game) => [Number(game.appid), game]),
  );
  const appIds = ownedGames.map((game) => Number(game.appid));

  const chunkResults = await mapWithConcurrency(
    chunkArray(appIds, TOP_ACHIEVEMENTS_PRIMARY_CHUNK_SIZE),
    ACHIEVEMENT_SUMMARY_CONCURRENCY,
    (chunk) => fetchTopAchievementChunkWithFallback(env, steamId, chunk),
  );

  const topAchievementGames = chunkResults.flatMap((result) => result.games);
  const failures = chunkResults.flatMap((result) => result.failures);
  const seenAppIds = new Set();

  const summaries = topAchievementGames
    .map((game) =>
      buildAchievementSummary(
        game,
        gameMetadataByAppId.get(Number(game.appid)),
      ),
    )
    .filter(Boolean)
    .filter((summary) => {
      if (seenAppIds.has(summary.appId)) {
        return false;
      }
      seenAppIds.add(summary.appId);
      return true;
    })
    .sort((a, b) => a.gameName.localeCompare(b.gameName));

  const failedAppIds = new Set(
    failures.map((failure) => Number(failure.appId)),
  );
  const noAchievementGames = ownedGames
    .filter(
      (game) =>
        !seenAppIds.has(Number(game.appid)) &&
        !failedAppIds.has(Number(game.appid)),
    )
    .map((game) => ({
      appId: Number(game.appid),
      gameName: game.name,
      status: "no_achievement_data",
    }));

  return {
    totalOwnedGames: ownedGames.length,
    summaries,
    failures,
    noAchievementGames,
  };
}

async function fetchTopAchievementChunkWithFallback(env, steamId, appIds) {
  if (!appIds.length) {
    return { games: [], failures: [] };
  }

  try {
    const payload = await getTopAchievementsForGames(env, steamId, appIds);
    return {
      games: (payload?.response?.games ?? []).filter((game) => game?.appid),
      failures: [],
    };
  } catch (error) {
    if (appIds.length <= 1) {
      return {
        games: [],
        failures: [
          {
            appId: Number(appIds[0]),
            status: "failed",
            error: error?.message || "Unknown error",
            code: error?.code || "unknown",
          },
        ],
      };
    }

    if (appIds.length <= TOP_ACHIEVEMENTS_FALLBACK_CHUNK_SIZE) {
      const results = await mapWithConcurrency(
        appIds.map((appId) => [appId]),
        ACHIEVEMENT_SUMMARY_CONCURRENCY,
        (chunk) => fetchTopAchievementChunkWithFallback(env, steamId, chunk),
      );

      return {
        games: results.flatMap((result) => result.games),
        failures: results.flatMap((result) => result.failures),
      };
    }

    const fallbackResults = await mapWithConcurrency(
      chunkArray(appIds, TOP_ACHIEVEMENTS_FALLBACK_CHUNK_SIZE),
      ACHIEVEMENT_SUMMARY_CONCURRENCY,
      (chunk) => fetchTopAchievementChunkWithFallback(env, steamId, chunk),
    );

    return {
      games: fallbackResults.flatMap((result) => result.games),
      failures: fallbackResults.flatMap((result) => result.failures),
    };
  }
}

async function getTopAchievementsForGames(env, steamId, appIds) {
  const params = {
    steamid: steamId,
    language: "english",
    max_achievements: String(TOP_ACHIEVEMENTS_MAX_ACHIEVEMENTS),
  };

  appIds.forEach((appId, index) => {
    params[`appids[${index}]`] = String(appId);
  });

  return steamGet(
    env,
    "/IPlayerService/GetTopAchievementsForGames/v1/",
    params,
  );
}

function buildAchievementSummary(game, metadata) {
  const appId = Number(game?.appid ?? metadata?.appid ?? 0);
  const totalAchievements = Number(game?.total_achievements ?? 0);

  if (!appId || !Number.isFinite(totalAchievements) || totalAchievements <= 0) {
    return null;
  }

  const unlockedAchievements = Array.isArray(game?.achievements)
    ? game.achievements.length
    : 0;
  const lockedAchievements = Math.max(
    totalAchievements - unlockedAchievements,
    0,
  );

  return {
    appId,
    gameName: metadata?.name ?? game?.name ?? `App ${appId}`,
    imageUrl: resolveOwnedGameImageUrl(
      appId,
      metadata?.img_icon_url,
      metadata?.img_logo_url ?? metadata?.logo,
    ),
    totalAchievements,
    unlockedAchievements,
    lockedAchievements,
  };
}

async function getCommunityOwnedGames(steamId) {
  const xml = await fetchSteamCommunityGamesXml(steamId);
  return parseCommunityOwnedGamesXml(xml);
}

async function fetchSteamCommunityGamesXml(steamId) {
  const url = `https://steamcommunity.com/profiles/${steamId}/games?tab=all&xml=1`;

  for (let attempt = 1; attempt <= STEAM_FETCH_RETRIES; attempt++) {
    const controller = new AbortController();
    const timeout = setTimeout(
      () => controller.abort("Steam Community games request timed out"),
      STEAM_FETCH_TIMEOUT_MS,
    );

    try {
      const response = await fetch(url, {
        headers: {
          accept: "application/xml,text/xml,text/plain",
          "accept-language": "en-US,en;q=0.9",
          "user-agent":
            "STEAMER/1.1.2 (+https://steam-tracker-api.noahfoley6.workers.dev)",
        },
        signal: controller.signal,
      });

      clearTimeout(timeout);

      if (!response.ok) {
        if (
          attempt < STEAM_FETCH_RETRIES &&
          (response.status === 429 || response.status >= 500)
        ) {
          await delay(attempt * 350);
          continue;
        }

        throw appError(
          `Steam Community games returned ${response.status}`,
          502,
          "steam_community_games_error",
        );
      }

      return response.text();
    } catch (error) {
      clearTimeout(timeout);

      const shouldRetry =
        attempt < STEAM_FETCH_RETRIES &&
        (error?.name === "AbortError" || error?.status >= 500);

      if (!shouldRetry) {
        throw error;
      }

      await delay(attempt * 350);
    }
  }

  throw appError(
    "Steam Community games request failed",
    502,
    "steam_community_games_error",
  );
}

function parseCommunityOwnedGamesXml(xml) {
  if (!xml || typeof xml !== "string") {
    return [];
  }

  const gameBlocks = [...xml.matchAll(/<game>([\s\S]*?)<\/game>/gi)];

  return gameBlocks
    .map((match) => parseCommunityOwnedGameBlock(match[1]))
    .filter(Boolean);
}

function parseCommunityOwnedGameBlock(block) {
  const appId = Number(extractXmlTagValue(block, "appID"));
  if (!appId) {
    return null;
  }

  const name = extractXmlTagValue(block, "name");
  const logo = extractXmlTagValue(block, "logo");
  const storeLink = extractXmlTagValue(block, "storeLink");
  const statsLink = extractXmlTagValue(block, "statsLink");
  const globalStatsLink = extractXmlTagValue(block, "globalStatsLink");

  return {
    appid: appId,
    name: name || `App ${appId}`,
    playtime_forever: parseHoursToMinutes(
      extractXmlTagValue(block, "hoursOnRecord"),
    ),
    playtime_2weeks: parseHoursToMinutes(
      extractXmlTagValue(block, "hoursLast2Weeks"),
    ),
    img_icon_url: logo,
    img_logo_url: logo,
    logo,
    store_link: storeLink,
    stats_link: statsLink,
    has_community_visible_stats: Boolean(statsLink || globalStatsLink),
    source: "steam_community_xml",
  };
}

function extractXmlTagValue(block, tagName) {
  const cdataMatch = block.match(
    new RegExp(
      `<${tagName}>\\s*<!\\[CDATA\\[([\\s\\S]*?)\\]\\]>\\s*<\\/${tagName}>`,
      "i",
    ),
  );

  if (cdataMatch) {
    return decodeXmlEntities(cdataMatch[1].trim());
  }

  const plainMatch = block.match(
    new RegExp(`<${tagName}>\\s*([\\s\\S]*?)\\s*<\\/${tagName}>`, "i"),
  );

  if (!plainMatch) {
    return "";
  }

  return decodeXmlEntities(plainMatch[1].trim());
}

function decodeXmlEntities(value) {
  return String(value || "")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&apos;/g, "'");
}

function parseHoursToMinutes(value) {
  const match = String(value || "")
    .replaceAll(",", "")
    .match(/[\d.]+/);
  const hours = Number(match?.[0] ?? 0);

  if (!Number.isFinite(hours) || hours <= 0) {
    return 0;
  }

  return Math.round(hours * 60);
}

function mergeOwnedGames(apiGames, supplementalGames) {
  const mergedGames = [];
  const seenAppIds = new Set();

  for (const game of apiGames) {
    const appId = Number(game?.appid);
    if (!appId || seenAppIds.has(appId)) {
      continue;
    }

    seenAppIds.add(appId);
    mergedGames.push(game);
  }

  for (const game of supplementalGames) {
    const appId = Number(game?.appid);
    if (!appId || seenAppIds.has(appId)) {
      continue;
    }

    seenAppIds.add(appId);
    mergedGames.push(game);
  }

  return mergedGames;
}

function resolveOwnedGameImageUrl(appId, imageRef, fallbackRef = "") {
  if (isAbsoluteUrl(imageRef)) {
    return imageRef;
  }

  if (imageRef) {
    return `https://media.steampowered.com/steamcommunity/public/images/apps/${appId}/${imageRef}.jpg`;
  }

  if (isAbsoluteUrl(fallbackRef)) {
    return fallbackRef;
  }

  if (fallbackRef) {
    return `https://media.steampowered.com/steamcommunity/public/images/apps/${appId}/${fallbackRef}.jpg`;
  }

  return "";
}

function isAbsoluteUrl(value) {
  return typeof value === "string" && /^https?:\/\//i.test(value);
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

  let lastError = null;

  for (let attempt = 1; attempt <= STEAM_FETCH_RETRIES; attempt++) {
    const controller = new AbortController();
    const timeout = setTimeout(
      () => controller.abort("Steam API request timed out"),
      STEAM_FETCH_TIMEOUT_MS,
    );

    try {
      const response = await fetch(url.toString(), {
        headers: {
          accept: "application/json",
        },
        signal: controller.signal,
      });

      clearTimeout(timeout);

      if (!response.ok) {
        if (
          attempt < STEAM_FETCH_RETRIES &&
          (response.status === 429 || response.status >= 500)
        ) {
          await delay(attempt * 350);
          continue;
        }

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
    } catch (error) {
      clearTimeout(timeout);
      lastError = error;

      const shouldRetry =
        attempt < STEAM_FETCH_RETRIES &&
        (error?.name === "AbortError" ||
          error?.code === "steam_api_error" ||
          error?.status >= 500);

      if (!shouldRetry) {
        throw normalizeSteamError(error);
      }

      await delay(attempt * 350);
    }
  }

  throw normalizeSteamError(lastError);
}

async function fetchSteamCommunityProfileHtml(steamId) {
  const url = `https://steamcommunity.com/profiles/${steamId}/`;

  for (let attempt = 1; attempt <= STEAM_FETCH_RETRIES; attempt++) {
    const controller = new AbortController();
    const timeout = setTimeout(
      () => controller.abort("Steam Community request timed out"),
      STEAM_FETCH_TIMEOUT_MS,
    );

    try {
      const response = await fetch(url, {
        headers: {
          accept: "text/html,application/xhtml+xml",
          "accept-language": "en-US,en;q=0.9",
          "user-agent":
            "STEAMER/1.1.2 (+https://steam-tracker-api.noahfoley6.workers.dev)",
        },
        signal: controller.signal,
      });

      clearTimeout(timeout);

      if (!response.ok) {
        if (
          attempt < STEAM_FETCH_RETRIES &&
          (response.status === 429 || response.status >= 500)
        ) {
          await delay(attempt * 350);
          continue;
        }

        throw appError(
          `Steam Community returned ${response.status}`,
          502,
          "steam_community_error",
        );
      }

      return response.text();
    } catch (error) {
      clearTimeout(timeout);

      const shouldRetry =
        attempt < STEAM_FETCH_RETRIES &&
        (error?.name === "AbortError" || error?.status >= 500);

      if (!shouldRetry) {
        throw error;
      }

      await delay(attempt * 350);
    }
  }

  throw appError(
    "Steam Community profile request failed",
    502,
    "steam_community_error",
  );
}

async function getOrCacheJson(
  env,
  key,
  ttlSeconds,
  producer,
  skipCache = false,
) {
  if (!skipCache) {
    const cached = await env.STEAMER_CACHE.get(key, "json");
    if (cached) {
      return cached;
    }
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

function chunkArray(items, chunkSize) {
  const chunks = [];

  for (let index = 0; index < items.length; index += chunkSize) {
    chunks.push(items.slice(index, index + chunkSize));
  }

  return chunks;
}

function normalizeSteamError(error) {
  if (error?.status && error?.code) {
    return error;
  }

  if (error?.name === "AbortError") {
    return appError("Steam API request timed out", 504, "steam_api_timeout");
  }

  return appError(
    error?.message || "Steam API request failed",
    502,
    "steam_api_error",
  );
}

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
