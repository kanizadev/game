import '../models/player.dart';

class LevelService {
  static int xpForNextLevel(int level) => level * 70;

  static Player applyXp(Player player, int gainedXp) {
    var updated = player.copyWith(xp: player.xp + gainedXp);
    while (updated.xp >= xpForNextLevel(updated.level)) {
      final nextLevel = updated.level + 1;
      updated = updated.copyWith(level: nextLevel, maxHp: updated.maxHp + 15, currentHp: updated.maxHp + 15, baseAttack: updated.baseAttack + 3, baseDefense: updated.baseDefense + 2);
    }
    return updated;
  }
}
