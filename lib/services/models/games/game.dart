// ignore_for_file: public_member_api_docs, sort_constructors_first, depend_on_referenced_packages
import 'dart:convert';

import 'package:equatable/equatable.dart';

class Game extends Equatable {
  final int appId;
  final String name;
  final int? playtimeForever;
  final int? playtime2Weeks;
  final String? imgIconUrl;
  final String? imgLogoUrl;
  final bool? hasCommunityVisibleStats;
  const Game({
    required this.appId,
    required this.name,
    required this.playtimeForever,
    required this.playtime2Weeks,
    required this.imgIconUrl,
    required this.imgLogoUrl,
    required this.hasCommunityVisibleStats,
  });

  Game copyWith({
    int? appId,
    String? name,
    int? playtimeForever,
    int? playtime2Weeks,
    String? imgIconUrl,
    String? imgLogoUrl,
    bool? hasCommunityVisibleStats,
  }) {
    return Game(
      appId: appId ?? this.appId,
      name: name ?? this.name,
      playtimeForever: playtimeForever ?? this.playtimeForever,
      playtime2Weeks: playtime2Weeks ?? this.playtime2Weeks,
      imgIconUrl: imgIconUrl ?? this.imgIconUrl,
      imgLogoUrl: imgLogoUrl ?? this.imgLogoUrl,
      hasCommunityVisibleStats:
          hasCommunityVisibleStats ?? this.hasCommunityVisibleStats,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appId': appId,
      'name': name,
      'playtimeForever': playtimeForever,
      'playtime2Weeks': playtime2Weeks,
      'imgIconUrl': imgIconUrl,
      'imgLogoUrl': imgLogoUrl,
      'hasCommunityVisibleStats': hasCommunityVisibleStats,
    };
  }

  factory Game.empty() {
    return const Game(
      appId: 0,
      name: '',
      playtimeForever: 0,
      playtime2Weeks: 0,
      imgIconUrl: '',
      imgLogoUrl: '',
      hasCommunityVisibleStats: false,
    );
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    final appId = map['appid'] as int;
    final rawIconUrl = (map['img_icon_url'] as String?) ??
        (map['icon'] as String?) ??
        (map['logo'] as String?) ??
        '';
    final rawLogoUrl = (map['img_logo_url'] as String?) ??
        (map['logo'] as String?) ??
        rawIconUrl;

    return Game(
      appId: appId,
      name: map['name'] as String,
      playtimeForever:
          map['playtime_forever'] != null ? map['playtime_forever'] as int : 0,
      playtime2Weeks:
          map['playtime_2weeks'] != null ? map['playtime_2weeks'] as int : 0,
      imgIconUrl: _resolveSteamImageUrl(
        appId: appId,
        rawValue: rawIconUrl,
        fallbackValue: rawLogoUrl,
      ),
      imgLogoUrl: _resolveSteamImageUrl(
        appId: appId,
        rawValue: rawLogoUrl,
        fallbackValue: rawIconUrl,
      ),
      hasCommunityVisibleStats: map['has_community_visible_stats'] ?? false,
    );
  }

  factory Game.fromSharedPrefs(Map<String, dynamic> map) {
    return Game(
      appId: map['appId'] as int,
      name: map['name'] as String,
      playtimeForever:
          map['playtimeForever'] != null ? map['playtimeForever'] as int : 0,
      playtime2Weeks:
          map['playtime2Weeks'] != null ? map['playtime2Weeks'] as int : 0,
      imgIconUrl: map['imgIconUrl'] as String,
      imgLogoUrl: map['imgLogoUrl'] as String,
      hasCommunityVisibleStats: map['hasCommunityVisibleStats'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Game.fromJson(String source) {
    return Game.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      appId,
      name,
      playtimeForever ?? 0,
      playtime2Weeks ?? 0,
      imgIconUrl ?? '',
      imgLogoUrl ?? '',
      hasCommunityVisibleStats ?? false,
    ];
  }

  static String _resolveSteamImageUrl({
    required int appId,
    required String rawValue,
    String fallbackValue = '',
  }) {
    if (_isAbsoluteUrl(rawValue)) {
      return rawValue;
    }

    if (rawValue.isNotEmpty) {
      return 'https://media.steampowered.com/steamcommunity/public/images/apps/$appId/$rawValue.jpg';
    }

    if (_isAbsoluteUrl(fallbackValue)) {
      return fallbackValue;
    }

    if (fallbackValue.isNotEmpty) {
      return 'https://media.steampowered.com/steamcommunity/public/images/apps/$appId/$fallbackValue.jpg';
    }

    return '';
  }

  static bool _isAbsoluteUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }
}
