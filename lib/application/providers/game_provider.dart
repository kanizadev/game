import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/save_service.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/item.dart';
import '../../domain/models/player.dart';
import '../../domain/models/player_class.dart';
import '../../domain/models/status_effect.dart';
import '../../domain/services/battle_service.dart';
import '../../domain/services/combat_engine.dart';
import '../../domain/services/enemy_ai_service.dart';
import '../../domain/services/level_service.dart';
import '../../domain/services/random_event_service.dart';
import '../../domain/services/sound_service.dart';
import '../../domain/services/status_effect_service.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(),
);

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier()
    : _saveService = SaveService(),
      _randomEventService = RandomEventService(),
      _battleService = BattleService(),
      _combatEngine = CombatEngine(
        battleService: BattleService(),
        statusEffectService: StatusEffectService(),
        enemyAiService: EnemyAiService(),
      ),
      _soundService = SoundService(),
      super(GameState.initial()) {
    unawaited(_soundService.setEnabled(state.soundEnabled));
  }

  final SaveService _saveService;
  final RandomEventService _randomEventService;
  final BattleService _battleService;
  final CombatEngine _combatEngine;
  final SoundService _soundService;

  Future<void> startNewGame() async {
    state = GameState.initial();
    _appendLog('> New session started. Entering the rift...');
    unawaited(_soundService.playBgm(BgmType.exploration));
    await saveGame();
  }

  Future<bool> loadGame() async {
    final loaded = await _saveService.load();
    if (loaded == null) return false;
    state = loaded;
    unawaited(_soundService.setEnabled(state.soundEnabled));
    if (state.soundEnabled) {
      _syncBgmToState();
    }
    _appendLog('> Save loaded. Systems synchronized.');
    return true;
  }

  Future<void> saveGame() => _saveService.save(state);
  Future<void> clearSave() => _saveService.clear();
  void toggleSound(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
    unawaited(_soundService.setEnabled(enabled));
    if (enabled) {
      _syncBgmToState();
    } else {
      unawaited(_soundService.stopBgm());
    }
    _autoSave();
  }

  void playUiClick() {
    unawaited(_soundService.playSfx(SfxType.uiClick));
  }

  void playMenuOpen() {
    unawaited(_soundService.playSfx(SfxType.menuOpen));
  }

  void advanceTurnDay() {
    if (state.phase != GamePhase.exploring) return;
    final nextDay = state.day + 1;
    _appendLog('> You advance cautiously to day $nextDay.');

    if (_randomEventService.shouldTriggerEncounter(nextDay, state.riftLevel)) {
      final enemy = _randomEventService.randomEnemy(
        state.player.level,
        state.riftLevel,
      );
      state = state.copyWith(
        day: nextDay,
        phase: GamePhase.battle,
        enemy: enemy,
        isPlayerTurn: true,
        storyBeat: state.storyBeat + 1,
      );
      _appendLog('> Day $nextDay encounter! ${enemy.name} appears.');
      _appendEncounterForecast(enemy.name);
      _playEncounterSound(enemy.name);
      _syncBgmToState();
      _autoSave();
      return;
    }

    state = state.copyWith(
      day: nextDay,
      choices: _randomEventService.nextChoices(
        state.storyBeat + 1,
        memoryFlags: state.memoryFlags,
        keeperAlignment: state.keeperAlignment,
      ),
      storyBeat: state.storyBeat + 1,
    );
    _autoSave();
  }

  void chooseStoryOption(String choiceId) {
    _appendLog('> ${_randomEventService.flavorText(choiceId)}');

    if (choiceId == 'rest') {
      final healed = (state.player.currentHp + 12).clamp(0, state.player.maxHp);
      final soul = (state.player.currentSoul + 10).clamp(
        0,
        state.player.maxSoul,
      );
      state = state.copyWith(
        player: state.player.copyWith(currentHp: healed, currentSoul: soul),
      );
      _appendLog('> You regain 12 HP and 10 SOUL.');
      advanceTurnDay();
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
      advanceTurnDay();
      return;
    }

    if (choiceId == 'knight_help') {
      final player = state.player.copyWith(luck: state.player.luck + 1);
      state = state.copyWith(
        player: player,
        keeperAlignment: state.keeperAlignment + 1,
      );
      _appendLog('> The knight grants you an Echo Sigil. +1 LUCK.');
      advanceTurnDay();
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
      state = state.copyWith(
        memoryFlags: {...state.memoryFlags, 'keeper_mark'}.toList(),
        keeperAlignment: state.keeperAlignment - 1,
      );
      advanceTurnDay();
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
      state = state.copyWith(
        inventory: [...state.inventory, ring],
        keeperAlignment: state.keeperAlignment - 2,
      );
      _appendLog('> You take the Cursed Ring. Power answers, but at a cost.');
      advanceTurnDay();
      return;
    }

    if (choiceId == 'keeper_bargain') {
      final player = state.player.copyWith(
        baseAttack: state.player.baseAttack + 2,
        maxSoul: state.player.maxSoul + 4,
        currentSoul: (state.player.currentSoul + 8).clamp(
          0,
          state.player.maxSoul + 4,
        ),
      );
      state = state.copyWith(
        player: player,
        keeperAlignment: state.keeperAlignment - 2,
        memoryFlags: {...state.memoryFlags, 'keeper_pact'}.toList(),
      );
      _appendLog('> Keeper Pact formed: +2 ATK, +4 max SOUL.');
      advanceTurnDay();
      return;
    }

    if (choiceId == 'keeper_resist') {
      state = state.copyWith(
        keeperAlignment: state.keeperAlignment + 1,
        memoryFlags: {...state.memoryFlags, 'keeper_resisted'}.toList(),
      );
      _appendLog('> You hold your will. The Keeper retreats.');
      advanceTurnDay();
      return;
    }

    if (choiceId == 'shadow_offer') {
      state = state.copyWith(
        player: state.player.copyWith(baseAttack: state.player.baseAttack + 1),
        playerEffects: [
          ...state.playerEffects,
          const StatusEffect(
            id: 'shadow_regen',
            type: StatusEffectType.regen,
            potency: 2,
            remainingTurns: 3,
            source: 'shadow_offer',
          ),
        ],
      );
      _appendLog('> Shadow boon: +1 ATK and temporary regen.');
      advanceTurnDay();
      return;
    }
    advanceTurnDay();
  }

  void playerAttack() {
    final enemy = state.enemy;
    if (enemy == null || !state.isPlayerTurn || state.phase != GamePhase.battle)
      return;

    final weaponBonus = state.inventory
        .where((item) => item.type == ItemType.weapon)
        .fold<int>(0, (sum, item) => sum + item.value);
    final result = _combatEngine.playerAttack(
      enemy: enemy,
      attackerPower: state.player.baseAttack + weaponBonus,
      playerLuck: state.player.luck,
      playerHp: state.player.currentHp,
      playerSoul: state.player.currentSoul,
      playerBurst: state.player.soulBurstCharge,
      comboChain: state.comboChain,
      playerEffects: state.playerEffects,
      enemyEffects: state.enemyEffects,
    );
    state = state.copyWith(
      enemy: result.enemy,
      player: state.player.copyWith(
        currentHp: result.playerHp.clamp(0, state.player.maxHp),
        currentSoul: result.playerSoul.clamp(0, state.player.maxSoul),
        soulBurstCharge: result.playerBurst,
      ),
      comboChain: result.comboChain,
      lastPlayerAction: result.lastAction,
      playerEffects: result.playerEffects,
      enemyEffects: result.enemyEffects,
    );
    for (final line in result.logs) {
      _appendLog(line);
    }
    unawaited(_soundService.playSfx(SfxType.attack));

    if (result.enemy.currentHp <= 0) {
      _resolveVictory();
      return;
    }

    state = state.copyWith(
      isPlayerTurn: false,
      turnCounter: state.turnCounter + 1,
    );
    enemyTurn();
  }

  void playerDefend() {
    if (state.enemy == null ||
        !state.isPlayerTurn ||
        state.phase != GamePhase.battle)
      return;
    _appendLog('> You brace for impact.');
    state = state.copyWith(
      isPlayerTurn: false,
      comboChain: 0,
      lastPlayerAction: 'defend',
      turnCounter: state.turnCounter + 1,
      playerEffects: [
        ...state.playerEffects,
        const StatusEffect(
          id: 'defend_shield',
          type: StatusEffectType.shield,
          potency: 3,
          remainingTurns: 1,
          source: 'defend',
        ),
      ],
      player: state.player.copyWith(
        soulBurstCharge: (state.player.soulBurstCharge + 12).clamp(0, 100),
      ),
    );
    enemyTurn(playerDefending: true);
  }

  void playerRun() {
    if (state.enemy == null ||
        !state.isPlayerTurn ||
        state.phase != GamePhase.battle)
      return;
    if (_battleService.tryRunAway()) {
      _appendLog('> You escape the encounter.');
      state = state.copyWith(
        phase: GamePhase.exploring,
        clearEnemy: true,
        isPlayerTurn: true,
      );
      _autoSave();
      return;
    }
    _appendLog('> Escape failed. The enemy blocks your path!');
    state = state.copyWith(
      isPlayerTurn: false,
      comboChain: 0,
      lastPlayerAction: 'run',
      turnCounter: state.turnCounter + 1,
    );
    enemyTurn();
  }

  void usePotionInBattle() {
    if (state.phase != GamePhase.battle || !state.isPlayerTurn) return;
    _consumePotion();
  }

  void castSkill() {
    final enemy = state.enemy;
    if (enemy == null || !state.isPlayerTurn || state.phase != GamePhase.battle)
      return;
    if (state.player.currentSoul < 12) {
      _appendLog('> Not enough SOUL to cast.');
      return;
    }

    final hasSoulFireMastery = state.player.unlockedSkills.contains(
      'arcanist_soul_fire',
    );
    final magicAttack =
        state.player.baseAttack +
        8 +
        (state.player.level * 2) +
        (hasSoulFireMastery ? 4 : 0);
    var damage = _battleService.calculateDamage(
      attackerPower: magicAttack,
      defenderPower: (enemy.defense * 0.7).round(),
    );
    if (enemy.weakToMagic) damage = (damage * 1.4).round();

    final remainingEnemyHp = (enemy.currentHp - damage).clamp(0, enemy.maxHp);
    final nextSoul = (state.player.currentSoul - 12).clamp(
      0,
      state.player.maxSoul,
    );
    final burstCharge = (state.player.soulBurstCharge + 25).clamp(0, 100);
    state = state.copyWith(
      enemy: enemy.copyWith(currentHp: remainingEnemyHp),
      player: state.player.copyWith(
        currentSoul: nextSoul,
        soulBurstCharge: burstCharge,
      ),
      comboChain: state.comboChain + 1,
      lastPlayerAction: 'skill',
      turnCounter: state.turnCounter + 1,
      enemyEffects: [
        ...state.enemyEffects,
        const StatusEffect(
          id: 'soul_fire_burn',
          type: StatusEffectType.burn,
          potency: 3,
          remainingTurns: 2,
          source: 'soul_fire',
        ),
      ],
    );
    _appendLog('> Soul Fire hits ${enemy.name} for $damage magic damage.');
    _appendLog('> ${enemy.name} is afflicted with Soul Burn.');
    unawaited(_soundService.playSfx(SfxType.attack));

    if (remainingEnemyHp <= 0) {
      _resolveVictory();
      return;
    }
    state = state.copyWith(isPlayerTurn: false);
    enemyTurn();
  }

  void useSoulBurst() {
    final enemy = state.enemy;
    if (enemy == null || !state.isPlayerTurn || state.phase != GamePhase.battle)
      return;
    if (state.player.soulBurstCharge < 100) {
      _appendLog('> Soul Burst is not fully charged.');
      return;
    }

    if (state.player.currentHp <= state.player.maxHp ~/ 2) {
      final healed = (state.player.currentHp + 40).clamp(0, state.player.maxHp);
      state = state.copyWith(
        player: state.player.copyWith(currentHp: healed, soulBurstCharge: 0),
        comboChain: 0,
        lastPlayerAction: 'soul_burst_heal',
        turnCounter: state.turnCounter + 1,
      );
      _appendLog('> Soul Burst surges inward. You recover 40 HP.');
      state = state.copyWith(isPlayerTurn: false);
      enemyTurn();
      return;
    }

    final hasOverdrive = state.player.unlockedSkills.contains(
      'vanguard_overdrive',
    );
    final damage = _battleService.calculateDamage(
      attackerPower: state.player.baseAttack + 40 + (hasOverdrive ? 10 : 0),
      defenderPower: (enemy.defense * 0.5).round(),
    );
    final remainingEnemyHp = (enemy.currentHp - damage).clamp(0, enemy.maxHp);
    state = state.copyWith(
      enemy: enemy.copyWith(currentHp: remainingEnemyHp),
      player: state.player.copyWith(soulBurstCharge: 0),
      comboChain: 0,
      lastPlayerAction: 'soul_burst',
      turnCounter: state.turnCounter + 1,
    );
    _appendLog('> Soul Burst tears through ${enemy.name} for $damage damage.');
    unawaited(_soundService.playSfx(SfxType.criticalHit));

    if (remainingEnemyHp <= 0) {
      _resolveVictory();
      return;
    }
    state = state.copyWith(isPlayerTurn: false);
    enemyTurn();
  }

  void usePotionOutsideBattle() => _consumePotion();

  void updatePlayerProfile({
    required String name,
    required PlayerClass classPath,
  }) {
    final nextName = name.trim().isEmpty ? 'Bound Soul' : name.trim();
    final current = state.player;
    var nextSkills = current.unlockedSkills;
    if (classPath != current.classPath && current.level <= 1) {
      nextSkills = switch (classPath) {
        PlayerClass.vanguard => const ['vanguard_combo_core'],
        PlayerClass.arcanist => const ['arcanist_mana_lattice'],
        PlayerClass.shade => const ['shade_blade_veil'],
      };
    }
    state = state.copyWith(
      player: current.copyWith(
        name: nextName,
        classPath: classPath,
        unlockedSkills: nextSkills,
      ),
    );
    _appendLog('> Profile updated. $nextName walks the $classPath path.');
    _autoSave();
  }

  void enemyTurn({bool playerDefending = false}) {
    final enemy = state.enemy;
    if (enemy == null || state.phase != GamePhase.battle) return;

    final armorBonus = state.inventory
        .where((i) => i.type == ItemType.armor)
        .fold<int>(0, (sum, item) => sum + item.value);
    final result = _combatEngine.enemyTurn(
      enemy: enemy,
      turnCounter: state.turnCounter,
      playerHp: state.player.currentHp,
      playerMaxHp: state.player.maxHp,
      playerDefense: state.player.baseDefense + armorBonus,
      defending: playerDefending,
      playerSoul: state.player.currentSoul,
      playerBurst: state.player.soulBurstCharge,
      playerEffects: state.playerEffects,
      enemyEffects: state.enemyEffects,
    );
    var hp = result.playerHp;
    var nextEnemy = result.enemy.copyWith(intent: result.intent.name);

    if (state.inventory.any((i) => i.id == 'cursed_ring')) {
      hp = (hp - 2).clamp(0, state.player.maxHp);
      _appendLog('> The Cursed Ring drains 2 HP.');
    }

    for (final line in result.logs) {
      _appendLog(line);
    }
    final nextSoul = result.playerSoul.clamp(0, state.player.maxSoul);
    state = state.copyWith(
      enemy: nextEnemy,
      player: state.player.copyWith(currentHp: hp, currentSoul: nextSoul),
      comboChain: 0,
      playerEffects: result.playerEffects,
      enemyEffects: result.enemyEffects,
    );
    unawaited(_soundService.playSfx(SfxType.enemyAttack));

    if (hp <= 0) {
      _applyDeathLoop();
      unawaited(_soundService.playSfx(SfxType.gameOver));
      _syncBgmToState();
      _autoSave();
      return;
    }

    state = state.copyWith(isPlayerTurn: true);
  }

  void _resolveVictory() {
    final enemy = state.enemy;
    if (enemy == null) return;

    var player = state.player.copyWith(
      gold: state.player.gold + enemy.goldReward,
    );
    final hasKeeperPact = state.memoryFlags.contains('keeper_pact');
    if (hasKeeperPact) {
      player = player.copyWith(
        currentSoul: (player.currentSoul + 4).clamp(0, player.maxSoul),
      );
    }
    player = LevelService.applyXp(player, enemy.xpReward);
    player = _unlockStarterSkills(player);
    final leveledUp = player.level > state.player.level;

    final nextRiftLevel = state.riftLevel + 1;
    state = state.copyWith(
      player: player,
      phase: GamePhase.exploring,
      clearEnemy: true,
      isPlayerTurn: true,
      riftLevel: nextRiftLevel,
      day: state.day + 1,
      choices: _randomEventService.nextChoices(
        state.storyBeat + 1,
        memoryFlags: state.memoryFlags,
        keeperAlignment: state.keeperAlignment,
      ),
      storyBeat: state.storyBeat + 1,
      playerEffects: const [],
      enemyEffects: const [],
    );

    _appendLog(
      '> ${enemy.name} defeated. +${enemy.xpReward} XP, +${enemy.goldReward} gold.',
    );
    unawaited(_soundService.playSfx(SfxType.enemyDeath));
    _appendLog('> You advance to Rift Level $nextRiftLevel.');
    _syncBgmToState();
    if (leveledUp) {
      _appendLog('> Level up! You are now level ${player.level}.');
      _appendLog('> Skill point available: ${player.skillPoints}.');
      unawaited(_soundService.playSfx(SfxType.levelUp));
    }
    _autoSave();
  }

  void _consumePotion() {
    final potionIndex = state.inventory.indexWhere(
      (item) => item.type == ItemType.consumable,
    );
    if (potionIndex < 0) {
      _appendLog('> No consumable available.');
      return;
    }

    final potion = state.inventory[potionIndex];
    final healed = (state.player.currentHp + potion.value).clamp(
      0,
      state.player.maxHp,
    );
    final nextInventory = [...state.inventory]..removeAt(potionIndex);
    state = state.copyWith(
      player: state.player.copyWith(currentHp: healed),
      inventory: nextInventory,
    );
    _appendLog('> You use ${potion.name} and recover ${potion.value} HP.');
    unawaited(_soundService.playSfx(SfxType.itemUse));
    _autoSave();
  }

  void _applyDeathLoop() {
    final nextLoop = state.loopCount + 1;
    final nextEchoShards = state.echoShards + 1;
    final unlockedEchoes = _resolveUnlockedEchoes(
      nextEchoShards,
      state.unlockedEchoes,
    );
    final keepsLoopCrystal = state.inventory.any(
      (item) => item.id == 'loop_crystal',
    );
    final persistentItems = keepsLoopCrystal
        ? state.inventory.where((i) => i.type == ItemType.relic).toList()
        : <Item>[];
    final reset = GameState.initial();
    final baseInventory = [...reset.inventory, ...persistentItems];
    final inventoryWithEchoes = unlockedEchoes.contains('echo_cache')
        ? [
            ...baseInventory,
            const Item(
              id: 'echo_potion',
              name: 'Echo Potion',
              type: ItemType.consumable,
              value: 20,
              description: 'Restores 20 HP. Reformed by loop memory.',
            ),
          ]
        : baseInventory;
    final nextPlayer = _applyEchoBonusesToPlayer(reset.player, unlockedEchoes);
    state = reset.copyWith(
      player: nextPlayer,
      loopCount: nextLoop,
      riftLevel: (1 + (nextLoop ~/ 2)).clamp(1, 99),
      storyBeat: state.storyBeat + 1,
      inventory: inventoryWithEchoes,
      memoryFlags: {
        ...state.memoryFlags,
        'died_once',
        if (nextLoop >= 3) 'loop_hardened',
      }.toList(),
      keeperAlignment: state.keeperAlignment,
      echoShards: nextEchoShards,
      unlockedEchoes: unlockedEchoes,
      log: [
        ...state.log,
        '> You fall... then wake again.',
        '> Loop #$nextLoop begins. NPCs whisper fragments of your past life.',
        '> Echo Shard gained. Total shards: $nextEchoShards.',
        ..._echoUnlockLogs(unlockedEchoes, state.unlockedEchoes),
        '> Memory remains: ${unlockedEchoes.isEmpty ? 'none yet' : unlockedEchoes.join(', ')}.',
      ],
    );
  }

  List<String> _resolveUnlockedEchoes(int echoShards, List<String> current) {
    final echoes = {...current};
    if (echoShards >= 1) echoes.add('echo_vitality');
    if (echoShards >= 2) echoes.add('echo_cache');
    if (echoShards >= 3) echoes.add('echo_foresight');
    return echoes.toList()..sort();
  }

  Player _applyEchoBonusesToPlayer(Player player, List<String> echoes) {
    var next = player;
    if (echoes.contains('echo_vitality')) {
      next = next.copyWith(
        maxHp: next.maxHp + 5,
        currentHp: next.currentHp + 5,
      );
    }
    return next;
  }

  List<String> _echoUnlockLogs(List<String> next, List<String> previous) {
    final previousSet = previous.toSet();
    final added = next.where((echo) => !previousSet.contains(echo)).toList();
    return added.map((echo) {
      return switch (echo) {
        'echo_vitality' =>
          '> Echo Unlocked: Vitality (+5 Max HP each loop start).',
        'echo_cache' =>
          '> Echo Unlocked: Cache (start each loop with an extra consumable).',
        'echo_foresight' =>
          '> Echo Unlocked: Foresight (encounter forecast in logs).',
        _ => '> Echo resonance deepens.',
      };
    }).toList();
  }

  void _appendEncounterForecast(String enemyName) {
    if (!state.unlockedEchoes.contains('echo_foresight')) return;
    if (enemyName == 'Soul Leech') {
      _appendLog(
        '> Echo Foresight: Siphon pattern detected. Guard before sustain turns.',
      );
      return;
    }
    if (enemyName == 'Mirror Shade') {
      _appendLog(
        '> Echo Foresight: Mirror behavior detected. Avoid reckless burst openers.',
      );
      return;
    }
    if (enemyName == 'The Forgotten King' ||
        enemyName == 'The Time Devourer' ||
        enemyName == 'The Keeper') {
      _appendLog(
        '> Echo Foresight: Boss pressure spike expected. Save Soul Burst.',
      );
      return;
    }
    _appendLog('> Echo Foresight: Standard aggression pattern expected.');
  }

  void _appendLog(String message) {
    final lines = [...state.log, message];
    state = state.copyWith(
      log: lines.length > 200 ? lines.sublist(lines.length - 200) : lines,
    );
  }

  void _playEncounterSound(String enemyName) {
    if (enemyName == 'The Forgotten King' ||
        enemyName == 'The Time Devourer' ||
        enemyName == 'The Keeper') {
      unawaited(_soundService.playSfx(SfxType.menuOpen));
      return;
    }
    unawaited(_soundService.playSfx(SfxType.enemyAttack));
  }

  void _syncBgmToState() {
    if (!state.soundEnabled) return;
    if (state.phase == GamePhase.battle && state.enemy != null) {
      final isBoss =
          state.enemy!.name == 'The Forgotten King' ||
          state.enemy!.name == 'The Time Devourer' ||
          state.enemy!.name == 'The Keeper';
      unawaited(_soundService.playBgm(isBoss ? BgmType.boss : BgmType.battle));
      return;
    }
    unawaited(_soundService.playBgm(BgmType.exploration));
  }

  @override
  void dispose() {
    unawaited(_soundService.dispose());
    super.dispose();
  }

  void _autoSave() {
    unawaited(_saveService.save(state));
  }

  Player _unlockStarterSkills(Player player) {
    final skills = {...player.unlockedSkills};
    if (player.level >= 2) {
      switch (player.classPath.name) {
        case 'vanguard':
          skills.add('vanguard_overdrive');
        case 'arcanist':
          skills.add('arcanist_soul_fire');
        case 'shade':
          skills.add('shade_bleedstep');
      }
    }
    if (skills.length == player.unlockedSkills.length) return player;
    return player.copyWith(unlockedSkills: skills.toList());
  }
}
