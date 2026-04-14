// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/features/home/screens/home_screen.dart';
import 'package:steam_achievement_tracker/features/login/screens/steam_login.dart';
import 'package:steam_achievement_tracker/services/utils/app_route.dart';
import 'package:steam_achievement_tracker/services/utils/database.dart';
import 'package:steam_achievement_tracker/services/utils/demo_mode.dart';
import 'package:steam_achievement_tracker/services/utils/preference_utils.dart';

class LoginController extends GetxController {
  final Rx<String> steamID = ''.obs;
  final RxBool isLoggingIn = false.obs;

  /// Logs the user into their Steam account.
  void login(BuildContext context) async {
    if (isLoggingIn.value) {
      return;
    }
    isLoggingIn.value = true;
    try {
      // Send user to steam login page and wait until they return with their steamID
      var temp = await Navigator.of(context).push(
        AppRoute.fadeSlide(
          builder: (context) => const SteamLogin(),
        ),
      );
      // If the user didn't log in, don't continue
      if (temp == null || temp == '') {
        return;
      }
      steamID.value = temp;
      await PreferenceUtils.clearCachedData();
      await PreferenceUtils.setLastSteamId(steamID.value);
      // Now with a steam id, we can send them to the home screen
      Navigator.of(context).pushReplacement(
        AppRoute.fadeSlide(
          builder: (context) => HomeScreen(
            steamID: steamID.value,
            forceInitialRefresh: true,
          ),
        ),
      );
    } catch (e) {
      final message = e is AppNetworkException
          ? e.message
          : 'Steam sign-in failed. Please try again.';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      isLoggingIn.value = false;
    }
  }

  Future<void> loginWithTestMode(BuildContext context) async {
    if (isLoggingIn.value) {
      return;
    }

    steamID.value = DemoMode.steamId;
    await PreferenceUtils.clearCachedData();
    await PreferenceUtils.setLastSteamId(DemoMode.steamId);

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      AppRoute.fadeSlide(
        builder: (context) => const HomeScreen(
          steamID: DemoMode.steamId,
        ),
      ),
    );
  }
}
