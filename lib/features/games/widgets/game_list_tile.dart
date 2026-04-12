import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/features/games/screens/game_details_screen.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/utils/app_route.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/network_icon_image.dart';

class GameListTile extends StatelessWidget {
  final Game game;
  final String steamId;
  final GameDetails gameDetails;

  const GameListTile({
    Key? key,
    required this.game,
    required this.steamId,
    required this.gameDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalAchievements = (gameDetails.allAchievements ?? const []).length;
    final unlockedAchievements =
        (gameDetails.unlockedAchievements ?? const []).length;
    final isPerfect = totalAchievements > 0 &&
        (gameDetails.lockedAchievements ?? const []).isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              AppRoute.fadeSlide(
                builder: (context) => GameDetailsScreen(
                  steamID: steamId,
                  game: game,
                  gameDetails: gameDetails,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetworkIconImage(
                  imageUrl: game.imgIconUrl ?? '',
                  size: 56,
                  borderRadius: 14,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              game.name,
                              style: const TextStyle(
                                color: KColors.activeTextColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            isPerfect
                                ? Icons.verified_rounded
                                : Icons.chevron_right_rounded,
                            color: isPerfect
                                ? const Color(0xff89e5c6)
                                : KColors.inactiveTextColor,
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${game.playtimeForever ?? 0} minutes played',
                        style: const TextStyle(
                          color: KColors.inactiveTextColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _GameChip(
                            icon: Icons.emoji_events_outlined,
                            label: totalAchievements > 0
                                ? '$unlockedAchievements/$totalAchievements unlocked'
                                : 'No achievement stats',
                            accent: KColors.menuHighlightColor,
                          ),
                          _GameChip(
                            icon: Icons.schedule_rounded,
                            label:
                                '${game.playtime2Weeks ?? 0} min in last 2 weeks',
                            accent: const Color(0xff8ab4ff),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _GameChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: KColors.activeTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
