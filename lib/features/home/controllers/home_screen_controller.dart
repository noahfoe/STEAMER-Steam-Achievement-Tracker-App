// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/features/games/screens/games_screen.dart';
import 'package:steam_achievement_tracker/features/login/screens/login_screen.dart';
import 'package:steam_achievement_tracker/services/models/games/dashboard_summary.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/models/user/user_steam_information.dart';
import 'package:steam_achievement_tracker/services/utils/app_route.dart';
import 'package:steam_achievement_tracker/services/utils/database.dart';
import 'package:steam_achievement_tracker/services/utils/preference_utils.dart';

class HomeScreenController extends GetxController with StateMixin<void> {
  final String steamID;

  final Database _database = Database.instance;

  HomeScreenController({required this.steamID}) {
    init();
  }

  final Rx<UserSteamInformation> playerSummary =
      UserSteamInformation.empty().obs;
  final Rx<DashboardSummary> dashboardSummary = DashboardSummary.empty().obs;
  final RxList<Game> playerGamesList = <Game>[].obs;
  final RxList<GameDetails> gameDetails = <GameDetails>[].obs;
  final RxInt steamLevel = 0.obs;
  final RxBool isLoadingApiProgress = false.obs;
  final RxBool isPullRefreshing = false.obs;
  final RxDouble pullRefreshProgress = 0.0.obs;
  final RxInt completedApiSteps = 0.obs;
  final RxInt totalApiSteps = 0.obs;
  final RxString apiProgressStatus = ''.obs;

  init() async {
    await _loadHomeData(showLoadingState: true, forceRefresh: false);
  }

  void getSharedPreferences() {
    steamLevel.value = PreferenceUtils.getSteamLevel();
    playerSummary.value = PreferenceUtils.getPlayerSummary();
    dashboardSummary.value = PreferenceUtils.getDashboardSummary();
    playerGamesList.assignAll(PreferenceUtils.getPlayerGamesList());
    gameDetails.assignAll(PreferenceUtils.getGameDetails());
    steamLevel.refresh();
    playerSummary.refresh();
    dashboardSummary.refresh();
    playerGamesList.refresh();
    gameDetails.refresh();
  }

  Future<void> _loadHomeData({
    required bool showLoadingState,
    required bool forceRefresh,
  }) async {
    if (showLoadingState) {
      change(null, status: RxStatus.loading());
    }

    try {
      if (!forceRefresh) {
        getSharedPreferences();
      }

      final pendingSteps = <_ApiProgressStep>[];

      if (forceRefresh || steamLevel.value == 0) {
        pendingSteps.add(
          _ApiProgressStep(
            label: 'Loading Steam level',
            task: () async {
              final level = await _database.getSteamLevel(steamID: steamID);
              steamLevel.value = level;
              await PreferenceUtils.setSteamLevel(level);
            },
          ),
        );
      }

      if (forceRefresh || playerSummary.value == UserSteamInformation.empty()) {
        pendingSteps.add(
          _ApiProgressStep(
            label: 'Loading Steam profile',
            task: () async {
              final summary = await _database.getPlayerSummary(steamID: steamID);
              playerSummary.value = summary;
              await PreferenceUtils.setPlayerSummary(summary);
            },
          ),
        );
      }

      if (forceRefresh || dashboardSummary.value.isEmpty) {
        pendingSteps.add(
          _ApiProgressStep(
            label: 'Loading dashboard summary',
            task: () async {
              final summary =
                  await _database.getDashboardSummary(steamID: steamID);
              dashboardSummary.value = summary;
              await PreferenceUtils.setDashboardSummary(summary);
            },
          ),
        );
      }

      if (forceRefresh || playerGamesList.isEmpty) {
        pendingSteps.add(
          _ApiProgressStep(
            label: 'Loading library',
            task: () async {
              final games = await _database.getPlayerGamesList(steamID: steamID);
              playerGamesList.assignAll(games);
              await PreferenceUtils.setPlayerGamesList(playerGamesList);
            },
          ),
        );
      }

      _startApiProgress(pendingSteps);
      final futures = pendingSteps.map((step) => _runApiStep(step)).toList();
      await Future.wait(futures);
      _finishApiProgress();
      update();
      change(null, status: RxStatus.success());
    } catch (e) {
      _finishApiProgress();
      if (showLoadingState ||
          playerGamesList.isEmpty ||
          playerSummary.value == UserSteamInformation.empty()) {
        change(null, status: RxStatus.error(e.toString()));
      } else {
        rethrow;
      }
    }
  }

  void _startApiProgress(List<_ApiProgressStep> steps) {
    totalApiSteps.value = steps.length;
    completedApiSteps.value = 0;
    isLoadingApiProgress.value = steps.isNotEmpty;
    apiProgressStatus.value = steps.isEmpty
        ? 'Using cached Steam data'
        : 'Starting Steam sync...';
  }

  Future<void> _runApiStep(_ApiProgressStep step) async {
    apiProgressStatus.value = step.label;
    await step.task();
    completedApiSteps.value = completedApiSteps.value + 1;
    apiProgressStatus.value =
        'Completed ${completedApiSteps.value} of ${totalApiSteps.value} requests';
  }

  void _finishApiProgress() {
    if (totalApiSteps.value == 0) {
      isLoadingApiProgress.value = false;
      apiProgressStatus.value = 'Using cached Steam data';
      return;
    }

    completedApiSteps.value = totalApiSteps.value;
    apiProgressStatus.value =
        'Steam sync complete: ${completedApiSteps.value} of ${totalApiSteps.value} requests finished';
    isLoadingApiProgress.value = false;
  }

  /// Navigate the user to the Games Screen.
  void navigateToGamesScreen(BuildContext context) {
    Navigator.of(context).push(
      AppRoute.fadeSlide(
        builder: (context) => GamesScreen(
          steamID: steamID,
          playerGamesList: playerGamesList,
          gameDetails: gameDetails,
          playerSummary: playerSummary.value,
        ),
      ),
    );
  }

  Future<void> refreshAllData() async {
    completedApiSteps.value = 0;
    totalApiSteps.value = 0;
    apiProgressStatus.value = '';
    await _loadHomeData(showLoadingState: false, forceRefresh: true);
  }

  Future<void> handlePullToRefresh() async {
    if (isPullRefreshing.value) {
      return;
    }

    isPullRefreshing.value = true;
    pullRefreshProgress.value = 1;
    final stopwatch = Stopwatch()..start();

    try {
      await refreshAllData();
    } finally {
      const minimumVisibleDuration = Duration(milliseconds: 1400);
      final elapsed = stopwatch.elapsed;
      if (elapsed < minimumVisibleDuration) {
        await Future<void>.delayed(minimumVisibleDuration - elapsed);
      }
      isPullRefreshing.value = false;
      pullRefreshProgress.value = 0;
    }
  }

  void updatePullRefreshProgress(double progress) {
    if (isPullRefreshing.value) {
      pullRefreshProgress.value = 1;
      return;
    }
    pullRefreshProgress.value = progress.clamp(0.0, 1.0);
  }

  void resetPullRefreshProgress() {
    if (isPullRefreshing.value) {
      return;
    }
    pullRefreshProgress.value = 0;
  }

  Future<void> signOut(BuildContext context) async {
    await PreferenceUtils.clearSessionData();
    playerSummary.value = UserSteamInformation.empty();
    dashboardSummary.value = DashboardSummary.empty();
    playerGamesList.clear();
    gameDetails.clear();
    steamLevel.value = 0;
    isLoadingApiProgress.value = false;
    isPullRefreshing.value = false;
    pullRefreshProgress.value = 0;
    completedApiSteps.value = 0;
    totalApiSteps.value = 0;
    apiProgressStatus.value = '';
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      AppRoute.fadeSlide(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }
}

class _ApiProgressStep {
  final String label;
  final Future<void> Function() task;

  const _ApiProgressStep({
    required this.label,
    required this.task,
  });
}
