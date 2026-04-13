import 'dart:convert';

import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final int totalGames;
  final int totalHoursPlayed;
  final int totalAchievements;
  final int unlockedAchievements;
  final int lockedAchievements;
  final int perfectedGames;
  final int gamesWithAchievements;

  const DashboardSummary({
    required this.totalGames,
    required this.totalHoursPlayed,
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.lockedAchievements,
    required this.perfectedGames,
    required this.gamesWithAchievements,
  });

  factory DashboardSummary.empty() {
    return const DashboardSummary(
      totalGames: 0,
      totalHoursPlayed: 0,
      totalAchievements: 0,
      unlockedAchievements: 0,
      lockedAchievements: 0,
      perfectedGames: 0,
      gamesWithAchievements: 0,
    );
  }

  bool get isEmpty => this == DashboardSummary.empty();

  DashboardSummary copyWith({
    int? totalGames,
    int? totalHoursPlayed,
    int? totalAchievements,
    int? unlockedAchievements,
    int? lockedAchievements,
    int? perfectedGames,
    int? gamesWithAchievements,
  }) {
    return DashboardSummary(
      totalGames: totalGames ?? this.totalGames,
      totalHoursPlayed: totalHoursPlayed ?? this.totalHoursPlayed,
      totalAchievements: totalAchievements ?? this.totalAchievements,
      unlockedAchievements:
          unlockedAchievements ?? this.unlockedAchievements,
      lockedAchievements: lockedAchievements ?? this.lockedAchievements,
      perfectedGames: perfectedGames ?? this.perfectedGames,
      gamesWithAchievements: gamesWithAchievements ?? this.gamesWithAchievements,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalGames': totalGames,
      'totalHoursPlayed': totalHoursPlayed,
      'totalAchievements': totalAchievements,
      'unlockedAchievements': unlockedAchievements,
      'lockedAchievements': lockedAchievements,
      'perfectedGames': perfectedGames,
      'gamesWithAchievements': gamesWithAchievements,
    };
  }

  factory DashboardSummary.fromMap(Map<String, dynamic> map) {
    return DashboardSummary(
      totalGames: map['totalGames'] as int? ?? 0,
      totalHoursPlayed: map['totalHoursPlayed'] as int? ?? 0,
      totalAchievements: map['totalAchievements'] as int? ?? 0,
      unlockedAchievements: map['unlockedAchievements'] as int? ?? 0,
      lockedAchievements: map['lockedAchievements'] as int? ?? 0,
      perfectedGames: map['perfectedGames'] as int? ?? 0,
      gamesWithAchievements: map['gamesWithAchievements'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DashboardSummary.fromJson(String source) =>
      DashboardSummary.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object> get props => [
        totalGames,
        totalHoursPlayed,
        totalAchievements,
        unlockedAchievements,
        lockedAchievements,
        perfectedGames,
        gamesWithAchievements,
      ];
}
