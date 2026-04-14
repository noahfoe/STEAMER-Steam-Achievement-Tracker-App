import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/services/utils/app_update_service.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/my_app_bar.dart';

const _releaseVersion = '1.1.2';

class SettingsScreen extends StatefulWidget {
  final Future<void> Function()? onSignOut;
  final Future<void> Function()? onRefreshLibrary;

  const SettingsScreen({
    Key? key,
    this.onSignOut,
    this.onRefreshLibrary,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isRefreshingLibrary = false;
  String? _refreshStatusMessage;
  bool _refreshWasSuccessful = false;

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

  Future<void> _refreshLibrary(BuildContext context) async {
    if (widget.onRefreshLibrary == null || _isRefreshingLibrary) {
      return;
    }

    setState(() {
      _isRefreshingLibrary = true;
      _refreshWasSuccessful = false;
      _refreshStatusMessage =
          'Refreshing your Steam profile, library, and dashboard data...';
    });

    try {
      await widget.onRefreshLibrary!.call();

      if (!mounted) {
        return;
      }

      setState(() {
        _isRefreshingLibrary = false;
        _refreshWasSuccessful = true;
        _refreshStatusMessage =
            'Library refresh complete. Your latest Steam data is ready.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isRefreshingLibrary = false;
        _refreshWasSuccessful = false;
        _refreshStatusMessage = error.toString();
      });
    }
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _refreshStatusMessage == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _RefreshStatusCard(
                      isLoading: _isRefreshingLibrary,
                      isSuccess: _refreshWasSuccessful,
                      message: _refreshStatusMessage!,
                    ),
                  ),
          ),
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
                onTap: widget.onSignOut == null || _isRefreshingLibrary
                    ? null
                    : () => widget.onSignOut!.call(),
              ),
              _BasicSettingButton(
                title: "Refresh Library",
                subtitle: _isRefreshingLibrary
                    ? "Refreshing your Steam data now. This may take a moment."
                    : "Re-sync your profile, library, and achievements from Steam.",
                icon: Icon(
                  _isRefreshingLibrary ? Icons.sync_rounded : Icons.refresh,
                  color: _isRefreshingLibrary
                      ? KColors.menuHighlightColor
                      : KColors.inactiveTextColor,
                ),
                trailing: _isRefreshingLibrary
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: KColors.menuHighlightColor,
                        ),
                      )
                    : null,
                isEnabled:
                    widget.onRefreshLibrary != null && !_isRefreshingLibrary,
                onTap: widget.onRefreshLibrary == null
                    ? null
                    : () => _refreshLibrary(context),
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
                  'Current version $_releaseVersion',
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
  final Widget? trailing;
  final bool isEnabled;
  final Function()? onTap;

  const _BasicSettingButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.subtitle,
    this.trailing,
    this.isEnabled = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isEnabled
                ? KColors.backgroundColor
                : KColors.backgroundColor.withValues(alpha: 0.6),
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
                      style: TextStyle(
                        color: isEnabled
                            ? KColors.activeTextColor
                            : KColors.inactiveTextColor,
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
              trailing ??
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

class _RefreshStatusCard extends StatelessWidget {
  final bool isLoading;
  final bool isSuccess;
  final String message;

  const _RefreshStatusCard({
    required this.isLoading,
    required this.isSuccess,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isLoading
        ? KColors.menuHighlightColor
        : isSuccess
            ? const Color(0xff7dd3a3)
            : const Color(0xfff4b266);

    final icon = isLoading
        ? Icons.sync_rounded
        : isSuccess
            ? Icons.check_circle_rounded
            : Icons.info_outline_rounded;

    final title = isLoading
        ? 'Refreshing Library'
        : isSuccess
            ? 'Refresh Complete'
            : 'Refresh Notice';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: KColors.menuHighlightColor,
                    ),
                  )
                : Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
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
                  message,
                  style: const TextStyle(
                    color: KColors.inactiveTextColor,
                    fontSize: 13,
                    height: 1.35,
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
