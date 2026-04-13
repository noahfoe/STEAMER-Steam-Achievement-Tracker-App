// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/features/games/screens/games_screen.dart';
import 'package:steam_achievement_tracker/features/login/screens/login_screen.dart';
import 'package:steam_achievement_tracker/services/models/games/dashboard_summary.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/models/user/user_steam_information.dart';
import 'package:steam_achievement_tracker/services/utils/app_route.dart';
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
  final Rx<DashboardSummary> dashboardSummary = DashboardSummary.empty().obs;
  final RxList<Game> playerGamesList = <Game>[].obs;
  final RxList<GameDetails> gameDetails = <GameDetails>[].obs;
  final RxInt steamLevel = 0.obs;

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
        if (dashboardSummary.value.isEmpty)
          _database.getDashboardSummary(steamID: steamID).then((summary) async {
            dashboardSummary.value = summary;
            await PreferenceUtils.setDashboardSummary(summary);
          }),
        if (playerGamesList.isEmpty)
          _database.getPlayerGamesList(steamID: steamID).then((games) async {
            playerGamesList.assignAll(games);
            await PreferenceUtils.setPlayerGamesList(playerGamesList);
          }),
      ];
      await Future.wait(futures);
      update();
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
    change(null, status: RxStatus.success());
  }

  void getSharedPreferences() {
    steamLevel.value = PreferenceUtils.getSteamLevel();
    playerSummary.value = PreferenceUtils.getPlayerSummary();
    dashboardSummary.value = PreferenceUtils.getDashboardSummary();
    playerGamesList.assignAll(PreferenceUtils.getPlayerGamesList());
    gameDetails.assignAll(PreferenceUtils.getGameDetails());
    steamLevel.refresh();
    playerSummary.refresh();
    dashboardSummary.refresh();
    playerGamesList.refresh();
    gameDetails.refresh();
  }

  /// Navigate the user to the Games Screen.
  void navigateToGamesScreen(BuildContext context) {
    Navigator.of(context).push(
      AppRoute.fadeSlide(
        builder: (context) => GamesScreen(
          steamID: steamID,
          playerGamesList: playerGamesList,
          gameDetails: gameDetails,
          playerSummary: playerSummary.value,
        ),
      ),
    );
  }

  Future<void> refreshAllData() async {
    await PreferenceUtils.clearCachedData();
    playerSummary.value = UserSteamInformation.empty();
    dashboardSummary.value = DashboardSummary.empty();
    playerGamesList.clear();
    gameDetails.clear();
    steamLevel.value = 0;
    await init();
  }

  Future<void> signOut(BuildContext context) async {
    await PreferenceUtils.clearSessionData();
    playerSummary.value = UserSteamInformation.empty();
    dashboardSummary.value = DashboardSummary.empty();
    playerGamesList.clear();
    gameDetails.clear();
    steamLevel.value = 0;
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      AppRoute.fadeSlide(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }
}
