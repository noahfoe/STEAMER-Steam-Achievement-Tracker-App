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
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CustomNetworkImage(
                  url: playerSummary.avatar ?? '',
                  height: 90,
                  width: 90,
                  radius: 12,
                ),
                const SizedBox(height: 16),
                Text(
                  playerSummary.steamName ?? 'Unknown Steam User',
                  style: const TextStyle(
                    color: KColors.activeTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Steam Level $steamLevel',
                  style: const TextStyle(
                    color: KColors.inactiveTextColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
