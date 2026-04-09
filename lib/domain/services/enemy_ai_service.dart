import '../models/enemy.dart';

enum EnemyIntent { attack, guard, siphon, overclock }

class EnemyAiService {
  EnemyIntent chooseIntent({
    required Enemy enemy,
    required int turnCounter,
    required double playerHpRatio,
  }) {
    if (enemy.drainsHp && playerHpRatio > 0.35 && turnCounter.isOdd) {
      return EnemyIntent.siphon;
    }
    if (enemy.mirrorStats && turnCounter % 3 == 0) {
      return EnemyIntent.guard;
    }
    if (enemy.tier == EnemyTier.boss && turnCounter % 4 == 0) {
      return EnemyIntent.overclock;
    }
    return EnemyIntent.attack;
  }
}
