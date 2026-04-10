// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/utils/database.dart';

class GamesScreenController extends GetxController with StateMixin<void> {
  final String steamID;

  List<Game> playerGamesList = List<Game>.empty().obs;
  Rx<List<Game>> filteredGamesList = RxList<Game>.empty().obs;

  final Database _database = Database.instance;
  final TextEditingController searchController = TextEditingController();

  GamesScreenController({
    required this.steamID,
    required this.playerGamesList,
  }) {
    init();
  }

  searchGamesList(String value) {
    if (value.isEmpty) {
      filteredGamesList.value = playerGamesList;
      return;
    }
    filteredGamesList.value = playerGamesList
        .where((Game element) =>
            element.name.toLowerCase().contains(value.toLowerCase()))
        .toList()
        .obs;
  }

  init() async {
    change(null, status: RxStatus.loading());
    try {
      if (playerGamesList.isEmpty) {
        playerGamesList = await _database.getPlayerGamesList(steamID: steamID);
      }
      filteredGamesList.value = playerGamesList;
      if (playerGamesList.isEmpty) {
        change(null, status: RxStatus.empty());
        return;
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
      return;
    }
    change(null, status: RxStatus.success());
  }

  Future<void> retry() async {
    await init();
  }
}
