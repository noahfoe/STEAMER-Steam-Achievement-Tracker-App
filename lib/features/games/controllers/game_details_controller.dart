// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/models/games/global_achievement_percentages.dart';
import 'package:steam_achievement_tracker/services/utils/database.dart';

class GameDetailsScreenController extends GetxController with StateMixin<void> {
  final String steamID;
  final int appID;
  GameDetails gameDetails;

  GameDetailsScreenController({
    required this.steamID,
    required this.appID,
    required this.gameDetails,
  }) {
    init();
  }

  final Database _database = Database.instance;
  final PageController pageController = PageController();

  // final Rx<GameDetails> gameInfoAndAchievements = GameDetails.empty().obs;
  final Rx<List<GlobalAchievementPercentages>>
      achievementsAndGlobalPercentages =
      RxList<GlobalAchievementPercentages>.empty().obs;

  init() async {
    change(null, status: RxStatus.loading());
    try {
      if (gameDetails == GameDetails.empty()) {
        gameDetails = await _database.getGameDetails(
          steamID: steamID,
          appID: appID,
        );
      }

      if (gameDetails == GameDetails.empty()) {
        change(null, status: RxStatus.empty());
        return;
      }

      achievementsAndGlobalPercentages.value =
          await _database.getGlobalAchievementPercentagesForApp(appID: appID);
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
    change(null, status: RxStatus.success());
  }
}
