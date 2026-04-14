// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/features/home/controllers/home_screen_controller.dart';
import 'package:steam_achievement_tracker/features/profile/screens/achievements_screen.dart';
import 'package:steam_achievement_tracker/features/profile/screens/profile_screen.dart';
import 'package:steam_achievement_tracker/features/settings/screens/settings_screen.dart';
import 'package:steam_achievement_tracker/services/models/games/dashboard_summary.dart';
import 'package:steam_achievement_tracker/services/models/user/user_steam_information.dart';
import 'package:steam_achievement_tracker/services/utils/app_route.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/utils/demo_mode.dart';
import 'package:steam_achievement_tracker/services/utils/extensions/int_extensions.dart';
import 'package:steam_achievement_tracker/services/utils/extensions/string_extensions.dart';
import 'package:steam_achievement_tracker/services/widgets/async_state_panel.dart';
import 'package:steam_achievement_tracker/services/widgets/button.dart';
import 'package:steam_achievement_tracker/services/widgets/custom_image.dart';
import 'package:steam_achievement_tracker/services/widgets/my_app_bar.dart';

class HomeScreen extends StatelessWidget {
  final String steamID;
  final bool forceInitialRefresh;

  const HomeScreen({
    super.key,
    required this.steamID,
    this.forceInitialRefresh = false,
  });

  String _achievementStatValue(
    String Function() resolver,
  ) {
    return resolver();
  }

  String _summaryAchievementValue(
    HomeScreenController controller,
    DashboardSummary summary,
    int summaryValue,
    int Function() fallback,
  ) {
    if (!summary.isEmpty) {
      return summaryValue.toString().toNumberFormat();
    }
    return _achievementStatValue(() => fallback().toString().toNumberFormat());
  }

  String _summaryTotalGames(
    HomeScreenController controller,
    DashboardSummary summary,
  ) {
    if (!summary.isEmpty) {
      return summary.totalGames.toString().toNumberFormat();
    }
    return controller.playerGamesList.length.toString().toNumberFormat();
  }

  String _summaryTotalHours(
    HomeScreenController controller,
    DashboardSummary summary,
  ) {
    if (!summary.isEmpty) {
      return summary.totalHoursPlayed.minutesToHours().toString().toNumberFormat();
    }

    if (controller.playerGamesList.isNotEmpty) {
      return controller.playerGamesList
          .map((e) => e.playtimeForever)
          .reduce((value, element) => value! + element!)!
          .minutesToHours()
          .toString()
          .toNumberFormat();
    }

    return '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.backgroundColor,
      appBar: myAppBar(title: 'STEAMER'),
      drawer: const _Drawer(),
      body: GetBuilder<HomeScreenController>(
        init: HomeScreenController(
          steamID: steamID,
          forceInitialRefresh: forceInitialRefresh,
        ),
        builder: (controller) {
          return controller.obx(
            onLoading: const Center(
              child: CircularProgressIndicator(
                color: KColors.menuHighlightColor,
              ),
            ),
            onError: (error) => AsyncStatePanel(
              icon: Icons.cloud_off_rounded,
              title: 'Dashboard Unavailable',
              message: error ?? 'We could not load your Steam dashboard.',
              actionLabel: 'Retry',
              onAction: controller.refreshAllData,
            ),
            (state) => Stack(
              children: [
                RefreshIndicator.noSpinner(
                  onRefresh: controller.handlePullToRefresh,
                  onStatusChange: controller.handleRefreshStatusChange,
                  triggerMode: RefreshIndicatorTriggerMode.onEdge,
                  notificationPredicate: (notification) => notification.depth == 0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 920
                          ? 3
                          : constraints.maxWidth >= 620
                              ? 2
                              : 1;

                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                        children: [
                          Obx(
                            () {
                              final summary = controller.dashboardSummary.value;
                              final totalGames = _summaryTotalGames(
                                controller,
                                summary,
                              );
                              final totalHoursPlayed = _summaryTotalHours(
                                controller,
                                summary,
                              );
                              return _HeroPanel(
                                summary: controller.playerSummary.value,
                                steamLevel: controller.steamLevel.value,
                                steamId: controller.steamID,
                                totalGames: totalGames,
                                totalHoursPlayed: totalHoursPlayed,
                                onViewLibrary: () =>
                                    controller.navigateToGamesScreen(context),
                                onViewAchievements: () {
                                  Navigator.of(context).push(
                                    AppRoute.fadeSlide(
                                      builder: (context) => AchievementsScreen(
                                        steamID: controller.steamID,
                                        playerGames: controller.playerGamesList,
                                      ),
                                    ),
                                  );
                                },
                                isDemoMode:
                                    DemoMode.isDemoSteamId(controller.steamID),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          const _SectionLabel(
                            title: 'Dashboard',
                            subtitle:
                                'A quick snapshot of your profile, library, and achievement progress.',
                          ),
                          const SizedBox(height: 14),
                          Obx(
                            () {
                              final summary = controller.dashboardSummary.value;
                              final totalAchievements = _summaryAchievementValue(
                                controller,
                                summary,
                                summary.totalAchievements,
                                () => controller.gameDetails
                                    .map((e) => e.allAchievements ?? const [])
                                    .expand((e) => e)
                                    .length,
                              );
                              final unlockedAchievements =
                                  _summaryAchievementValue(
                                controller,
                                summary,
                                summary.unlockedAchievements,
                                () => controller.gameDetails
                                    .map(
                                      (e) => e.unlockedAchievements ?? const [],
                                    )
                                    .expand((e) => e)
                                    .length,
                              );
                              final lockedAchievements =
                                  _summaryAchievementValue(
                                controller,
                                summary,
                                summary.lockedAchievements,
                                () => controller.gameDetails
                                    .map((e) => e.lockedAchievements ?? const [])
                                    .expand((e) => e)
                                    .length,
                              );
                              final totalGames =
                                  _summaryTotalGames(controller, summary);
                              final totalHoursPlayed =
                                  _summaryTotalHours(controller, summary);
                              final perfectedGames = _summaryAchievementValue(
                                controller,
                                summary,
                                summary.perfectedGames,
                                () => controller.gameDetails
                                    .where(
                                      (e) =>
                                          (e.allAchievements ?? const [])
                                              .isNotEmpty &&
                                          (e.lockedAchievements ?? const [])
                                              .isEmpty,
                                    )
                                    .length,
                              );

                              final statCards = [
                                _StatCard(
                                  title: 'Total Achievements',
                                  value: totalAchievements,
                                  helper:
                                      'Every tracked achievement across your games',
                                  icon: Icons.emoji_events_outlined,
                                  accent: KColors.menuHighlightColor,
                                ),
                                _StatCard(
                                  title: 'Unlocked',
                                  value: unlockedAchievements,
                                  helper:
                                      'Achievements you have already earned',
                                  icon: Icons.check_circle_outline_rounded,
                                  accent: const Color(0xff7dd3a3),
                                ),
                                _StatCard(
                                  title: 'Locked',
                                  value: lockedAchievements,
                                  helper: 'Still waiting for you to finish',
                                  icon: Icons.lock_outline_rounded,
                                  accent: const Color(0xfff4b266),
                                ),
                                _StatCard(
                                  title: 'Total Games',
                                  value: totalGames,
                                  helper:
                                      'Visible games in your current library',
                                  icon: Icons.library_books_outlined,
                                  accent: const Color(0xff8ab4ff),
                                ),
                                _StatCard(
                                  title: 'Total Hours Played',
                                  value: totalHoursPlayed,
                                  helper:
                                      'Combined playtime across your library',
                                  icon: Icons.schedule_rounded,
                                  accent: const Color(0xff85d7ff),
                                ),
                                _StatCard(
                                  title: 'Perfected Games',
                                  value: perfectedGames,
                                  helper:
                                      'Games with every tracked achievement unlocked',
                                  icon: Icons.verified_rounded,
                                  accent: const Color(0xff89e5c6),
                                ),
                              ];

                              const horizontalSpacing = 14.0;
                              final cardWidth = columns == 1
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth -
                                          (horizontalSpacing * (columns - 1))) /
                                      columns;

                              return Column(
                                children: [
                                  Wrap(
                                    spacing: horizontalSpacing,
                                    runSpacing: 14,
                                    children: statCards
                                        .map(
                                          (card) => SizedBox(
                                            width: cardWidth,
                                            child: card,
                                          ),
                                        )
                                        .toList(growable: false),
                                  ),
                                  const SizedBox(height: 22),
                                  _ProgressHighlights(
                                    totalAchievements: totalAchievements,
                                    unlockedAchievements: unlockedAchievements,
                                    perfectedGames: perfectedGames,
                                    totalGames: totalGames,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          const Center(
                            child: Text(
                              'Pull down to refresh your Steam profile and achievements.',
                              style: TextStyle(
                                color: KColors.inactiveTextColor,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const _PullRefreshOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final UserSteamInformation summary;
  final int steamLevel;
  final String steamId;
  final String totalGames;
  final String totalHoursPlayed;
  final VoidCallback onViewLibrary;
  final VoidCallback onViewAchievements;
  final bool isDemoMode;

  const _HeroPanel({
    required this.summary,
    required this.steamLevel,
    required this.steamId,
    required this.totalGames,
    required this.totalHoursPlayed,
    required this.onViewLibrary,
    required this.onViewAchievements,
    required this.isDemoMode,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: KColors.menuHighlightColor.withValues(alpha: 0.4),
                  ),
                ),
                child: CustomNetworkImage(
                  url: summary.avatar ?? '',
                  height: 88,
                  width: 88,
                  radius: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.steamName ?? 'Steam User',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: KColors.activeTextColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PillTag(
                          icon: Icons.star_border_rounded,
                          text: 'Level $steamLevel',
                        ),
                        _PillTag(
                          icon: Icons.videogame_asset_outlined,
                          text: '$totalGames games',
                        ),
                        _PillTag(
                          icon: Icons.schedule_rounded,
                          text: '$totalHoursPlayed hours',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Everything important from your Steam account, distilled into one dashboard.',
            style: TextStyle(
              color: KColors.activeTextColor.withValues(alpha: 0.84),
              fontSize: 15,
              height: 1.35,
            ),
          ),
          if (isDemoMode) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: KColors.menuHighlightColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: KColors.menuHighlightColor.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.science_outlined,
                    color: KColors.menuHighlightColor,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Closed testing mode is active. This account uses sample data so testers can explore the full app without Steam sign-in.',
                      style: TextStyle(
                        color: KColors.activeTextColor,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Button(
                onTap: onViewLibrary,
                text: 'View Library',
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
              _SecondaryActionButton(
                label: 'View Achievements',
                icon: Icons.emoji_events_outlined,
                onTap: onViewAchievements,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Steam ID: $steamId',
              style: const TextStyle(
                color: KColors.inactiveTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String helper;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.value,
    required this.helper,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final minHeight = textScale >= 1.3
        ? 190.0
        : textScale >= 1.15
            ? 172.0
            : 154.0;

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: KColors.inactiveTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 34,
                fontWeight: FontWeight.w700,
                height: 0.95,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            helper,
            style: const TextStyle(
              color: KColors.activeTextColor,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHighlights extends StatelessWidget {
  final String totalAchievements;
  final String unlockedAchievements;
  final String perfectedGames;
  final String totalGames;

  const _ProgressHighlights({
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.perfectedGames,
    required this.totalGames,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          const Text(
            'Progress Notes',
            style: TextStyle(
              color: KColors.activeTextColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your latest profile snapshot is loaded and ready to browse.',
            style: TextStyle(
              color: KColors.inactiveTextColor,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          _InsightRow(
            leading: 'Unlocked',
            trailing:
                '$unlockedAchievements of $totalAchievements tracked achievements',
          ),
          const SizedBox(height: 10),
          _InsightRow(
            leading: 'Perfected',
            trailing: '$perfectedGames of $totalGames games fully completed',
          ),
        ],
      ),
    );
  }
}

class _PullRefreshOverlay extends GetView<HomeScreenController> {
  const _PullRefreshOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Obx(() {
            final progress = controller.pullRefreshProgress.value;
            final isRefreshing = controller.isPullRefreshing.value;
            final status = controller.pullRefreshStatus.value;
            final isVisible = progress > 0 || isRefreshing;

            if (!isVisible) {
              return const SizedBox.shrink();
            }

            final slideY = isRefreshing ? 0.0 : (1 - progress) * -0.9;
            final opacity = isRefreshing ? 1.0 : progress.clamp(0.0, 1.0);
            final scale = isRefreshing ? 1.0 : 0.86 + (progress * 0.14);
            final label = isRefreshing
                ? 'Loading...'
                : status == RefreshIndicatorStatus.armed ||
                        status == RefreshIndicatorStatus.snap
                    ? 'Release to refresh'
                    : 'Pull to refresh';

            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                offset: Offset(0, slideY),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 140),
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: KColors.primaryColor.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color:
                              KColors.menuHighlightColor.withValues(alpha: 0.32),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isRefreshing)
                            const _MiniRefreshDots()
                          else
                            Transform.rotate(
                              angle: progress * 1.2,
                              child: const Icon(
                                Icons.arrow_downward_rounded,
                                size: 16,
                                color: KColors.menuHighlightColor,
                              ),
                            ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: KColors.activeTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _MiniRefreshDots extends StatefulWidget {
  const _MiniRefreshDots();

  @override
  State<_MiniRefreshDots> createState() => _MiniRefreshDotsState();
}

class _MiniRefreshDotsState extends State<_MiniRefreshDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final shifted = (_controller.value - (index * 0.18)) % 1;
            final wave = shifted < 0 ? shifted + 1 : shifted;
            final opacity = 0.28 + ((1 - wave) * 0.72).clamp(0.0, 0.72);

            return Container(
              margin: EdgeInsets.only(right: index == 2 ? 0 : 4),
              height: 6,
              width: 6,
              decoration: BoxDecoration(
                color: KColors.menuHighlightColor.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String leading;
  final String trailing;

  const _InsightRow({
    required this.leading,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 3),
          height: 8,
          width: 8,
          decoration: const BoxDecoration(
            color: KColors.menuHighlightColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$leading: ',
                  style: const TextStyle(
                    color: KColors.activeTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: trailing,
                  style: const TextStyle(
                    color: KColors.inactiveTextColor,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PillTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PillTag({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: KColors.activeTextColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: KColors.menuHighlightColor, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
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

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: KColors.activeTextColor.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: KColors.activeTextColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: KColors.activeTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final String text;
  final Icon icon;
  final Function()? onTap;

  const DrawerTile({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: const BoxDecoration(
            color: KColors.backgroundColor,
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(color: KColors.activeTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerHeader extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final int steamLevel;

  const DrawerHeader({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.steamLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          CustomNetworkImage(
            url: avatarUrl,
            radius: 5,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: KColors.activeTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Steam Level: $steamLevel',
                  style: const TextStyle(
                    color: KColors.inactiveTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Drawer extends GetView<HomeScreenController> {
  const _Drawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: KColors.primaryColor,
      child: ListView(
        children: [
          const SizedBox(height: 10),
          Obx(
            () => DrawerHeader(
              avatarUrl: controller.playerSummary.value.avatar!,
              steamLevel: controller.steamLevel.value,
              name: controller.playerSummary.value.steamName!,
            ),
          ),
          const SizedBox(height: 10),
          DrawerTile(
            text: 'Profile',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                AppRoute.fadeSlide(
                  builder: (context) => ProfileScreen(
                    playerSummary: controller.playerSummary.value,
                    steamLevel: controller.steamLevel.value,
                    steamId: controller.steamID,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.person_outline,
              color: KColors.inactiveTextColor,
            ),
          ),
          DrawerTile(
            text: 'Library',
            onTap: () {
              Navigator.of(context).pop();
              controller.navigateToGamesScreen(context);
            },
            icon: const Icon(
              Icons.library_books_outlined,
              color: KColors.inactiveTextColor,
            ),
          ),
          DrawerTile(
            text: 'Achievements',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                AppRoute.fadeSlide(
                  builder: (context) => AchievementsScreen(
                    steamID: controller.steamID,
                    playerGames: controller.playerGamesList,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.checklist_outlined,
              color: KColors.inactiveTextColor,
            ),
          ),
          const Divider(),
          DrawerTile(
            text: 'Settings',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                AppRoute.fadeSlide(
                  builder: (context) => SettingsScreen(
                    onRefreshLibrary: () async {
                      await controller.refreshAllData();
                    },
                    onSignOut: () async {
                      await controller.signOut(context);
                    },
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: KColors.inactiveTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
