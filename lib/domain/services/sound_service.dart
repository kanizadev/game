import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum SfxType {
  uiClick,
  menuOpen,
  attack,
  criticalHit,
  enemyAttack,
  enemyDeath,
  itemUse,
  levelUp,
  gameOver,
}

enum BgmType {
  exploration,
  battle,
  boss,
}

class SoundService {
  SoundService();

  AudioPlayer? _sfxPlayer;
  AudioPlayer? _bgmPlayer;
  bool _enabled = false;
  bool _audioAvailable = true;
  bool _initialized = false;
  BgmType? _activeBgm;

  static const Map<SfxType, String> _sfxAssets = {
    SfxType.uiClick: 'assets/sounds/sfx/ui_tick.wav',
    SfxType.menuOpen: 'assets/sounds/sfx/ui_blip.wav',
    SfxType.attack: 'assets/sounds/sfx/attack_slash.wav',
    SfxType.criticalHit: 'assets/sounds/sfx/critical_impact.wav',
    SfxType.enemyAttack: 'assets/sounds/sfx/enemy_dark_hit.wav',
    SfxType.enemyDeath: 'assets/sounds/sfx/enemy_break.wav',
    SfxType.itemUse: 'assets/sounds/sfx/item_pop.wav',
    SfxType.levelUp: 'assets/sounds/sfx/levelup_8bit.wav',
    SfxType.gameOver: 'assets/sounds/sfx/gameover_glitch.wav',
  };

  static const Map<BgmType, String> _bgmAssets = {
    BgmType.exploration: 'assets/sounds/bgm/exploration_loop.wav',
    BgmType.battle: 'assets/sounds/bgm/battle_loop.wav',
    BgmType.boss: 'assets/sounds/bgm/boss_loop.wav',
  };

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await _ensureInitialized();
    if (!_audioAvailable) return;
    if (!enabled) {
      await _bgmPlayer?.stop();
      _activeBgm = null;
      return;
    }
    await _bgmPlayer?.setVolume(0.22);
    await _sfxPlayer?.setVolume(0.40);
  }

  Future<void> playSfx(SfxType type) async {
    if (!_enabled) return;
    await _ensureInitialized();
    if (!_audioAvailable) return;
    final assetPath = _sfxAssets[type];
    if (assetPath == null) return;
    try {
      await _sfxPlayer?.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (_) {
      if (!kIsWeb) {
        await SystemSound.play(SystemSoundType.click);
      }
    }
  }

  Future<void> playBgm(BgmType type) async {
    if (!_enabled) return;
    await _ensureInitialized();
    if (!_audioAvailable) return;
    if (_activeBgm == type) return;
    final assetPath = _bgmAssets[type];
    if (assetPath == null) return;
    _activeBgm = type;
    try {
      await _bgmPlayer?.setVolume(0.22);
      await _bgmPlayer?.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (_) {
      _activeBgm = null;
    }
  }

  Future<void> stopBgm() async {
    _activeBgm = null;
    await _bgmPlayer?.stop();
  }

  Future<void> dispose() async {
    await _sfxPlayer?.dispose();
    await _bgmPlayer?.dispose();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    try {
      _sfxPlayer = AudioPlayer(playerId: 'sfx');
      _bgmPlayer = AudioPlayer(playerId: 'bgm');
      await _bgmPlayer?.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayer?.setPlayerMode(PlayerMode.lowLatency);
    } catch (_) {
      _audioAvailable = false;
      _sfxPlayer = null;
      _bgmPlayer = null;
    }
  }
}
