import '../models/enemy.dart';
import '../models/status_effect.dart';
import 'battle_service.dart';
import 'enemy_ai_service.dart';
import 'status_effect_service.dart';

class CombatActionResult {
  const CombatActionResult({
    required this.enemy,
    required this.playerHp,
    required this.playerSoul,
    required this.playerBurst,
    required this.comboChain,
    required this.lastAction,
    required this.playerEffects,
    required this.enemyEffects,
    required this.logs,
    this.intent = EnemyIntent.attack,
  });

  final Enemy enemy;
  final int playerHp;
  final int playerSoul;
  final int playerBurst;
  final int comboChain;
  final String? lastAction;
  final List<StatusEffect> playerEffects;
  final List<StatusEffect> enemyEffects;
  final List<String> logs;
  final EnemyIntent intent;
}

class CombatEngine {
  CombatEngine({
    required BattleService battleService,
    required StatusEffectService statusEffectService,
    required EnemyAiService enemyAiService,
  })  : _battleService = battleService,
        _statusEffectService = statusEffectService,
        _enemyAiService = enemyAiService;

  final BattleService _battleService;
  final StatusEffectService _statusEffectService;
  final EnemyAiService _enemyAiService;

  CombatActionResult playerAttack({
    required Enemy enemy,
    required int attackerPower,
    required int playerLuck,
    required int playerHp,
    required int playerSoul,
    required int playerBurst,
    required int comboChain,
    required List<StatusEffect> playerEffects,
    required List<StatusEffect> enemyEffects,
  }) {
    final playerTick = _statusEffectService.tick(effects: playerEffects, ownerName: 'You');
    final enemyTick = _statusEffectService.tick(effects: enemyEffects, ownerName: enemy.name);
    final logs = <String>[...playerTick.logs, ...enemyTick.logs];

    final nextPlayerHp = playerHp + playerTick.hpDelta;
    final preHitEnemyHp = (enemy.currentHp + enemyTick.hpDelta).clamp(0, enemy.maxHp);
    final crit = _battleService.isCriticalHit(playerLuck);
    final comboBonus = comboChain * 2;
    var damage = _battleService.calculateDamage(
      attackerPower: attackerPower + comboBonus + _statusEffectService.attackModifier(playerTick.nextEffects),
      defenderPower: enemy.defense - _statusEffectService.defenseReduction(enemyTick.nextEffects),
    );
    if (crit) {
      damage = (damage * 1.6).round();
    }
    final remainingEnemyHp = (preHitEnemyHp - damage).clamp(0, enemy.maxHp);
    logs.add(
      crit
          ? '> CRITICAL! You strike ${enemy.name} for $damage damage.'
          : '> You strike ${enemy.name} for $damage damage.',
    );

    final nextEnemyEffects = [...enemyTick.nextEffects];
    if (comboChain >= 2) {
      nextEnemyEffects.add(
        const StatusEffect(
          id: 'combo_weaken',
          type: StatusEffectType.weaken,
          potency: 2,
          remainingTurns: 2,
          source: 'combo',
        ),
      );
      logs.add('> Combo pressure weakens ${enemy.name}.');
    }

    return CombatActionResult(
      enemy: enemy.copyWith(currentHp: remainingEnemyHp),
      playerHp: nextPlayerHp,
      playerSoul: playerSoul,
      playerBurst: (playerBurst + 20).clamp(0, 100),
      comboChain: comboChain + 1,
      lastAction: 'attack',
      playerEffects: playerTick.nextEffects,
      enemyEffects: nextEnemyEffects,
      logs: logs,
    );
  }

  CombatActionResult enemyTurn({
    required Enemy enemy,
    required int turnCounter,
    required int playerHp,
    required int playerMaxHp,
    required int playerDefense,
    required bool defending,
    required int playerSoul,
    required int playerBurst,
    required List<StatusEffect> playerEffects,
    required List<StatusEffect> enemyEffects,
  }) {
    final playerTick = _statusEffectService.tick(effects: playerEffects, ownerName: 'You');
    final enemyTick = _statusEffectService.tick(effects: enemyEffects, ownerName: enemy.name);
    final logs = <String>[...playerTick.logs, ...enemyTick.logs];

    final hpAfterTicks = (playerHp + playerTick.hpDelta).clamp(0, playerMaxHp);
    final enemyHpAfterTicks = (enemy.currentHp + enemyTick.hpDelta).clamp(0, enemy.maxHp);
    final intent = _enemyAiService.chooseIntent(
      enemy: enemy,
      turnCounter: turnCounter,
      playerHpRatio: hpAfterTicks / playerMaxHp,
    );

    var intentAttackBonus = 0;
    var intentDefending = false;
    switch (intent) {
      case EnemyIntent.guard:
        intentDefending = true;
        logs.add('> ${enemy.name} takes a guarded stance.');
      case EnemyIntent.siphon:
        intentAttackBonus = 4;
        logs.add('> ${enemy.name} prepares to siphon life.');
      case EnemyIntent.overclock:
        intentAttackBonus = 8;
        logs.add('> ${enemy.name} overclocks with unstable fury.');
      case EnemyIntent.attack:
        break;
    }

    final damage = _battleService.calculateDamage(
      attackerPower: enemy.attack + intentAttackBonus + _statusEffectService.attackModifier(enemyTick.nextEffects),
      defenderPower: playerDefense - _statusEffectService.defenseReduction(playerTick.nextEffects),
      defending: defending || intentDefending,
    );
    var nextHp = (hpAfterTicks - damage).clamp(0, playerMaxHp);
    var nextEnemyHp = enemyHpAfterTicks;

    if (intent == EnemyIntent.siphon || enemy.drainsHp) {
      nextEnemyHp = (nextEnemyHp + (damage ~/ 2)).clamp(0, enemy.maxHp);
      logs.add('> ${enemy.name} drains your life.');
    }
    logs.add('> ${enemy.name} hits you for $damage damage.');

    return CombatActionResult(
      enemy: enemy.copyWith(currentHp: nextEnemyHp),
      playerHp: nextHp,
      playerSoul: (playerSoul + 6).clamp(0, 999),
      playerBurst: playerBurst,
      comboChain: 0,
      lastAction: null,
      playerEffects: playerTick.nextEffects,
      enemyEffects: enemyTick.nextEffects,
      logs: logs,
      intent: intent,
    );
  }
}
