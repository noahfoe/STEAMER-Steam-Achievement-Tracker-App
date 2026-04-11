import 'package:steam_achievement_tracker/services/models/games/achievement.dart';
import 'package:steam_achievement_tracker/services/models/games/game.dart';
import 'package:steam_achievement_tracker/services/models/games/game_details.dart';
import 'package:steam_achievement_tracker/services/models/games/global_achievement_percentages.dart';
import 'package:steam_achievement_tracker/services/models/user/user_steam_information.dart';

// TEMPORARY CLOSED TESTING FEATURE:
// Remove this file and the DemoMode branches after the testing period ends.
class DemoMode {
  static const String steamId = 'steamer-demo-account';

  static bool isDemoSteamId(String steamId) => steamId == DemoMode.steamId;

  static const UserSteamInformation playerSummary = UserSteamInformation(
    steamID: steamId,
    steamName: 'STEAMER Test Pilot',
    avatar:
        'https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/620/header.jpg',
    realName: 'Closed Testing Profile',
  );

  static const int steamLevel = 42;

  static final List<Game> games = <Game>[
    _game(
      appId: 620,
      name: 'Portal 2',
      playtimeForever: 1340,
      playtime2Weeks: 95,
    ),
    _game(
      appId: 1145360,
      name: 'Hades',
      playtimeForever: 2860,
      playtime2Weeks: 40,
    ),
    _game(
      appId: 413150,
      name: 'Stardew Valley',
      playtimeForever: 4215,
      playtime2Weeks: 125,
    ),
    _game(
      appId: 440,
      name: 'Team Fortress 2',
      playtimeForever: 980,
      playtime2Weeks: 0,
    ),
    _game(
      appId: 1794680,
      name: 'Vampire Survivors',
      playtimeForever: 1530,
      playtime2Weeks: 72,
    ),
  ];

  static final Map<int, GameDetails> gameDetailsByAppId = <int, GameDetails>{
    620: _gameDetails(
      gameName: 'Portal 2',
      version: '1.0 Test Build',
      achievements: <Achievement>[
        _achievement(
          appId: 620,
          name: 'WAKE_UP_CALL',
          displayName: 'Wake Up Call',
          description: 'Complete the very first test chamber.',
          achieved: true,
        ),
        _achievement(
          appId: 620,
          name: 'TRUST_FALL',
          displayName: 'Trust Fall',
          description: 'Catch yourself with a portal after a long drop.',
          achieved: true,
        ),
        _achievement(
          appId: 620,
          name: 'PARTY_OF_TWO',
          displayName: 'Party of Two',
          description: 'Finish the co-op calibration sequence.',
          achieved: false,
        ),
        _achievement(
          appId: 620,
          name: 'ROBOT_RESCUE',
          displayName: 'Robot Rescue',
          description: 'Save your co-op partner from disaster.',
          achieved: false,
        ),
      ],
    ),
    1145360: _gameDetails(
      gameName: 'Hades',
      version: '1.0 Test Build',
      achievements: <Achievement>[
        _achievement(
          appId: 1145360,
          name: 'ESCAPE_ATTEMPT',
          displayName: 'First Escape Attempt',
          description: 'Fight your way out of the House of Hades once.',
          achieved: true,
        ),
        _achievement(
          appId: 1145360,
          name: 'KEEPSAKE_COLLECTOR',
          displayName: 'Keepsake Collector',
          description: 'Unlock several keepsakes from Olympian allies.',
          achieved: true,
        ),
        _achievement(
          appId: 1145360,
          name: 'BOON_SPECIALIST',
          displayName: 'Boon Specialist',
          description: 'Complete a run with a heavily upgraded build.',
          achieved: true,
        ),
        _achievement(
          appId: 1145360,
          name: 'UNDERWORLD_CHAMPION',
          displayName: 'Underworld Champion',
          description: 'Clear a difficult run with heat enabled.',
          achieved: false,
        ),
      ],
    ),
    413150: _gameDetails(
      gameName: 'Stardew Valley',
      version: '1.0 Test Build',
      achievements: <Achievement>[
        _achievement(
          appId: 413150,
          name: 'GREENHORN',
          displayName: 'Greenhorn',
          description: 'Earn your first farming milestone.',
          achieved: true,
        ),
        _achievement(
          appId: 413150,
          name: 'TREASURE_HUNTER',
          displayName: 'Treasure Hunter',
          description: 'Find a valuable treasure deep underground.',
          achieved: true,
        ),
        _achievement(
          appId: 413150,
          name: 'COMMUNITY_HELPER',
          displayName: 'Community Helper',
          description: 'Complete a full set of community bundles.',
          achieved: true,
        ),
      ],
    ),
    440: _gameDetails(
      gameName: 'Team Fortress 2',
      version: '1.0 Test Build',
      achievements: <Achievement>[
        _achievement(
          appId: 440,
          name: 'FIRST_BLOOD',
          displayName: 'First Blood',
          description: 'Score your first elimination.',
          achieved: true,
        ),
        _achievement(
          appId: 440,
          name: 'CONTROL_POINT_CAPTURE',
          displayName: 'Point Taken',
          description: 'Help capture a control point.',
          achieved: false,
        ),
        _achievement(
          appId: 440,
          name: 'MEDIC_SUPPORT',
          displayName: 'Battlefield Medic',
          description: 'Provide meaningful healing to your team.',
          achieved: false,
        ),
      ],
    ),
    1794680: _gameDetails(
      gameName: 'Vampire Survivors',
      version: '1.0 Test Build',
      achievements: <Achievement>[
        _achievement(
          appId: 1794680,
          name: 'NIGHT_ONE',
          displayName: 'Night One',
          description: 'Survive your first intense run.',
          achieved: true,
        ),
        _achievement(
          appId: 1794680,
          name: 'WEAPON_EVOLUTION',
          displayName: 'Weapon Evolution',
          description: 'Evolve a weapon during a run.',
          achieved: true,
        ),
        _achievement(
          appId: 1794680,
          name: 'COIN_MASTER',
          displayName: 'Coin Master',
          description: 'Build up a healthy stash of gold.',
          achieved: false,
        ),
        _achievement(
          appId: 1794680,
          name: 'ARCANA_COLLECTOR',
          displayName: 'Arcana Collector',
          description: 'Unlock one of the stronger arcana combinations.',
          achieved: false,
        ),
      ],
    ),
  };

  static GameDetails detailsForApp(int appId) =>
      gameDetailsByAppId[appId] ?? GameDetails.empty();

  static List<GameDetails> allGameDetails() => games
      .map((game) => detailsForApp(game.appId))
      .where((details) => details != GameDetails.empty())
      .toList(growable: false);

  static List<GlobalAchievementPercentages> percentagesForApp(int appId) {
    final details = detailsForApp(appId);
    return (details.allAchievements ?? const <Achievement>[])
        .map(
          (achievement) => GlobalAchievementPercentages(
            name: achievement.name,
            percent: _percentageLookup[appId]?[achievement.name] ?? 0,
          ),
        )
        .toList(growable: false);
  }

  static final Map<int, List<double>> _rawPercentages = <int, List<double>>{
    620: const <double>[88.4, 54.1, 28.7, 14.9],
    1145360: const <double>[92.0, 65.8, 49.3, 18.2],
    413150: const <double>[95.1, 47.6, 35.5],
    440: const <double>[84.8, 52.0, 31.4],
    1794680: const <double>[90.7, 58.2, 34.9, 22.1],
  };

  static final Map<int, Map<String, double>> _percentageLookup =
      <int, Map<String, double>>{
    for (final entry in gameDetailsByAppId.entries)
      entry.key: {
        for (int index = 0;
            index <
                (entry.value.allAchievements ?? const <Achievement>[]).length;
            index++)
          entry.value.allAchievements![index].name:
              _rawPercentages[entry.key]![index],
      },
  };

  static Game _game({
    required int appId,
    required String name,
    required int playtimeForever,
    required int playtime2Weeks,
  }) {
    final imageUrl =
        'https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/$appId/capsule_184x69.jpg';
    return Game(
      appId: appId,
      name: name,
      playtimeForever: playtimeForever,
      playtime2Weeks: playtime2Weeks,
      imgIconUrl: imageUrl,
      imgLogoUrl: imageUrl,
      hasCommunityVisibleStats: true,
    );
  }

  static GameDetails _gameDetails({
    required String gameName,
    required String version,
    required List<Achievement> achievements,
  }) {
    final unlocked = achievements
        .where((achievement) => achievement.achieved == 1)
        .toList(growable: false);
    final locked = achievements
        .where((achievement) => achievement.achieved == 0)
        .toList(growable: false);

    return GameDetails(
      gameName: gameName,
      gameVersion: version,
      allAchievements: achievements,
      unlockedAchievements: unlocked,
      lockedAchievements: locked,
    );
  }

  static Achievement _achievement({
    required int appId,
    required String name,
    required String displayName,
    required String description,
    required bool achieved,
  }) {
    final imageUrl =
        'https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/$appId/capsule_184x69.jpg';
    return Achievement(
      name: name,
      displayName: displayName,
      achieved: achieved ? 1 : 0,
      description: description,
      icon: imageUrl,
      iconGray: imageUrl,
      hidden: 0,
    );
  }
}
