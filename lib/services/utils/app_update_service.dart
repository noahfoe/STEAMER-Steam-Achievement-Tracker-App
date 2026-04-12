import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateService {
  static Future<void> checkForUpdates(BuildContext context) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      _showMessage(
        context,
        'In-app update checks are only available on Android devices.',
      );
      return;
    }

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability != UpdateAvailability.updateAvailable) {
        if (!context.mounted) {
          return;
        }
        _showMessage(
          context,
          'You are already on the latest available version of STEAMER.',
        );
        return;
      }

      if (updateInfo.immediateUpdateAllowed) {
        if (!context.mounted) {
          return;
        }
        final shouldUpdate = await _showUpdatePrompt(
          context,
          title: 'Update Available',
          message:
              'A newer version of STEAMER is available. Update now to get the latest fixes and improvements.',
          actionLabel: 'Update Now',
        );

        if (shouldUpdate != true) {
          return;
        }

        if (!context.mounted) {
          return;
        }
        await InAppUpdate.performImmediateUpdate();
        return;
      }

      if (updateInfo.flexibleUpdateAllowed) {
        if (!context.mounted) {
          return;
        }
        final shouldUpdate = await _showUpdatePrompt(
          context,
          title: 'Update Ready to Download',
          message:
              'A newer version of STEAMER is available. Download and install it now?',
          actionLabel: 'Download',
        );

        if (shouldUpdate != true) {
          return;
        }

        if (!context.mounted) {
          return;
        }
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();

        if (context.mounted) {
          _showMessage(
            context,
            'The update has been downloaded. Android may finish installing it in the background.',
          );
        }
        return;
      }

      if (!context.mounted) {
        return;
      }
      _showMessage(
        context,
        'An update is available, but Google Play has not enabled an install flow for this build yet.',
      );
    } on PlatformException catch (error) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, _friendlyPlatformError(error));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showMessage(
        context,
        'We could not check for updates right now. Please try again in a moment.',
      );
    }
  }

  static Future<bool?> _showUpdatePrompt(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  static String _friendlyPlatformError(PlatformException error) {
    final code = error.code.toUpperCase();
    final message = (error.message ?? '').toLowerCase();

    if (code.contains('ERROR_API_NOT_AVAILABLE') ||
        message.contains('api not available')) {
      return 'Update checks only work on builds installed from Google Play. Debug and sideloaded installs will show this message.';
    }

    if (code.contains('ERROR_APP_NOT_OWNED') ||
        message.contains('app is not owned')) {
      return 'This Google account does not currently own the Play Store build needed for in-app updates.';
    }

    if (code.contains('ERROR_DOWNLOAD_NOT_PRESENT')) {
      return 'Google Play has not finished preparing the update yet. Please try again shortly.';
    }

    return 'Google Play could not complete the update check right now. ${error.code}';
  }

  static void _showMessage(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
