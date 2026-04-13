// ignore_for_file: depend_on_referenced_packages, invalid_use_of_protected_member

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:steam_achievement_tracker/services/models/games/achievement_game_summary.dart';
import 'package:steam_achievement_tracker/services/models/games/dashboard_summary.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/models/games/global_achievement_percentages.dart';
import 'package:steam_achievement_tracker/services/models/user/user_steam_information.dart';
import 'package:steam_achievement_tracker/services/utils/demo_mode.dart';

class Database extends GetxController {
  static Database instance = Get.put(_instance);
  static final _instance = Database._internal();
  Database._internal();

  static const String _apiBaseUrl =
      'https://steam-tracker-api.noahfoley6.workers.dev';
  static const Duration _requestTimeout = Duration(seconds: 20);

  Uri _buildUri(String path, Map<String, String> queryParameters) {
    return Uri.parse(
      '$_apiBaseUrl$path',
    ).replace(queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> _getJson(
    String path,
    Map<String, String> queryParameters,
  ) async {
    try {
      final response = await http.get(
        _buildUri(path, queryParameters),
        headers: const {
          'accept': 'application/json',
          'cache-control': 'no-cache',
        },
      ).timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AppNetworkException(
          'The server returned ${response.statusCode}. Please try again.',
        );
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const AppNetworkException(
          'The server response was not in the expected format.',
        );
      }

      if (decoded['error'] is String) {
        throw AppNetworkException(decoded['error'] as String);
      }

      return decoded;
    } on TimeoutException {
      throw const AppNetworkException(
        'The request timed out. Check your connection and try again.',
      );
    } on SocketException {
      throw const AppNetworkException(
        'No internet connection. Check your network and try again.',
      );
    } on FormatException {
      throw const AppNetworkException(
        'The server response could not be read. Please try again later.',
      );
    }
  }

  /// Gets the user's basic Steam information from the Steam API.
  Future<UserSteamInformation> getPlayerSummary(
      {required String steamID}) async {
    if (DemoMode.isDemoSteamId(steamID)) {
      return DemoMode.playerSummary;
    }

    final response = await _getJson(
      '/player-summary',
      {'steamId': steamID},
    );

    final players =
        (response['response'] as Map<String, dynamic>?)?['players'] as List?;
    if (players == null ||
        players.isEmpty ||
        players.first is! Map<String, dynamic>) {
      throw const AppNetworkException(
        'We could not find a public Steam profile for this account.',
      );
    }

    return UserSteamInformation.fromSteamAPI(players.first);
  }

  Future<RxList<GlobalAchievementPercentages>>
      getGlobalAchievementPercentagesForApp({
    required int appID,
    String? steamID,
  }) async {
    if (steamID != null && DemoMode.isDemoSteamId(steamID)) {
      return DemoMode.percentagesForApp(appID).obs;
    }

    final body = await _getJson(
      '/global-achievement-percentages',
      {'appId': '$appID'},
    );
    final achievements = (body['achievementpercentages']
        as Map<String, dynamic>?)?['achievements'] as List?;
    if (achievements == null || achievements.isEmpty) {
      return <GlobalAchievementPercentages>[].obs;
    }

    final temp = <GlobalAchievementPercentages>[];
    for (final element in achievements) {
      if (element is Map<String, dynamic>) {
        temp.add(GlobalAchievementPercentages.fromMap(element));
      }
    }
    return temp.obs;
  }

  /// Gets the user's games list from the Steam API.
  Future<RxList<Game>> getPlayerGamesList({required String steamID}) async {
    if (DemoMode.isDemoSteamId(steamID)) {
      return DemoMode.games.obs;
    }

    final body = await _getJson(
      '/owned-games',
      {'steamId': steamID},
    );

    final games =
        (body['response'] as Map<String, dynamic>?)?['games'] as List?;
    if (games == null || games.isEmpty) {
      return <Game>[].obs;
    }

    final temp = <Game>[].obs;
    for (final game in games) {
      if (game is Map<String, dynamic>) {
        temp.add(Game.fromMap(game));
      }
    }
    return temp;
  }

  Future<DashboardSummary> getDashboardSummary({required String steamID}) async {
    if (DemoMode.isDemoSteamId(steamID)) {
      return DemoMode.dashboardSummary();
    }

    final body = await _getJson(
      '/dashboard-summary',
      {'steamId': steamID},
    );

    final summary = body['summary'];
    if (summary is! Map<String, dynamic>) {
      throw const AppNetworkException(
        'The dashboard summary response was not in the expected format.',
      );
    }

    return DashboardSummary.fromMap(summary);
  }

  Future<List<AchievementGameSummary>> getAchievementGameSummaries({
    required String steamID,
  }) async {
    if (DemoMode.isDemoSteamId(steamID)) {
      return DemoMode.achievementSummaries();
    }

    final body = await _getJson(
      '/achievement-summaries',
      {'steamId': steamID},
    );

    final summaries = body['games'];
    if (summaries is! List) {
      throw const AppNetworkException(
        'The achievement summaries response was not in the expected format.',
      );
    }

    return summaries
        .whereType<Map<String, dynamic>>()
        .map(AchievementGameSummary.fromMap)
        .toList(growable: false);
  }

  Future<List<GameDetails>> getEveryOwnedGamesGameDetails({
    required String steamID,
    List<Game>? games,
    void Function(int completed, int total)? onProgress,
  }) async {
    if (DemoMode.isDemoSteamId(steamID)) {
      final demoGames = games ?? DemoMode.games;
      final total = demoGames.length;
      final details = <GameDetails>[];
      for (int index = 0; index < total; index++) {
        final game = demoGames[index];
        final detail = DemoMode.detailsForApp(game.appId);
        if ((detail.allAchievements ?? const []).isNotEmpty) {
          details.add(detail.copyWith(gameName: game.name));
        }
        onProgress?.call(index + 1, total);
      }
      return details;
    }

    final List<Game> achievementGames =
        (games ?? await getPlayerGamesList(steamID: steamID))
            .toList(growable: false);

    if (achievementGames.isEmpty) {
      onProgress?.call(0, 0);
      return <GameDetails>[];
    }

    const batchSize = 20;
    final List<GameDetails> temp = [];
    int completed = 0;

    for (int i = 0; i < achievementGames.length; i += batchSize) {
      final batch = achievementGames.skip(i).take(batchSize).map((game) async {
        try {
          final details = await getGameDetails(
            steamID: steamID,
            appID: game.appId,
          );
          if ((details.allAchievements ?? const []).isEmpty) {
            return null;
          }
          return details.copyWith(gameName: game.name);
        } catch (_) {
          return null;
        } finally {
          completed++;
          onProgress?.call(completed, achievementGames.length);
        }
      }).toList(growable: false);

      temp.addAll((await Future.wait(batch)).whereType<GameDetails>());
    }

    return temp;
  }

  /// Gets a single GameDetails object from the Steam API.
  ///
  /// This function also calls [getAchievements] to get the user's achievements for the game.
  /// Which is then added to the GameDetails object.
  Future<GameDetails> getGameDetails(
      {required String steamID, required int appID}) async {
    if (DemoMode.isDemoSteamId(steamID)) {
      return DemoMode.detailsForApp(appID);
    }

    final body = await _getJson(
      '/game-schema',
      {
        'steamId': steamID,
        'appId': '$appID',
      },
    );

    if (body.isEmpty || body['game'] == null) {
      return GameDetails.empty();
    }

    Rx<GameDetails> temp = GameDetails.fromMap(body).obs;

    if ((temp.value.allAchievements ?? const []).isNotEmpty) {
      temp = await getAchievements(
            gameDetails: temp,
            steamID: steamID,
            appID: appID,
          ) ??
          temp;
    }

    return temp.value;
  }

  /// Gets the user's achievements for a specific game from the Steam API.
  Future<Rx<GameDetails>?> getAchievements({
    required Rx<GameDetails> gameDetails,
    required String steamID,
    required int appID,
  }) async {
    if (DemoMode.isDemoSteamId(steamID)) {
      return DemoMode.detailsForApp(appID).obs;
    }

    final response = await _getJson(
      '/player-achievements',
      {
        'steamId': steamID,
        'appId': '$appID',
      },
    );

    final body = (response['playerstats']
        as Map<String, dynamic>?)?['achievements'] as List?;

    if (body == null || body.isEmpty) return null;

    final achievementLookup = <String, dynamic>{
      for (final achievement in body)
        if (achievement is Map<String, dynamic> &&
            achievement['apiname'] != null)
          achievement['apiname'] as String: achievement,
    };

    gameDetails.value = gameDetails.value.copyWith(
      allAchievements: gameDetails.value.allAchievements!
          .map(
            (e) => e.copyWith(
              achieved: (achievementLookup[e.name]
                      as Map<String, dynamic>?)?['achieved'] as int? ??
                  0,
            ),
          )
          .toList(),
    );

    gameDetails.value.allAchievements!.sort(
      (a, b) => b.achieved.compareTo(a.achieved),
    );

    gameDetails.value = gameDetails.value.copyWith(
      unlockedAchievements: gameDetails.value.allAchievements!
          .where((element) => element.achieved == 1)
          .toList(),
    );

    gameDetails.value = gameDetails.value.copyWith(
      lockedAchievements: gameDetails.value.allAchievements!
          .where((element) => element.achieved == 0)
          .toList(),
    );
    return gameDetails;
  }

  Future<int> getSteamLevel({required String steamID}) async {
    if (DemoMode.isDemoSteamId(steamID)) {
      return DemoMode.steamLevel;
    }

    final value = await _getJson(
      '/steam-level',
      {'steamId': steamID},
    );
    final level = (value['response'] as Map<String, dynamic>?)?['player_level'];
    if (level is! int) {
      throw const AppNetworkException(
        'We could not read the Steam level for this profile.',
      );
    }
    return level;
  }
}

class AppNetworkException implements Exception {
  final String message;

  const AppNetworkException(this.message);

  @override
  String toString() => message;
}
