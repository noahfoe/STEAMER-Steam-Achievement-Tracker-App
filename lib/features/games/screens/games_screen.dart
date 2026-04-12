// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/features/games/controllers/games_screen_controller.dart';
import 'package:steam_achievement_tracker/features/games/widgets/game_list_tile.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/models/user/user_steam_information.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/async_state_panel.dart';
import 'package:steam_achievement_tracker/services/widgets/network_icon_image.dart';
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
            onEmpty: const AsyncStatePanel(
              icon: Icons.library_books_outlined,
              title: 'No Games Found',
              message:
                  'This Steam account does not have any visible games to display yet.',
            ),
            onError: (error) => AsyncStatePanel(
              icon: Icons.wifi_off_rounded,
              title: 'Library Unavailable',
              message: error ?? 'We could not load your Steam library.',
              actionLabel: 'Try Again',
              onAction: controller.retry,
            ),
            (state) => Obx(
              () {
                final filteredGames = controller.filteredGamesList.value;
                final totalAchievements = gameDetails
                    .map((details) => details.allAchievements ?? const [])
                    .expand((details) => details)
                    .length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                    _LibraryHero(
                      playerSummary: playerSummary,
                      totalGames: playerGamesList.length,
                      visibleGames: filteredGames.length,
                      totalAchievements: totalAchievements,
                    ),
                    const SizedBox(height: 18),
                    _SearchPanel(controller: controller),
                    const SizedBox(height: 18),
                    _SectionLabel(
                      title: filteredGames.length == playerGamesList.length
                          ? 'All Games'
                          : 'Search Results',
                      subtitle: filteredGames.isEmpty
                          ? 'No games match your current search yet.'
                          : '${filteredGames.length} games ready to browse.',
                    ),
                    const SizedBox(height: 14),
                    if (filteredGames.isEmpty)
                      const _EmptyLibrarySearchState()
                    else
                      ...filteredGames.map(
                        (game) => GameListTile(
                          game: game,
                          gameDetails: _findGameDetails(game),
                          steamId: steamID,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _LibraryHero extends StatelessWidget {
  final UserSteamInformation playerSummary;
  final int totalGames;
  final int visibleGames;
  final int totalAchievements;

  const _LibraryHero({
    required this.playerSummary,
    required this.totalGames,
    required this.visibleGames,
    required this.totalAchievements,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff213748),
            Color(0xff162231),
            KColors.primaryColor,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NetworkIconImage(
                imageUrl: playerSummary.avatar ?? '',
                size: 64,
                borderRadius: 18,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${playerSummary.steamName ?? 'Steam User'} Library',
                      style: const TextStyle(
                        color: KColors.activeTextColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Browse your collection with faster search and cleaner game snapshots.',
                      style: TextStyle(
                        color: KColors.activeTextColor.withValues(alpha: 0.82),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroChip(
                icon: Icons.library_books_outlined,
                label: '$totalGames total games',
              ),
              _HeroChip(
                icon: Icons.search_rounded,
                label: '$visibleGames visible now',
              ),
              _HeroChip(
                icon: Icons.emoji_events_outlined,
                label: '$totalAchievements tracked achievements',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  final GamesScreenController controller;

  const _SearchPanel({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.searchGamesList,
        style: const TextStyle(color: KColors.activeTextColor),
        decoration: InputDecoration(
          hintText: 'Search your Steam library',
          hintStyle: const TextStyle(color: KColors.inactiveTextColor),
          prefixIcon: const Icon(
            Icons.search,
            color: KColors.inactiveTextColor,
          ),
          suffixIcon: controller.searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    controller.searchController.clear();
                    controller.searchGamesList('');
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: KColors.inactiveTextColor,
                  ),
                ),
          filled: true,
          fillColor: KColors.backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionLabel({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: KColors.activeTextColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: KColors.inactiveTextColor,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
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

class _EmptyLibrarySearchState extends StatelessWidget {
  const _EmptyLibrarySearchState();

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
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: KColors.inactiveTextColor,
            size: 28,
          ),
          SizedBox(height: 10),
          Text(
            'No games matched that search.',
            style: TextStyle(
              color: KColors.activeTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'Try a shorter name or clear the search field to see your whole library again.',
            style: TextStyle(
              color: KColors.inactiveTextColor,
              fontSize: 14,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
