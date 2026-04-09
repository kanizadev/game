import 'dart:math';

import '../models/enemy.dart';
import '../models/game_state.dart';

class RandomEventService {
  RandomEventService({Random? random}) : _random = random ?? Random();
  final Random _random;

  Enemy randomEnemy(int playerLevel, int riftLevel) {
    final common = [
      ('Hollow Rat', EnemyTier.common, 40, 10, 2, 30, 8, false, false, false),
      ('Lost Wanderer', EnemyTier.common, 56, 12, 4, 40, 11, false, false, false),
      ('Cursed Crow', EnemyTier.common, 45, 14, 3, 42, 12, false, false, false),
    ];
    final elite = [
      ('Grave Knight', EnemyTier.elite, 95, 20, 10, 95, 26, false, false, false),
      ('Soul Leech', EnemyTier.elite, 85, 18, 8, 90, 24, false, true, false),
      ('Mirror Shade', EnemyTier.elite, 90, 0, 0, 100, 28, false, false, true),
    ];
    final bosses = [
      ('The Forgotten King', EnemyTier.boss, 180, 24, 12, 180, 60, true, false, false),
      ('The Time Devourer', EnemyTier.boss, 220, 28, 14, 240, 90, false, false, false),
      ('The Keeper', EnemyTier.boss, 260, 30, 16, 320, 140, false, false, false),
    ];

    final List<(String, EnemyTier, int, int, int, int, int, bool, bool, bool)> pool;
    if (riftLevel >= 10 && _random.nextInt(100) < 35) {
      pool = bosses;
    } else if (riftLevel >= 4 && _random.nextInt(100) < 50) {
      pool = elite;
    } else {
      pool = common;
    }

    final t = pool[_random.nextInt(pool.length)];
    final effectiveLevel = playerLevel + (riftLevel - 1);
    final scale = 1 + ((effectiveLevel - 1) * 0.15);
    final scaledHp = (t.$3 * scale).round();
    final attack = t.$10 ? (10 + (playerLevel * 3)) : (t.$4 * scale).round();
    final defense = t.$10 ? (4 + (playerLevel * 2)) : (t.$5 * scale).round();
    return Enemy(
      id: t.$1.toLowerCase().replaceAll(' ', '_'),
      name: t.$1,
      tier: t.$2,
      maxHp: scaledHp,
      currentHp: scaledHp,
      attack: attack,
      defense: defense,
      xpReward: (t.$6 * scale).round(),
      goldReward: (t.$7 * scale).round(),
      weakToMagic: t.$8,
      drainsHp: t.$9,
      mirrorStats: t.$10,
    );
  }

  List<StoryChoice> nextChoices(int storyBeat) {
    if (storyBeat % 4 == 0) {
      return const [
        StoryChoice(id: 'knight_help', text: 'Help the wounded knight'),
        StoryChoice(id: 'knight_ignore', text: 'Ignore and move on'),
        StoryChoice(id: 'knight_finish', text: 'Finish him and take his blade'),
      ];
    }
    return const [
      StoryChoice(id: 'forward', text: 'Advance deeper into the Hollow Realm'),
      StoryChoice(id: 'rest', text: 'Meditate with The Keeper\'s echo'),
      StoryChoice(id: 'forage', text: 'Search ruins for supplies'),
    ];
  }

  bool shouldTriggerEncounter(int day, int riftLevel) {
    final chance = (42 + (day ~/ 2) + (riftLevel * 3)).clamp(42, 90);
    return _random.nextInt(100) < chance;
  }

  String flavorText(String choiceId) {
    switch (choiceId) {
      case 'rest':
        return 'You steady your soul, and faint memories surface.';
      case 'forage':
        return 'You find traces of a past life buried in ash.';
      case 'knight_help':
        return 'The knight swears to remember your face in every loop.';
      case 'knight_ignore':
        return 'You choose the safer road and avoid his curse.';
      case 'knight_finish':
        return 'His final breath binds a cursed relic to your fate.';
      default:
        return 'You move carefully through fractured time.';
    }
  }
}
