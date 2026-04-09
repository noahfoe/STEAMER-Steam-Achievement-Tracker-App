import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/my_app_bar.dart';

class AchievementsScreen extends StatelessWidget {
  final List<GameDetails> gameDetails;

  const AchievementsScreen({
    super.key,
    required this.gameDetails,
  });

  @override
  Widget build(BuildContext context) {
    final totalAchievements = gameDetails
        .map((e) => e.allAchievements ?? const [])
        .expand((e) => e)
        .length;
    final unlockedAchievements = gameDetails
        .map((e) => e.unlockedAchievements ?? const [])
        .expand((e) => e)
        .length;
    final lockedAchievements = gameDetails
        .map((e) => e.lockedAchievements ?? const [])
        .expand((e) => e)
        .length;
    final perfectedGames = gameDetails
        .where(
          (details) =>
              (details.allAchievements ?? const []).isNotEmpty &&
              (details.lockedAchievements ?? const []).isEmpty,
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: KColors.backgroundColor,
      appBar: myAppBar(title: 'Achievements'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _AchievementSummaryCard(
                title: 'Total',
                value: '$totalAchievements',
              ),
              _AchievementSummaryCard(
                title: 'Unlocked',
                value: '$unlockedAchievements',
              ),
              _AchievementSummaryCard(
                title: 'Locked',
                value: '$lockedAchievements',
              ),
              _AchievementSummaryCard(
                title: '100% Games',
                value: '${perfectedGames.length}',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Perfected Games',
            style: TextStyle(
              color: KColors.activeTextColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (perfectedGames.isEmpty)
            const Text(
              'No fully completed achievement sets yet.',
              style: TextStyle(
                color: KColors.inactiveTextColor,
              ),
            )
          else
            ...perfectedGames.map(
              (details) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: KColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  details.gameName ?? 'Unknown Game',
                  style: const TextStyle(
                    color: KColors.activeTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AchievementSummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _AchievementSummaryCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: KColors.inactiveTextColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: KColors.menuHighlightColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
