import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/features/games/screens/game_details_screen.dart';
import 'package:steam_achievement_tracker/services/models/games/achievement_game_summary.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/utils/app_route.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/utils/database.dart';
import 'package:steam_achievement_tracker/services/utils/preference_utils.dart';
import 'package:steam_achievement_tracker/services/widgets/async_state_panel.dart';
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
  final String steamID;
  final List<Game> playerGames;

  const AchievementsScreen({
    super.key,
    required this.steamID,
    required this.playerGames,
  });

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Database _database = Database.instance;

  AchievementFilter _filter = AchievementFilter.all;
  AchievementSort _sort = AchievementSort.nameAsc;
  List<AchievementGameSummary> _summaries = <AchievementGameSummary>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSummaries({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!forceRefresh) {
        final cached = PreferenceUtils.getAchievementGameSummaries();
        if (cached.isNotEmpty) {
          _summaries = cached;
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }

      final fresh = await _database.getAchievementGameSummaries(
        steamID: widget.steamID,
      );
      _summaries = fresh;
      await PreferenceUtils.setAchievementGameSummaries(fresh);

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAchievements =
        _summaries.fold<int>(0, (sum, game) => sum + game.totalAchievements);
    final unlockedAchievements =
        _summaries.fold<int>(0, (sum, game) => sum + game.unlockedAchievements);
    final lockedAchievements =
        _summaries.fold<int>(0, (sum, game) => sum + game.lockedAchievements);
    final perfectedGames =
        _summaries.where((game) => game.isPerfected).toList(growable: false)
          ..sort(
            (a, b) =>
                a.gameName.toLowerCase().compareTo(b.gameName.toLowerCase()),
          );
    final visibleGames = _buildVisibleGames(_summaries);

    return Scaffold(
      backgroundColor: KColors.backgroundColor,
      appBar: myAppBar(title: 'Achievements'),
      body: _buildBody(
        context,
        totalAchievements: totalAchievements,
        unlockedAchievements: unlockedAchievements,
        lockedAchievements: lockedAchievements,
        perfectedGames: perfectedGames.length,
        visibleGames: visibleGames,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required int totalAchievements,
    required int unlockedAchievements,
    required int lockedAchievements,
    required int perfectedGames,
    required List<AchievementGameSummary> visibleGames,
  }) {
    if (_isLoading && _summaries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: KColors.menuHighlightColor,
        ),
      );
    }

    if (_errorMessage != null && _summaries.isEmpty) {
      return AsyncStatePanel(
        icon: Icons.cloud_off_rounded,
        title: 'Achievements Unavailable',
        message: _errorMessage!,
        actionLabel: 'Retry',
        onAction: () => _loadSummaries(forceRefresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadSummaries(forceRefresh: true),
      color: KColors.menuHighlightColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          _AchievementsHero(
            totalAchievements: totalAchievements,
            unlockedAchievements: unlockedAchievements,
            perfectedGames: perfectedGames,
          ),
          const SizedBox(height: 18),
          if (_isLoading)
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: KColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
                ),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: KColors.menuHighlightColor,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Refreshing achievement summaries...',
                      style: TextStyle(
                        color: KColors.activeTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                value: '$perfectedGames',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionLabel(
            title: 'Achievement Browser',
            subtitle:
                'Search, filter, and sort the games that currently expose achievement data.',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KColors.primaryColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: KColors.activeTextColor),
                  decoration: InputDecoration(
                    hintText: 'Search games',
                    hintStyle:
                        const TextStyle(color: KColors.inactiveTextColor),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: KColors.inactiveTextColor,
                    ),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ListModeBanner(
            label: _filter == AchievementFilter.perfected
                ? 'Perfected Games'
                : _filter == AchievementFilter.inProgress
                    ? 'Games In Progress'
                    : 'All Games With Achievements',
          ),
          const SizedBox(height: 12),
          if (visibleGames.isEmpty)
            const _EmptyAchievementsState()
          else
            ...visibleGames.map((summary) => _buildSummaryCard(context, summary)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    AchievementGameSummary summary,
  ) {
    final matchingGame = widget.playerGames.cast<Game?>().firstWhere(
          (game) => game?.appId == summary.appId,
          orElse: () => null,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: matchingGame == null
              ? null
              : () {
                  Navigator.of(context).push(
                    AppRoute.fadeSlide(
                      builder: (context) => GameDetailsScreen(
                        steamID: widget.steamID,
                        game: matchingGame,
                        gameDetails: GameDetails.empty(),
                      ),
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (summary.imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: NetworkIconImage(
                      imageUrl: summary.imageUrl,
                      size: 44,
                      borderRadius: 10,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.gameName,
                        style: const TextStyle(
                          color: KColors.activeTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${summary.unlockedAchievements}/${summary.totalAchievements} unlocked',
                        style: const TextStyle(
                          color: KColors.inactiveTextColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        minHeight: 7,
                        value: summary.totalAchievements == 0
                            ? 0
                            : summary.unlockedAchievements /
                                summary.totalAchievements,
                        backgroundColor: KColors.backgroundColor,
                        valueColor: const AlwaysStoppedAnimation(
                          KColors.menuHighlightColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    summary.isPerfected
                        ? Icons.verified_rounded
                        : Icons.chevron_right_rounded,
                    color: summary.isPerfected
                        ? KColors.menuHighlightColor
                        : KColors.inactiveTextColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<AchievementGameSummary> _buildVisibleGames(
    List<AchievementGameSummary> source,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = source.where((details) {
      final matchesSearch = details.gameName.toLowerCase().contains(query);
      if (!matchesSearch) {
        return false;
      }
      switch (_filter) {
        case AchievementFilter.all:
          return true;
        case AchievementFilter.perfected:
          return details.isPerfected;
        case AchievementFilter.inProgress:
          return details.lockedAchievements > 0;
      }
    }).toList(growable: false);

    filtered.sort((a, b) {
      switch (_sort) {
        case AchievementSort.nameAsc:
          return a.gameName.toLowerCase().compareTo(b.gameName.toLowerCase());
        case AchievementSort.nameDesc:
          return b.gameName.toLowerCase().compareTo(a.gameName.toLowerCase());
        case AchievementSort.mostAchievements:
          return b.totalAchievements.compareTo(a.totalAchievements);
        case AchievementSort.fewestLocked:
          return a.lockedAchievements.compareTo(b.lockedAchievements);
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
          child: Text('All', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: AchievementFilter.perfected,
          child: Text('Perfected', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: AchievementFilter.inProgress,
          child: Text('In Progress', overflow: TextOverflow.ellipsis),
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
          child: Text('Name A-Z', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: AchievementSort.nameDesc,
          child: Text('Name Z-A', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: AchievementSort.mostAchievements,
          child: Text('Most Achievements', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: AchievementSort.fewestLocked,
          child: Text('Fewest Locked', overflow: TextOverflow.ellipsis),
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
      fillColor: KColors.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _AchievementsHero extends StatelessWidget {
  final int totalAchievements;
  final int unlockedAchievements;
  final int perfectedGames;

  const _AchievementsHero({
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.perfectedGames,
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
            Color(0xff20374b),
            Color(0xff162231),
            KColors.primaryColor,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Achievement Command Center',
            style: TextStyle(
              color: KColors.activeTextColor,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'See what is done, what is close, and which games are already fully completed.',
            style: TextStyle(
              color: KColors.activeTextColor.withValues(alpha: 0.82),
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroChip(
                icon: Icons.emoji_events_outlined,
                label: '$totalAchievements tracked',
              ),
              _HeroChip(
                icon: Icons.check_circle_outline_rounded,
                label: '$unlockedAchievements unlocked',
              ),
              _HeroChip(
                icon: Icons.verified_rounded,
                label: '$perfectedGames perfected',
              ),
            ],
          ),
        ],
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

class _ListModeBanner extends StatelessWidget {
  final String label;

  const _ListModeBanner({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.tune_rounded,
            color: KColors.menuHighlightColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: KColors.activeTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAchievementsState extends StatelessWidget {
  const _EmptyAchievementsState();

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
            Icons.filter_alt_off_rounded,
            color: KColors.inactiveTextColor,
            size: 28,
          ),
          SizedBox(height: 10),
          Text(
            'No games match the current search or filters.',
            style: TextStyle(
              color: KColors.activeTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'Clear the search field or switch filters to see more games with achievement progress.',
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
