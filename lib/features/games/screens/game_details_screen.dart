// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/features/games/controllers/game_details_controller.dart';
import 'package:steam_achievement_tracker/features/games/widgets/expandable_game_tile.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/async_state_panel.dart';
import 'package:steam_achievement_tracker/services/widgets/my_app_bar.dart';

class GameDetailsScreen extends StatelessWidget {
  final String steamID;
  final Game game;
  final GameDetails gameDetails;

  const GameDetailsScreen({
    Key? key,
    required this.steamID,
    required this.gameDetails,
    required this.game,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GameDetailsScreenController>(
      init: GameDetailsScreenController(
        appID: game.appId,
        steamID: steamID,
        gameDetails: gameDetails,
      ),
      builder: (controller) {
        return Scaffold(
          backgroundColor: KColors.backgroundColor,
          appBar: myAppBar(title: game.name),
          body: controller.obx(
            onLoading: const Center(child: CircularProgressIndicator()),
            onEmpty: AsyncStatePanel(
              icon: Icons.emoji_events_outlined,
              title: 'No Achievement Data',
              message:
                  '${game.name} does not currently expose Steam achievement data for this profile.',
            ),
            onError: (error) => AsyncStatePanel(
              icon: Icons.cloud_off,
              title: 'Could Not Load Achievements',
              message: error ?? 'Please try again in a moment.',
              actionLabel: 'Retry',
              onAction: controller.retry,
            ),
            (state) => Column(
              children: [
                // Header Image
                Image.network(
                  'https://steamcdn-a.akamaihd.net/steam/apps/${game.appId}/header.jpg',
                ),
                _AchievementDropdowns(game: game),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AchievementDropdowns extends GetView<GameDetailsScreenController> {
  const _AchievementDropdowns({
    required this.game,
  });

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          if (controller.gameDetails.allAchievements!.isNotEmpty)
            Column(
              children: [
                // All Achievements
                Visibility(
                  visible: controller.gameDetails.allAchievements!.isNotEmpty,
                  child: Obx(
                    () => ExpandableGameTile(
                      isTotal: true,
                      gameName: game.name,
                      achievements:
                          controller.gameDetails.allAchievements ?? [],
                      globalAchievementPercentages:
                          controller.achievementsAndGlobalPercentages.value,
                    ),
                  ),
                ),

                // Unlocked Achievements
                Visibility(
                  visible:
                      controller.gameDetails.unlockedAchievements!.isNotEmpty,
                  child: Obx(
                    () => ExpandableGameTile(
                      gameName: "Unlocked Achievements",
                      achievements:
                          controller.gameDetails.unlockedAchievements ?? [],
                      globalAchievementPercentages:
                          controller.achievementsAndGlobalPercentages.value,
                    ),
                  ),
                ),

                // Locked Achievements
                Visibility(
                  visible:
                      controller.gameDetails.lockedAchievements!.isNotEmpty,
                  child: Obx(
                    () => ExpandableGameTile(
                      gameName: "Locked Achievements",
                      achievements:
                          controller.gameDetails.lockedAchievements ?? [],
                      globalAchievementPercentages:
                          controller.achievementsAndGlobalPercentages.value,
                    ),
                  ),
                ),
              ],
            )
          else
            // No Achievements State
            _NoAchievementsState(
              gameDetails: controller.gameDetails,
              game: game,
            ),
        ],
      ),
    );
  }
}

class _NoAchievementsState extends StatelessWidget {
  const _NoAchievementsState({
    Key? key,
    required this.gameDetails,
    required this.game,
  }) : super(key: key);

  final GameDetails gameDetails;
  final Game game;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        Center(
          child: Text(
            "Sorry, but ${game.name} does not have any Steam achievements",
            style: const TextStyle(
              color: KColors.activeTextColor,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Total Playtime: ${game.playtimeForever}",
          style: const TextStyle(
            color: KColors.activeTextColor,
          ),
        ),
        const SizedBox(height: 20),
        // Last 2 weeks playtime
        Text(
          "Last 2 weeks playtime: ${game.playtime2Weeks}",
          style: const TextStyle(
            color: KColors.activeTextColor,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
