import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/features/games/widgets/game_details_list_tile.dart';
import 'package:steam_achievement_tracker/services/models/games/achievement.dart';
import 'package:steam_achievement_tracker/services/models/games/global_achievement_percentages.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';

class ExpandableGameTile extends StatelessWidget {
  final String gameName;
  final bool isTotal;
  final List<Achievement> achievements;
  final List<GlobalAchievementPercentages> globalAchievementPercentages;

  const ExpandableGameTile({
    Key? key,
    this.isTotal = false,
    required this.gameName,
    required this.achievements,
    required this.globalAchievementPercentages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
      ),
      child: ExpansionTile(
        iconColor: KColors.menuHighlightColor,
        collapsedIconColor: KColors.logoColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          gameName,
          style: const TextStyle(
            color: KColors.activeTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        subtitle: isTotal
            ? Text(
                "${((achievements.where((element) => element.achieved == 1).length / achievements.length) * 100).toDouble().round()}% total achievements unlocked",
                style: const TextStyle(
                  color: KColors.inactiveTextColor,
                  fontWeight: FontWeight.w500,
                ),
              )
            : achievements[0].achieved == 1
                ? Text(
                    "${achievements.length} unlocked achievements",
                    style: const TextStyle(
                      color: KColors.inactiveTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Text(
                    "${achievements.length} locked achievements",
                    style: const TextStyle(
                      color: KColors.inactiveTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
        childrenPadding: const EdgeInsets.all(10),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: achievements.length,
            itemBuilder: (context, index) => GameDetailsListTile(
              achievement: achievements[index],
              globalAchievementPercentages: globalAchievementPercentages,
            ),
          ),
        ],
      ),
    );
  }
}
