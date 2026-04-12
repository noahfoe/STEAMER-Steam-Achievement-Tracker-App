import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/services/models/user/user_steam_information.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/custom_image.dart';
import 'package:steam_achievement_tracker/services/widgets/my_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  final UserSteamInformation playerSummary;
  final int steamLevel;
  final String steamId;

  const ProfileScreen({
    super.key,
    required this.playerSummary,
    required this.steamLevel,
    required this.steamId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.backgroundColor,
      appBar: myAppBar(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          _ProfileHero(
            playerSummary: playerSummary,
            steamLevel: steamLevel,
          ),
          const SizedBox(height: 22),
          const _SectionLabel(
            title: 'Account Snapshot',
            subtitle:
                'A cleaner summary of the public profile details currently visible to STEAMER.',
          ),
          const SizedBox(height: 14),
          _ProfileInfoRow(label: 'Steam ID', value: steamId),
          _ProfileInfoRow(
            label: 'Display Name',
            value: playerSummary.steamName ?? 'Not available',
          ),
          _ProfileInfoRow(
            label: 'Real Name',
            value: playerSummary.realName ?? 'Not available',
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final UserSteamInformation playerSummary;
  final int steamLevel;

  const _ProfileHero({
    required this.playerSummary,
    required this.steamLevel,
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
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: KColors.menuHighlightColor.withValues(alpha: 0.4),
                  ),
                ),
                child: CustomNetworkImage(
                  url: playerSummary.avatar ?? '',
                  height: 90,
                  width: 90,
                  radius: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerSummary.steamName ?? 'Unknown Steam User',
                      style: const TextStyle(
                        color: KColors.activeTextColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      playerSummary.realName ?? 'No real name set on Steam',
                      style: TextStyle(
                        color: KColors.activeTextColor.withValues(alpha: 0.82),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _LevelPill(steamLevel: steamLevel),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your profile screen keeps the essentials readable and ready for reviewers, testers, and future screenshots.',
            style: TextStyle(
              color: KColors.activeTextColor.withValues(alpha: 0.82),
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  final int steamLevel;

  const _LevelPill({
    required this.steamLevel,
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
          const Icon(
            Icons.star_border_rounded,
            color: KColors.menuHighlightColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Steam Level $steamLevel',
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

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.label,
    required this.value,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: KColors.inactiveTextColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: KColors.activeTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
