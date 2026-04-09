import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/services/models/games/achievement.dart';
import 'package:steam_achievement_tracker/services/models/games/global_achievement_percentages.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/network_icon_image.dart';

class GameDetailsListTile extends StatelessWidget {
  final Achievement achievement;
  final List<GlobalAchievementPercentages> globalAchievementPercentages;

  const GameDetailsListTile({
    Key? key,
    required this.achievement,
    required this.globalAchievementPercentages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: KColors.backgroundColor,
      leading: achievement.achieved == 1
          ? NetworkIconImage(imageUrl: achievement.icon)
          : NetworkIconImage(imageUrl: achievement.iconGray),
      title: Text(
        achievement.displayName,
        style: const TextStyle(
          color: KColors.activeTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            achievement.description ?? "No Description",
            style: const TextStyle(
              color: KColors.inactiveTextColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "$_getGlobalPercentageForThisAchievement% of all players",
            style: const TextStyle(
              color: KColors.inactiveTextColor,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
      dense: true,
    );
  }

  String get _getGlobalPercentageForThisAchievement {
    if (globalAchievementPercentages.isEmpty) {
      return "0";
    }

    // Find the global percentage for this achievement without using .firstWhere
    final percentage = globalAchievementPercentages
        .where((element) => element.name == achievement.name)
        .first;

    return percentage.percent.toStringAsFixed(2);
  }
}
