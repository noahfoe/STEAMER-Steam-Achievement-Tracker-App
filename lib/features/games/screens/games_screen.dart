// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/features/games/controllers/games_screen_controller.dart';
import 'package:steam_achievement_tracker/features/games/widgets/game_list_tile.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/models/user/user_steam_information.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/my_app_bar.dart';

class GamesScreen extends StatelessWidget {
  final String steamID;
  final List<Game> playerGamesList;
  final List<GameDetails> gameDetails;
  final UserSteamInformation playerSummary;

  const GamesScreen({
    Key? key,
    required this.steamID,
    required this.playerGamesList,
    required this.gameDetails,
    required this.playerSummary,
  }) : super(key: key);

  GameDetails _findGameDetails(Game game) {
    for (final details in gameDetails) {
      if (details.gameName == game.name) {
        return details;
      }
    }
    return GameDetails.empty().copyWith(gameName: game.name);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GamesScreenController>(
      init: GamesScreenController(
        steamID: steamID,
        playerGamesList: playerGamesList,
      ),
      builder: (GamesScreenController controller) {
        return Scaffold(
          backgroundColor: KColors.backgroundColor,
          appBar: myAppBar(
            title: 'Library',
          ),
          body: controller.obx(
            onLoading: const Center(child: CircularProgressIndicator()),
            (state) => Obx(
              () => ListView.builder(
                itemCount: controller.filteredGamesList.value.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Search Bar
                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                            controller: controller.searchController,
                            onChanged: controller.searchGamesList,
                            style: const TextStyle(
                              color: KColors.activeTextColor,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: KColors.activeTextColor,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: KColors.activeTextColor,
                              ),
                              filled: true,
                              fillColor: KColors.backgroundColor,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        GameListTile(
                          game: controller.filteredGamesList.value[index],
                          gameDetails:
                              _findGameDetails(controller.filteredGamesList.value[index]),
                          steamId: steamID,
                        )
                      ],
                    );
                  }
                  return GameListTile(
                    game: controller.filteredGamesList.value[index],
                    gameDetails:
                        _findGameDetails(controller.filteredGamesList.value[index]),
                    steamId: steamID,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
