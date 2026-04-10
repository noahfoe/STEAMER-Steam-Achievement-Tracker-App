import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/features/games/screens/game_details_screen.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/utils/app_route.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';

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
    return ListTile(
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
      tileColor: KColors.backgroundColor,
      title: Text(
        game.name,
        style: const TextStyle(
          color: KColors.activeTextColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: SizedBox(
        width: 35,
        height: 35,
        child: Image.network(game.imgIconUrl!),
      ),
      subtitle: Text(
        "Total Playtime: ${game.playtimeForever}",
        style: const TextStyle(
          color: KColors.inactiveTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      dense: true,
    );
  }
}
