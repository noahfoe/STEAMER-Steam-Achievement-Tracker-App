import 'dart:async';

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/features/games/screens/games_screen.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/models/user/user_steam_information.dart';
import 'package:steam_achievement_tracker/services/utils/database.dart';
import 'package:steam_achievement_tracker/services/utils/preference_utils.dart';

class HomeScreenController extends GetxController with StateMixin<void> {
  final String steamID;

  final Database _database = Database.instance;

  HomeScreenController({required this.steamID}) {
    init();
  }

  final Rx<UserSteamInformation> playerSummary =
      UserSteamInformation.empty().obs;
  final RxList<Game> playerGamesList = <Game>[].obs;
  final RxList<GameDetails> gameDetails = <GameDetails>[].obs;
  final RxInt steamLevel = 0.obs;
  final RxBool isLoadingAchievementStats = false.obs;
  final RxBool hasLoadedAchievementStats = false.obs;
  final RxInt loadedAchievementGameCount = 0.obs;
  final RxInt totalAchievementGameCount = 0.obs;
  final RxString achievementSyncStatus = ''.obs;

  init() async {
    change(null, status: RxStatus.loading());
    try {
      getSharedPreferences();
      final futures = <Future<void>>[
        if (steamLevel.value == 0)
          _database.getSteamLevel(steamID: steamID).then((level) async {
            steamLevel.value = level;
            await PreferenceUtils.setSteamLevel(level);
          }),
        if (playerSummary.value == UserSteamInformation.empty())
          _database.getPlayerSummary(steamID: steamID).then((summary) async {
            playerSummary.value = summary;
            await PreferenceUtils.setPlayerSummary(summary);
          }),
        if (playerGamesList.isEmpty)
          _database.getPlayerGamesList(steamID: steamID).then((games) async {
            playerGamesList.assignAll(games);
            await PreferenceUtils.setPlayerGamesList(playerGamesList);
          }),
      ];
      await Future.wait(futures);
      totalAchievementGameCount.value = playerGamesList.length;
      if (gameDetails.isNotEmpty) {
        loadedAchievementGameCount.value = gameDetails.length;
        hasLoadedAchievementStats.value = true;
      }
      update();
      unawaited(_loadAchievementStats());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
    change(null, status: RxStatus.success());
  }

  void getSharedPreferences() {
    steamLevel.value = PreferenceUtils.getSteamLevel();
    playerSummary.value = PreferenceUtils.getPlayerSummary();
    playerGamesList.assignAll(PreferenceUtils.getPlayerGamesList());
    gameDetails.assignAll(PreferenceUtils.getGameDetails());
    steamLevel.refresh();
    playerSummary.refresh();
    playerGamesList.refresh();
    gameDetails.refresh();
    hasLoadedAchievementStats.value = gameDetails.isNotEmpty;
    loadedAchievementGameCount.value = gameDetails.length;
    totalAchievementGameCount.value = playerGamesList.length;
    achievementSyncStatus.value = '';
  }

  Future<void> _loadAchievementStats() async {
    isLoadingAchievementStats.value = true;
    achievementSyncStatus.value = 'Syncing achievement data...';
    if (gameDetails.isEmpty) {
      hasLoadedAchievementStats.value = false;
      loadedAchievementGameCount.value = 0;
    }
    try {
      final refreshedGameDetails = await _database.getEveryOwnedGamesGameDetails(
        steamID: steamID,
        games: playerGamesList,
        onProgress: (completed, total) {
          loadedAchievementGameCount.value = completed;
          totalAchievementGameCount.value = total;
          if (total > 0) {
            achievementSyncStatus.value =
                'Syncing achievement data... $completed of $total games checked';
          }
        },
      );
      gameDetails.assignAll(refreshedGameDetails);
      await PreferenceUtils.setGameDetails(gameDetails);
      achievementSyncStatus.value = refreshedGameDetails.isEmpty
          ? 'No achievement data found yet.'
          : 'Achievement data synced';
    } finally {
      isLoadingAchievementStats.value = false;
      hasLoadedAchievementStats.value = true;
    }
  }

  /// Navigate the user to the Games Screen.
  void navigateToGamesScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GamesScreen(
          steamID: steamID,
          playerGamesList: playerGamesList,
          gameDetails: gameDetails,
          playerSummary: playerSummary.value,
        ),
      ),
    );
  }
}
