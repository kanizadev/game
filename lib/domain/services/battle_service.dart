import 'dart:math';

class BattleService {
  BattleService({Random? random}) : _random = random ?? Random();
  final Random _random;

  int calculateDamage({required int attackerPower, required int defenderPower, bool defending = false}) {
    final variance = _random.nextInt(5);
    var raw = attackerPower + variance - defenderPower;
    if (defending) raw = (raw * 0.6).round();
    return raw.clamp(1, 999);
  }

  bool tryRunAway() => _random.nextInt(100) < 45;
}
