// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/features/home/screens/home_screen.dart';
import 'package:steam_achievement_tracker/features/login/screens/steam_login.dart';

class LoginController extends GetxController {
  final Rx<String> steamID = ''.obs;

  /// Logs the user into their Steam account.
  void login(BuildContext context) async {
    try {
      // Send user to steam login page and wait until they return with their steamID
      var temp = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SteamLogin(),
        ),
      );
      // If the user didn't log in, don't continue
      if (temp == null || temp == '') {
        return;
      }
      steamID.value = temp;
      // Now with a steam id, we can send them to the home screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            steamID: steamID.value,
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
