import '../models/player.dart';
import '../models/player_class.dart';

class LevelService {
  static int xpForNextLevel(int level) => level * 70;

  static Player applyXp(Player player, int gainedXp) {
    var updated = player.copyWith(xp: player.xp + gainedXp);
    while (updated.xp >= xpForNextLevel(updated.level)) {
      final nextLevel = updated.level + 1;
      updated = updated.copyWith(
        level: nextLevel,
        maxHp: updated.maxHp + _hpPerLevel(updated.classPath),
        currentHp: updated.maxHp + _hpPerLevel(updated.classPath),
        maxSoul: updated.maxSoul + _soulPerLevel(updated.classPath),
        currentSoul: updated.maxSoul + _soulPerLevel(updated.classPath),
        baseAttack: updated.baseAttack + _attackPerLevel(updated.classPath),
        baseDefense: updated.baseDefense + _defensePerLevel(updated.classPath),
        luck: updated.luck + _luckPerLevel(updated.classPath),
        skillPoints: updated.skillPoints + 1,
      );
    }
    return updated;
  }

  static int _hpPerLevel(PlayerClass classPath) => switch (classPath) {
        PlayerClass.vanguard => 18,
        PlayerClass.arcanist => 12,
        PlayerClass.shade => 14,
      };

  static int _soulPerLevel(PlayerClass classPath) => switch (classPath) {
        PlayerClass.vanguard => 4,
        PlayerClass.arcanist => 8,
        PlayerClass.shade => 6,
      };

  static int _attackPerLevel(PlayerClass classPath) => switch (classPath) {
        PlayerClass.vanguard => 3,
        PlayerClass.arcanist => 2,
        PlayerClass.shade => 3,
      };

  static int _defensePerLevel(PlayerClass classPath) => switch (classPath) {
        PlayerClass.vanguard => 3,
        PlayerClass.arcanist => 1,
        PlayerClass.shade => 2,
      };

  static int _luckPerLevel(PlayerClass classPath) => switch (classPath) {
        PlayerClass.vanguard => 1,
        PlayerClass.arcanist => 1,
        PlayerClass.shade => 2,
      };
}
