import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/save_service.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/item.dart';
import '../../domain/services/battle_service.dart';
import '../../domain/services/level_service.dart';
import '../../domain/services/random_event_service.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) => GameNotifier());

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier()
      : _saveService = SaveService(),
        _randomEventService = RandomEventService(),
        _battleService = BattleService(),
        super(GameState.initial());

  final SaveService _saveService;
  final RandomEventService _randomEventService;
  final BattleService _battleService;

  Future<void> startNewGame() async {
    state = GameState.initial();
    _appendLog('> New session started. Entering the rift...');
    await saveGame();
  }

  Future<bool> loadGame() async {
    final loaded = await _saveService.load();
    if (loaded == null) return false;
    state = loaded;
    _appendLog('> Save loaded. Systems synchronized.');
    return true;
  }

  Future<void> saveGame() => _saveService.save(state);
  Future<void> clearSave() => _saveService.clear();
  void toggleSound(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
    _autoSave();
  }

  void advanceTurnDay() {
    if (state.phase != GamePhase.exploring) return;
    final nextDay = state.day + 1;
    _appendLog('> You advance cautiously to day $nextDay.');

    if (_randomEventService.shouldTriggerEncounter(nextDay, state.riftLevel)) {
      final enemy = _randomEventService.randomEnemy(state.player.level, state.riftLevel);
      state = state.copyWith(day: nextDay, phase: GamePhase.battle, enemy: enemy, isPlayerTurn: true, storyBeat: state.storyBeat + 1);
      _appendLog('> Day $nextDay encounter! ${enemy.name} appears.');
      _playBeep();
      _autoSave();
      return;
    }

    state = state.copyWith(day: nextDay, choices: _randomEventService.nextChoices(state.storyBeat + 1), storyBeat: state.storyBeat + 1);
    _autoSave();
  }

  void chooseStoryOption(String choiceId) {
    _appendLog('> ${_randomEventService.flavorText(choiceId)}');

    if (choiceId == 'rest') {
      final healed = (state.player.currentHp + 12).clamp(0, state.player.maxHp);
      final soul = (state.player.currentSoul + 10).clamp(0, state.player.maxSoul);
      state = state.copyWith(
        player: state.player.copyWith(currentHp: healed, currentSoul: soul),
      );
      _appendLog('> You regain 12 HP and 10 SOUL.');
      return;
    }

    if (choiceId == 'forage') {
      const potion = Item(
        id: 'minor_potion',
        name: 'Minor Potion',
        type: ItemType.consumable,
        value: 20,
        description: 'Restores 20 HP.',
      );
      state = state.copyWith(inventory: [...state.inventory, potion]);
      _appendLog('> You found a Minor Potion.');
      _autoSave();
      return;
    }

    if (choiceId == 'knight_help') {
      final player = state.player.copyWith(luck: state.player.luck + 1);
      state = state.copyWith(player: player);
      _appendLog('> The knight grants you an Echo Sigil. +1 LUCK.');
      _autoSave();
      return;
    }

    if (choiceId == 'knight_ignore') {
      const crystal = Item(
        id: 'loop_crystal',
        name: 'Loop Crystal',
        type: ItemType.relic,
        value: 0,
        description: 'Keeps relics between death loops.',
      );
      if (state.inventory.every((item) => item.id != crystal.id)) {
        state = state.copyWith(inventory: [...state.inventory, crystal]);
        _appendLog('> You find a Loop Crystal on the safer path.');
      }
      _autoSave();
      return;
    }

    if (choiceId == 'knight_finish') {
      const ring = Item(
        id: 'cursed_ring',
        name: 'Cursed Ring',
        type: ItemType.relic,
        value: 6,
        description: 'High power, but drains HP each battle turn.',
      );
      state = state.copyWith(inventory: [...state.inventory, ring]);
      _appendLog('> You take the Cursed Ring. Power answers, but at a cost.');
      return;
    }

    if (_randomEventService.shouldTriggerEncounter(state.day, state.riftLevel)) {
      final enemy = _randomEventService.randomEnemy(state.player.level, state.riftLevel);
      state = state.copyWith(phase: GamePhase.battle, enemy: enemy, isPlayerTurn: true, storyBeat: state.storyBeat + 1);
      _appendLog('> Encounter! ${enemy.name} emerges from the dark.');
      _playBeep();
      _autoSave();
      return;
    }

    state = state.copyWith(choices: _randomEventService.nextChoices(state.storyBeat + 1), storyBeat: state.storyBeat + 1);
    _autoSave();
  }

  void playerAttack() {
    final enemy = state.enemy;
    if (enemy == null || !state.isPlayerTurn || state.phase != GamePhase.battle) return;

    final weaponBonus = state.inventory.where((item) => item.type == ItemType.weapon).fold<int>(0, (sum, item) => sum + item.value);
    final crit = _battleService.isCriticalHit(state.player.luck);
    var damage = _battleService.calculateDamage(attackerPower: state.player.baseAttack + weaponBonus, defenderPower: enemy.defense);
    if (crit) damage = (damage * 1.6).round();

    final remainingEnemyHp = (enemy.currentHp - damage).clamp(0, enemy.maxHp);
    final burstCharge = (state.player.soulBurstCharge + 20).clamp(0, 100);
    state = state.copyWith(
      enemy: enemy.copyWith(currentHp: remainingEnemyHp),
      player: state.player.copyWith(soulBurstCharge: burstCharge),
    );
    _appendLog(
      crit
          ? '> CRITICAL! You strike ${enemy.name} for $damage damage.'
          : '> You strike ${enemy.name} for $damage damage.',
    );

    if (remainingEnemyHp <= 0) {
      _resolveVictory();
      return;
    }

    state = state.copyWith(isPlayerTurn: false);
    enemyTurn();
  }

  void playerDefend() {
    if (state.enemy == null || !state.isPlayerTurn || state.phase != GamePhase.battle) return;
    _appendLog('> You brace for impact.');
    state = state.copyWith(
      isPlayerTurn: false,
      player: state.player.copyWith(
        soulBurstCharge: (state.player.soulBurstCharge + 12).clamp(0, 100),
      ),
    );
    enemyTurn(playerDefending: true);
  }

  void playerRun() {
    if (state.enemy == null || !state.isPlayerTurn || state.phase != GamePhase.battle) return;
    if (_battleService.tryRunAway()) {
      _appendLog('> You escape the encounter.');
      state = state.copyWith(phase: GamePhase.exploring, clearEnemy: true, isPlayerTurn: true);
      _autoSave();
      return;
    }
    _appendLog('> Escape failed. The enemy blocks your path!');
    state = state.copyWith(isPlayerTurn: false);
    enemyTurn();
  }

  void usePotionInBattle() {
    if (state.phase != GamePhase.battle || !state.isPlayerTurn) return;
    _consumePotion();
  }

  void castSkill() {
    final enemy = state.enemy;
    if (enemy == null || !state.isPlayerTurn || state.phase != GamePhase.battle) return;
    if (state.player.currentSoul < 12) {
      _appendLog('> Not enough SOUL to cast.');
      return;
    }

    final magicAttack = state.player.baseAttack + 8 + (state.player.level * 2);
    var damage = _battleService.calculateDamage(
      attackerPower: magicAttack,
      defenderPower: (enemy.defense * 0.7).round(),
    );
    if (enemy.weakToMagic) damage = (damage * 1.4).round();

    final remainingEnemyHp = (enemy.currentHp - damage).clamp(0, enemy.maxHp);
    final nextSoul = (state.player.currentSoul - 12).clamp(0, state.player.maxSoul);
    final burstCharge = (state.player.soulBurstCharge + 25).clamp(0, 100);
    state = state.copyWith(
      enemy: enemy.copyWith(currentHp: remainingEnemyHp),
      player: state.player.copyWith(currentSoul: nextSoul, soulBurstCharge: burstCharge),
    );
    _appendLog('> Soul Fire hits ${enemy.name} for $damage magic damage.');

    if (remainingEnemyHp <= 0) {
      _resolveVictory();
      return;
    }
    state = state.copyWith(isPlayerTurn: false);
    enemyTurn();
  }

  void useSoulBurst() {
    final enemy = state.enemy;
    if (enemy == null || !state.isPlayerTurn || state.phase != GamePhase.battle) return;
    if (state.player.soulBurstCharge < 100) {
      _appendLog('> Soul Burst is not fully charged.');
      return;
    }

    if (state.player.currentHp <= state.player.maxHp ~/ 2) {
      final healed = (state.player.currentHp + 40).clamp(0, state.player.maxHp);
      state = state.copyWith(
        player: state.player.copyWith(currentHp: healed, soulBurstCharge: 0),
      );
      _appendLog('> Soul Burst surges inward. You recover 40 HP.');
      state = state.copyWith(isPlayerTurn: false);
      enemyTurn();
      return;
    }

    final damage = _battleService.calculateDamage(
      attackerPower: state.player.baseAttack + 40,
      defenderPower: (enemy.defense * 0.5).round(),
    );
    final remainingEnemyHp = (enemy.currentHp - damage).clamp(0, enemy.maxHp);
    state = state.copyWith(
      enemy: enemy.copyWith(currentHp: remainingEnemyHp),
      player: state.player.copyWith(soulBurstCharge: 0),
    );
    _appendLog('> Soul Burst tears through ${enemy.name} for $damage damage.');

    if (remainingEnemyHp <= 0) {
      _resolveVictory();
      return;
    }
    state = state.copyWith(isPlayerTurn: false);
    enemyTurn();
  }

  void usePotionOutsideBattle() => _consumePotion();

  void enemyTurn({bool playerDefending = false}) {
    final enemy = state.enemy;
    if (enemy == null || state.phase != GamePhase.battle) return;

    var damage = _battleService.calculateDamage(attackerPower: enemy.attack, defenderPower: state.player.baseDefense, defending: playerDefending);
    if (enemy.id == 'time_devourer' && DateTime.now().millisecond % 2 == 0) {
      damage = (damage * 1.35).round();
      _appendLog('> Time fractures. The attack pattern resets unexpectedly!');
    }
    var hp = (state.player.currentHp - damage).clamp(0, state.player.maxHp);
    if (enemy.drainsHp) {
      final healedEnemy = (enemy.currentHp + (damage ~/ 2)).clamp(0, enemy.maxHp);
      state = state.copyWith(enemy: enemy.copyWith(currentHp: healedEnemy));
      _appendLog('> ${enemy.name} drains your life.');
    }
    if (state.inventory.any((i) => i.id == 'cursed_ring')) {
      hp = (hp - 2).clamp(0, state.player.maxHp);
      _appendLog('> The Cursed Ring drains 2 HP.');
    }

    final nextSoul = (state.player.currentSoul + 6).clamp(0, state.player.maxSoul);
    state = state.copyWith(player: state.player.copyWith(currentHp: hp, currentSoul: nextSoul));
    _appendLog('> ${enemy.name} hits you for $damage damage.');

    if (hp <= 0) {
      _applyDeathLoop();
      _playBeep();
      _autoSave();
      return;
    }

    state = state.copyWith(isPlayerTurn: true);
  }

  void _resolveVictory() {
    final enemy = state.enemy;
    if (enemy == null) return;

    var player = state.player.copyWith(gold: state.player.gold + enemy.goldReward);
    player = LevelService.applyXp(player, enemy.xpReward);
    final leveledUp = player.level > state.player.level;

    final nextRiftLevel = state.riftLevel + 1;
    state = state.copyWith(
      player: player,
      phase: GamePhase.exploring,
      clearEnemy: true,
      isPlayerTurn: true,
      riftLevel: nextRiftLevel,
      day: state.day + 1,
      choices: _randomEventService.nextChoices(state.storyBeat + 1),
      storyBeat: state.storyBeat + 1,
    );

    _appendLog('> ${enemy.name} defeated. +${enemy.xpReward} XP, +${enemy.goldReward} gold.');
    _appendLog('> You advance to Rift Level $nextRiftLevel.');
    if (leveledUp) {
      _appendLog('> Level up! You are now level ${player.level}.');
      _playBeep();
    }
    _autoSave();
  }

  void _consumePotion() {
    final potionIndex = state.inventory.indexWhere((item) => item.type == ItemType.consumable);
    if (potionIndex < 0) {
      _appendLog('> No consumable available.');
      return;
    }

    final potion = state.inventory[potionIndex];
    final healed = (state.player.currentHp + potion.value).clamp(0, state.player.maxHp);
    final nextInventory = [...state.inventory]..removeAt(potionIndex);
    state = state.copyWith(player: state.player.copyWith(currentHp: healed), inventory: nextInventory);
    _appendLog('> You use ${potion.name} and recover ${potion.value} HP.');
    _autoSave();
  }

  void _applyDeathLoop() {
    final nextLoop = state.loopCount + 1;
    final keepsLoopCrystal = state.inventory.any((item) => item.id == 'loop_crystal');
    final persistentItems = keepsLoopCrystal
        ? state.inventory.where((i) => i.type == ItemType.relic).toList()
        : <Item>[];
    final reset = GameState.initial();
    state = reset.copyWith(
      loopCount: nextLoop,
      riftLevel: (1 + (nextLoop ~/ 2)).clamp(1, 99),
      storyBeat: state.storyBeat + 1,
      inventory: [...reset.inventory, ...persistentItems],
      log: [
        ...state.log,
        '> You fall... then wake again.',
        '> Loop #$nextLoop begins. NPCs whisper fragments of your past life.',
      ],
    );
  }

  void _appendLog(String message) {
    final lines = [...state.log, message];
    state = state.copyWith(log: lines.length > 200 ? lines.sublist(lines.length - 200) : lines);
  }

  void _playBeep() {
    if (state.soundEnabled) SystemSound.play(SystemSoundType.click);
  }

  void _autoSave() {
    unawaited(_saveService.save(state));
  }
}
