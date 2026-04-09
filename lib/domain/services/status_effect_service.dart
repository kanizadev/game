import '../models/status_effect.dart';

class StatusTickResult {
  const StatusTickResult({
    required this.hpDelta,
    required this.nextEffects,
    required this.logs,
  });

  final int hpDelta;
  final List<StatusEffect> nextEffects;
  final List<String> logs;
}

class StatusEffectService {
  StatusTickResult tick({
    required List<StatusEffect> effects,
    required String ownerName,
  }) {
    var hpDelta = 0;
    final logs = <String>[];
    final next = <StatusEffect>[];

    for (final effect in effects) {
      switch (effect.type) {
        case StatusEffectType.burn:
          hpDelta -= effect.potency;
          logs.add('> $ownerName suffers ${effect.potency} burn damage.');
        case StatusEffectType.regen:
          hpDelta += effect.potency;
          logs.add('> $ownerName recovers ${effect.potency} HP from regen.');
        case StatusEffectType.shield:
        case StatusEffectType.weaken:
          // Passive modifiers consumed by combat formulas.
          break;
      }

      final turnsLeft = effect.remainingTurns - 1;
      if (turnsLeft > 0) {
        next.add(effect.copyWith(remainingTurns: turnsLeft));
      } else {
        logs.add('> ${effect.id} fades from $ownerName.');
      }
    }

    return StatusTickResult(hpDelta: hpDelta, nextEffects: next, logs: logs);
  }

  int attackModifier(List<StatusEffect> effects) {
    var modifier = 0;
    for (final effect in effects) {
      if (effect.type == StatusEffectType.weaken) modifier -= effect.potency;
    }
    return modifier;
  }

  int defenseReduction(List<StatusEffect> effects) {
    var reduction = 0;
    for (final effect in effects) {
      if (effect.type == StatusEffectType.shield) reduction += effect.potency;
    }
    return reduction;
  }
}
