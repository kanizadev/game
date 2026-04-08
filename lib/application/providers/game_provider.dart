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
      final healed = (state.player.currentHp + 10).clamp(0, state.player.maxHp);
      state = state.copyWith(player: state.player.copyWith(currentHp: healed));
      _appendLog('> You regain 10 HP.');
      return;
    }

    if (choiceId == 'merchant') {
      const potion = Item(id: 'small_potion', name: 'Small Potion', type: ItemType.potion, value: 25, description: 'Restores 25 HP.');
      state = state.copyWith(inventory: [...state.inventory, potion]);
      _appendLog('> The merchant leaves you a potion.');
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
    final damage = _battleService.calculateDamage(attackerPower: state.player.baseAttack + weaponBonus, defenderPower: enemy.defense);

    final remainingEnemyHp = (enemy.currentHp - damage).clamp(0, enemy.maxHp);
    state = state.copyWith(enemy: enemy.copyWith(currentHp: remainingEnemyHp));
    _appendLog('> You strike ${enemy.name} for $damage damage.');

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
    state = state.copyWith(isPlayerTurn: false);
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

  void usePotionOutsideBattle() => _consumePotion();

  void enemyTurn({bool playerDefending = false}) {
    final enemy = state.enemy;
    if (enemy == null || state.phase != GamePhase.battle) return;

    final damage = _battleService.calculateDamage(attackerPower: enemy.attack, defenderPower: state.player.baseDefense, defending: playerDefending);
    final hp = (state.player.currentHp - damage).clamp(0, state.player.maxHp);
    state = state.copyWith(player: state.player.copyWith(currentHp: hp));
    _appendLog('> ${enemy.name} hits you for $damage damage.');

    if (hp <= 0) {
      state = state.copyWith(phase: GamePhase.gameOver);
      _appendLog('> Signal lost. You were defeated in the rift.');
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
    final potionIndex = state.inventory.indexWhere((item) => item.type == ItemType.potion);
    if (potionIndex < 0) {
      _appendLog('> No potion available.');
      return;
    }

    final potion = state.inventory[potionIndex];
    final healed = (state.player.currentHp + potion.value).clamp(0, state.player.maxHp);
    final nextInventory = [...state.inventory]..removeAt(potionIndex);
    state = state.copyWith(player: state.player.copyWith(currentHp: healed), inventory: nextInventory);
    _appendLog('> You use ${potion.name} and recover ${potion.value} HP.');
    _autoSave();
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
