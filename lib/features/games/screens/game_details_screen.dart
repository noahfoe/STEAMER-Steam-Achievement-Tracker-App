// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/features/games/controllers/game_details_controller.dart';
import 'package:steam_achievement_tracker/features/games/widgets/expandable_game_tile.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/async_state_panel.dart';
import 'package:steam_achievement_tracker/services/widgets/app_skeletons.dart';
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
            onLoading: GameDetailsScreenSkeleton(gameName: game.name),
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
            (state) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                _GameHeroCard(
                  game: game,
                  gameDetails: controller.gameDetails,
                ),
                const SizedBox(height: 18),
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
    if (controller.gameDetails.allAchievements!.isEmpty) {
      return _NoAchievementsState(
        gameDetails: controller.gameDetails,
        game: game,
      );
    }

    return Column(
      children: [
        Obx(
          () => ExpandableGameTile(
            isTotal: true,
            gameName: game.name,
            achievements: controller.gameDetails.allAchievements ?? [],
            globalAchievementPercentages:
                controller.achievementsAndGlobalPercentages.value,
          ),
        ),
        if (controller.gameDetails.unlockedAchievements!.isNotEmpty)
          Obx(
            () => ExpandableGameTile(
              gameName: "Unlocked Achievements",
              achievements: controller.gameDetails.unlockedAchievements ?? [],
              globalAchievementPercentages:
                  controller.achievementsAndGlobalPercentages.value,
            ),
          ),
        if (controller.gameDetails.lockedAchievements!.isNotEmpty)
          Obx(
            () => ExpandableGameTile(
              gameName: "Locked Achievements",
              achievements: controller.gameDetails.lockedAchievements ?? [],
              globalAchievementPercentages:
                  controller.achievementsAndGlobalPercentages.value,
            ),
          ),
      ],
    );
  }
}

class _GameHeroCard extends StatelessWidget {
  final Game game;
  final GameDetails gameDetails;

  const _GameHeroCard({
    required this.game,
    required this.gameDetails,
  });

  @override
  Widget build(BuildContext context) {
    final total = (gameDetails.allAchievements ?? const []).length;
    final unlocked = (gameDetails.unlockedAchievements ?? const []).length;
    final progress = total == 0 ? 0.0 : unlocked / total;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: KColors.primaryColor,
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                'https://steamcdn-a.akamaihd.net/steam/apps/${game.appId}/header.jpg',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: const TextStyle(
                        color: KColors.activeTextColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _GameHeroChip(
                          icon: Icons.emoji_events_outlined,
                          label: '$unlocked/$total unlocked',
                        ),
                        _GameHeroChip(
                          icon: Icons.schedule_rounded,
                          label: '${game.playtimeForever ?? 0} minutes played',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Achievement Progress',
                  style: TextStyle(
                    color: KColors.activeTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: progress,
                    backgroundColor: KColors.backgroundColor,
                    valueColor: const AlwaysStoppedAnimation(
                      KColors.menuHighlightColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameHeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GameHeroChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: KColors.menuHighlightColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: KColors.activeTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
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
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sentiment_neutral_rounded,
            color: KColors.inactiveTextColor,
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            "${game.name} does not currently expose Steam achievements for this profile.",
            style: const TextStyle(
              color: KColors.activeTextColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            "Total playtime: ${game.playtimeForever} minutes",
            style: const TextStyle(
              color: KColors.inactiveTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Last 2 weeks: ${game.playtime2Weeks} minutes",
            style: const TextStyle(
              color: KColors.inactiveTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
