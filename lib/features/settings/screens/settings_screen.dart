import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/services/utils/app_update_service.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/my_app_bar.dart';

const _releaseVersion = '1.1.0';

class SettingsScreen extends StatelessWidget {
  final Future<void> Function()? onSignOut;
  final Future<void> Function()? onRefreshLibrary;

  const SettingsScreen({
    Key? key,
    this.onSignOut,
    this.onRefreshLibrary,
  }) : super(key: key);

  Future<void> _showAboutDialog(BuildContext context) async {
    showAboutDialog(
      context: context,
      applicationName: 'STEAMER',
      applicationVersion: _releaseVersion,
      applicationLegalese:
          'Steam achievement tracking companion app. Not affiliated with Valve.',
    );
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    await AppUpdateService.checkForUpdates(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(title: "Settings"),
      backgroundColor: KColors.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const _SettingsHero(),
          const SizedBox(height: 22),
          _SettingsSection(
            title: const _SectionLabel(
              title: 'General',
              subtitle:
                  'Version info, update visibility, and app identity details.',
            ),
            children: [
              _BasicSettingButton(
                title: "About",
                subtitle: "Version $_releaseVersion",
                icon: const Icon(
                  Icons.adb_outlined,
                  color: KColors.inactiveTextColor,
                ),
                onTap: () => _showAboutDialog(context),
              ),
              _BasicSettingButton(
                title: "Check for Updates",
                subtitle:
                    "Confirm your installed version and look for newer Play Store builds.",
                icon: const Icon(
                  Icons.system_update_alt_rounded,
                  color: KColors.inactiveTextColor,
                ),
                onTap: () => _checkForUpdates(context),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SettingsSection(
            title: const _SectionLabel(
              title: 'Account',
              subtitle:
                  'Manage your session and manually refresh Steam data when needed.',
            ),
            children: [
              _BasicSettingButton(
                title: "Sign Out",
                subtitle: "Sign out of your account.",
                icon: const Icon(
                  Icons.logout,
                  color: KColors.inactiveTextColor,
                ),
                onTap: onSignOut == null ? null : () => onSignOut!.call(),
              ),
              _BasicSettingButton(
                title: "Refresh Library",
                subtitle:
                    "Re-sync your profile, library, and achievements from Steam.",
                icon: const Icon(
                  Icons.refresh,
                  color: KColors.inactiveTextColor,
                ),
                onTap: onRefreshLibrary == null
                    ? null
                    : () => onRefreshLibrary!.call(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero();

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
            'Settings',
            style: TextStyle(
              color: KColors.activeTextColor,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep account actions, version info, and release polish in one place.',
            style: TextStyle(
              color: KColors.activeTextColor.withValues(alpha: 0.82),
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_outlined,
                  color: KColors.menuHighlightColor,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Current version 1.1.0',
                  style: TextStyle(
                    color: KColors.activeTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

class _SettingsSection extends StatelessWidget {
  final Widget title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
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
          title,
          const SizedBox(height: 12),
          ...children,
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

class _BasicSettingButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Icon icon;
  final Function()? onTap;

  const _BasicSettingButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          width: double.infinity,
          decoration: BoxDecoration(
            color: KColors.backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: KColors.activeTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: KColors.inactiveTextColor,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right_rounded,
                color: KColors.inactiveTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
