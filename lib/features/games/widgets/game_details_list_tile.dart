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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: KColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: achievement.achieved == 1
            ? NetworkIconImage(imageUrl: achievement.icon)
            : NetworkIconImage(imageUrl: achievement.iconGray),
        title: Text(
          achievement.displayName,
          style: const TextStyle(
            color: KColors.activeTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              achievement.description ?? "No Description",
              style: const TextStyle(
                color: KColors.inactiveTextColor,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$_getGlobalPercentageForThisAchievement% of all players",
              style: const TextStyle(
                color: KColors.inactiveTextColor,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        dense: true,
        trailing: Icon(
          achievement.achieved == 1
              ? Icons.check_circle_rounded
              : Icons.lock_outline_rounded,
          color: achievement.achieved == 1
              ? const Color(0xff7dd3a3)
              : KColors.inactiveTextColor,
        ),
      ),
    );
  }

  String get _getGlobalPercentageForThisAchievement {
    if (globalAchievementPercentages.isEmpty) {
      return "0";
    }

    final match = globalAchievementPercentages
        .where((element) => element.name == achievement.name)
        .toList();

    if (match.isEmpty) {
      return "0";
    }

    return match.first.percent.toStringAsFixed(2);
  }
}
