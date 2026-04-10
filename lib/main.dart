// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/features/home/screens/home_screen.dart';
import 'package:steam_achievement_tracker/features/login/screens/login_screen.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/utils/database.dart';
import 'package:steam_achievement_tracker/services/utils/logger.dart';
import 'package:steam_achievement_tracker/services/utils/preference_utils.dart';

Future<void> main() async {
  registerFlutterErrorHandler(
    (error, trace) => logger.e(error, stackTrace: trace),
  );
  await PreferenceUtils.init();
  Get.put(Database.instance);
  runApp(
    MyApp(
      initialSteamId: PreferenceUtils.getLastSteamId(),
    ),
  );
}

/// Registers an error callback for uncaught exceptions and flutter errors.
void registerFlutterErrorHandler(
  void Function(Object error, StackTrace? trace) handler,
) {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    handler(error, stack);
    return false;
  };
  FlutterError.onError = (details) => handler(details.exception, details.stack);
}

class MyApp extends StatelessWidget {
  final String? initialSteamId;

  const MyApp({
    super.key,
    required this.initialSteamId,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'STEAMER',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: KColors.menuHighlightColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: KColors.backgroundColor,
        canvasColor: KColors.backgroundColor,
        cardColor: KColors.primaryColor,
        dividerColor: KColors.lightBackgroundColor,
        splashColor: KColors.menuHighlightColor.withValues(alpha: 0.08),
        highlightColor: KColors.menuHighlightColor.withValues(alpha: 0.06),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: initialSteamId == null || initialSteamId!.isEmpty
          ? const LoginScreen()
          : HomeScreen(steamID: initialSteamId!),
    );
  }
}
