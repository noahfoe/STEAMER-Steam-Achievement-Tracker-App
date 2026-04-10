import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/network_icon_image.dart';
import 'package:steam_achievement_tracker/services/widgets/my_app_bar.dart';

enum AchievementFilter {
  all,
  perfected,
  inProgress,
}

enum AchievementSort {
  nameAsc,
  nameDesc,
  mostAchievements,
  fewestLocked,
}

class AchievementsScreen extends StatefulWidget {
  final List<GameDetails> gameDetails;
  final List<Game> playerGames;

  const AchievementsScreen({
    super.key,
    required this.gameDetails,
    required this.playerGames,
  });

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final TextEditingController _searchController = TextEditingController();
  AchievementFilter _filter = AchievementFilter.all;
  AchievementSort _sort = AchievementSort.nameAsc;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalAchievements = widget.gameDetails
        .map((e) => e.allAchievements ?? const [])
        .expand((e) => e)
        .length;
    final unlockedAchievements = widget.gameDetails
        .map((e) => e.unlockedAchievements ?? const [])
        .expand((e) => e)
        .length;
    final lockedAchievements = widget.gameDetails
        .map((e) => e.lockedAchievements ?? const [])
        .expand((e) => e)
        .length;
    final allAchievementGames = widget.gameDetails
        .where((details) => (details.allAchievements ?? const []).isNotEmpty)
        .toList(growable: false);
    final perfectedGames = allAchievementGames
        .where(
          (details) =>
              (details.lockedAchievements ?? const []).isEmpty,
        )
        .toList(growable: false)
      ..sort(
        (a, b) => (a.gameName ?? '').toLowerCase().compareTo(
          (b.gameName ?? '').toLowerCase(),
        ),
      );
    final visibleGames = _buildVisibleGames(allAchievementGames);

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
            'Achievement Browser',
            style: TextStyle(
              color: KColors.activeTextColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: KColors.activeTextColor),
            decoration: InputDecoration(
              hintText: 'Search games',
              hintStyle: const TextStyle(color: KColors.inactiveTextColor),
              prefixIcon: const Icon(
                Icons.search,
                color: KColors.inactiveTextColor,
              ),
              filled: true,
              fillColor: KColors.primaryColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackControls = constraints.maxWidth < 430;
              final controls = [
                _buildFilterDropdown(),
                _buildSortDropdown(),
              ];

              if (stackControls) {
                return Column(
                  children: [
                    controls[0],
                    const SizedBox(height: 12),
                    controls[1],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: controls[0]),
                  const SizedBox(width: 12),
                  Expanded(child: controls[1]),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            _filter == AchievementFilter.perfected
                ? 'Perfected Games'
                : _filter == AchievementFilter.inProgress
                    ? 'Games In Progress'
                    : 'All Games With Achievements',
            style: const TextStyle(
              color: KColors.inactiveTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          if (visibleGames.isEmpty)
            const Text(
              'No games match the current search/filter.',
              style: TextStyle(
                color: KColors.inactiveTextColor,
              ),
            )
          else
            ...visibleGames.map(
              (details) {
                final matchingGame = widget.playerGames.cast<Game?>().firstWhere(
                      (game) => game?.name == details.gameName,
                      orElse: () => null,
                    );
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: KColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (matchingGame?.imgIconUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: NetworkIconImage(
                            imageUrl: matchingGame!.imgIconUrl!,
                            size: 44,
                            borderRadius: 10,
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details.gameName ?? 'Unknown Game',
                              style: const TextStyle(
                                color: KColors.activeTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(details.unlockedAchievements ?? const []).length}/${(details.allAchievements ?? const []).length} unlocked',
                              style: const TextStyle(
                                color: KColors.inactiveTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if ((details.lockedAchievements ?? const []).isEmpty)
                        const Icon(
                          Icons.verified_rounded,
                          color: KColors.menuHighlightColor,
                          size: 20,
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  List<GameDetails> _buildVisibleGames(List<GameDetails> source) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = source.where((details) {
      final matchesSearch =
          (details.gameName ?? '').toLowerCase().contains(query);
      if (!matchesSearch) {
        return false;
      }
      switch (_filter) {
        case AchievementFilter.all:
          return true;
        case AchievementFilter.perfected:
          return (details.lockedAchievements ?? const []).isEmpty;
        case AchievementFilter.inProgress:
          return (details.lockedAchievements ?? const []).isNotEmpty;
      }
    }).toList(growable: false);

    filtered.sort((a, b) {
      switch (_sort) {
        case AchievementSort.nameAsc:
          return (a.gameName ?? '').toLowerCase().compareTo(
                (b.gameName ?? '').toLowerCase(),
              );
        case AchievementSort.nameDesc:
          return (b.gameName ?? '').toLowerCase().compareTo(
                (a.gameName ?? '').toLowerCase(),
              );
        case AchievementSort.mostAchievements:
          return (b.allAchievements ?? const [])
              .length
              .compareTo((a.allAchievements ?? const []).length);
        case AchievementSort.fewestLocked:
          return (a.lockedAchievements ?? const [])
              .length
              .compareTo((b.lockedAchievements ?? const []).length);
      }
    });
    return filtered;
  }

  Widget _buildFilterDropdown() {
    return DropdownButtonFormField<AchievementFilter>(
      initialValue: _filter,
      isExpanded: true,
      dropdownColor: KColors.primaryColor,
      decoration: _dropdownDecoration('Filter'),
      style: const TextStyle(color: KColors.activeTextColor),
      items: const [
        DropdownMenuItem(
          value: AchievementFilter.all,
          child: Text(
            'All',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem(
          value: AchievementFilter.perfected,
          child: Text(
            'Perfected',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem(
          value: AchievementFilter.inProgress,
          child: Text(
            'In Progress',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _filter = value);
        }
      },
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButtonFormField<AchievementSort>(
      initialValue: _sort,
      isExpanded: true,
      dropdownColor: KColors.primaryColor,
      decoration: _dropdownDecoration('Sort'),
      style: const TextStyle(color: KColors.activeTextColor),
      items: const [
        DropdownMenuItem(
          value: AchievementSort.nameAsc,
          child: Text(
            'Name A-Z',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem(
          value: AchievementSort.nameDesc,
          child: Text(
            'Name Z-A',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem(
          value: AchievementSort.mostAchievements,
          child: Text(
            'Most Achievements',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem(
          value: AchievementSort.fewestLocked,
          child: Text(
            'Fewest Locked',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _sort = value);
        }
      },
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: KColors.inactiveTextColor),
      filled: true,
      fillColor: KColors.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
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
