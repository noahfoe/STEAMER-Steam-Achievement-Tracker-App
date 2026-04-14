// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';

class AppSkeletonizer extends StatelessWidget {
  final Widget child;

  const AppSkeletonizer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(
        baseColor: Color(0xff162231),
        highlightColor: Color(0xff24384c),
        duration: Duration(milliseconds: 1200),
      ),
      child: child,
    );
  }
}

class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          _HeroSkeleton(),
          SizedBox(height: 18),
          _SectionSkeleton(),
          SizedBox(height: 14),
          _StatGridSkeleton(),
          SizedBox(height: 22),
          _InsightCardSkeleton(),
        ],
      ),
    );
  }
}

class GamesScreenSkeleton extends StatelessWidget {
  const GamesScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          _HeroSkeleton(),
          SizedBox(height: 18),
          _SearchPanelSkeleton(),
          SizedBox(height: 18),
          _SectionSkeleton(),
          SizedBox(height: 14),
          _ListItemSkeleton(),
          _ListItemSkeleton(),
          _ListItemSkeleton(),
          _ListItemSkeleton(),
        ],
      ),
    );
  }
}

class AchievementsScreenSkeleton extends StatelessWidget {
  const AchievementsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          _HeroSkeleton(),
          SizedBox(height: 18),
          _MiniBannerSkeleton(),
          SizedBox(height: 18),
          _StatWrapSkeleton(),
          SizedBox(height: 24),
          _SectionSkeleton(),
          SizedBox(height: 12),
          _FilterPanelSkeleton(),
          SizedBox(height: 16),
          _MiniBannerSkeleton(),
          SizedBox(height: 12),
          _AchievementRowSkeleton(),
          _AchievementRowSkeleton(),
          _AchievementRowSkeleton(),
          _AchievementRowSkeleton(),
        ],
      ),
    );
  }
}

class GameDetailsScreenSkeleton extends StatelessWidget {
  final String gameName;

  const GameDetailsScreenSkeleton({
    super.key,
    required this.gameName,
  });

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          _GameHeroSkeleton(title: gameName),
          const SizedBox(height: 18),
          const _ExpandablePanelSkeleton(),
          const _ExpandablePanelSkeleton(),
          const _ExpandablePanelSkeleton(),
        ],
      ),
    );
  }
}

class ProfileScreenSkeleton extends StatelessWidget {
  const ProfileScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          _HeroSkeleton(),
          SizedBox(height: 22),
          _SectionSkeleton(),
          SizedBox(height: 14),
          _InfoRowSkeleton(),
          _InfoRowSkeleton(),
          _InfoRowSkeleton(),
        ],
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

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
            children: [
              Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading Steam User Profile',
                      style: TextStyle(
                        color: KColors.activeTextColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PillSkeleton(label: 'Level 999'),
                        _PillSkeleton(label: '999 games'),
                        _PillSkeleton(label: '9,999 hours'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Loading your Steam dashboard with profile, library, and achievement highlights.',
            style: TextStyle(
              color: KColors.activeTextColor,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillSkeleton extends StatelessWidget {
  final String label;

  const _PillSkeleton({
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
      child: Text(
        label,
        style: const TextStyle(
          color: KColors.activeTextColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loading Section',
          style: TextStyle(
            color: KColors.activeTextColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Loading section subtitle and supporting context for this screen.',
          style: TextStyle(
            color: KColors.inactiveTextColor,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _StatGridSkeleton extends StatelessWidget {
  const _StatGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: List.generate(
            6,
            (index) => const SizedBox(
              width: 172,
              child: _StatCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatWrapSkeleton extends StatelessWidget {
  const _StatWrapSkeleton();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        4,
        (index) => const SizedBox(
          width: 150,
          child: _SummaryCardSkeleton(),
        ),
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 154),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.6),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                height: 38,
                width: 38,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              Spacer(),
              Flexible(
                child: Text(
                  'Loading Card Title',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: KColors.inactiveTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            '9,999',
            style: TextStyle(
              color: KColors.activeTextColor,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Loading helper text for the dashboard stat card.',
            style: TextStyle(
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

class _SummaryCardSkeleton extends StatelessWidget {
  const _SummaryCardSkeleton();

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loading',
            style: TextStyle(
              color: KColors.inactiveTextColor,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '999',
            style: TextStyle(
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

class _InsightCardSkeleton extends StatelessWidget {
  const _InsightCardSkeleton();

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Notes',
            style: TextStyle(
              color: KColors.activeTextColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Loading summary insight card with a quick snapshot of current progress.',
            style: TextStyle(
              color: KColors.inactiveTextColor,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Unlocked: 999 of 9,999 tracked achievements',
            style: TextStyle(
              color: KColors.inactiveTextColor,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Perfected: 99 of 999 games fully completed',
            style: TextStyle(
              color: KColors.inactiveTextColor,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchPanelSkeleton extends StatelessWidget {
  const _SearchPanelSkeleton();

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
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: KColors.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _FilterPanelSkeleton extends StatelessWidget {
  const _FilterPanelSkeleton();

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
      child: const Column(
        children: [
          SizedBox(
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: KColors.backgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: KColors.backgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: KColors.backgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBannerSkeleton extends StatelessWidget {
  const _MiniBannerSkeleton();

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
      child: const Text(
        'Loading current state banner message',
        style: TextStyle(
          color: KColors.activeTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ListItemSkeleton extends StatelessWidget {
  const _ListItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            width: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loading Game Title',
                  style: TextStyle(
                    color: KColors.activeTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '999 minutes played',
                  style: TextStyle(
                    color: KColors.inactiveTextColor,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ListChipSkeleton(label: '99/100 unlocked'),
                    _ListChipSkeleton(label: '999 min in last 2 weeks'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListChipSkeleton extends StatelessWidget {
  final String label;

  const _ListChipSkeleton({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: KColors.menuHighlightColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: KColors.activeTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AchievementRowSkeleton extends StatelessWidget {
  const _AchievementRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            height: 44,
            width: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loading Achievement Game Name',
                  style: TextStyle(
                    color: KColors.activeTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '99/100 unlocked',
                  style: TextStyle(
                    color: KColors.inactiveTextColor,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
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

class _GameHeroSkeleton extends StatelessWidget {
  final String title;

  const _GameHeroSkeleton({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: KColors.primaryColor,
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            color: const Color(0xff20374b),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 100, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title.isEmpty ? 'Loading Game Name' : title,
                    style: const TextStyle(
                      color: KColors.activeTextColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _PillSkeleton(label: '99/100 unlocked'),
                      _PillSkeleton(label: '999 minutes played'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achievement Progress',
                  style: TextStyle(
                    color: KColors.activeTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
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

class _ExpandablePanelSkeleton extends StatelessWidget {
  const _ExpandablePanelSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loading Achievement Section',
            style: TextStyle(
              color: KColors.activeTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 14),
          _AchievementTileSkeleton(),
          SizedBox(height: 10),
          _AchievementTileSkeleton(),
          SizedBox(height: 10),
          _AchievementTileSkeleton(),
        ],
      ),
    );
  }
}

class _AchievementTileSkeleton extends StatelessWidget {
  const _AchievementTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loading Achievement Name',
                style: TextStyle(
                  color: KColors.activeTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Loading achievement description and rarity information.',
                style: TextStyle(
                  color: KColors.inactiveTextColor,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRowSkeleton extends StatelessWidget {
  const _InfoRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KColors.lightBackgroundColor.withValues(alpha: 0.55),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loading Label',
            style: TextStyle(
              color: KColors.inactiveTextColor,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Loading value for this account field',
            style: TextStyle(
              color: KColors.activeTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
