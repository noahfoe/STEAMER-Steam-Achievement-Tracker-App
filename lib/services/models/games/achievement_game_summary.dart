import 'dart:convert';

import 'package:equatable/equatable.dart';

class AchievementGameSummary extends Equatable {
  final int appId;
  final String gameName;
  final String imageUrl;
  final int totalAchievements;
  final int unlockedAchievements;
  final int lockedAchievements;

  const AchievementGameSummary({
    required this.appId,
    required this.gameName,
    required this.imageUrl,
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.lockedAchievements,
  });

  bool get isPerfected => totalAchievements > 0 && lockedAchievements == 0;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appId': appId,
      'gameName': gameName,
      'imageUrl': imageUrl,
      'totalAchievements': totalAchievements,
      'unlockedAchievements': unlockedAchievements,
      'lockedAchievements': lockedAchievements,
    };
  }

  factory AchievementGameSummary.fromMap(Map<String, dynamic> map) {
    return AchievementGameSummary(
      appId: map['appId'] as int? ?? 0,
      gameName: map['gameName'] as String? ?? 'Unknown Game',
      imageUrl: map['imageUrl'] as String? ?? '',
      totalAchievements: map['totalAchievements'] as int? ?? 0,
      unlockedAchievements: map['unlockedAchievements'] as int? ?? 0,
      lockedAchievements: map['lockedAchievements'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory AchievementGameSummary.fromJson(String source) =>
      AchievementGameSummary.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object> get props => [
        appId,
        gameName,
        imageUrl,
        totalAchievements,
        unlockedAchievements,
        lockedAchievements,
      ];
}
