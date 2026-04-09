import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/game_state.dart';

class SaveService {
  static const _saveKey = 'rift_rpg_save';

  Future<void> save(GameState gameState) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_saveKey, jsonEncode(gameState.toJson()));
  }

  Future<GameState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_saveKey);
    if (payload == null) return null;
    try {
      final raw = jsonDecode(payload) as Map<String, dynamic>;
      final migrated = _migratePayload(raw);
      return GameState.fromJson(migrated);
    } catch (_) {
      // Old/corrupt save payloads should not crash app startup.
      await prefs.remove(_saveKey);
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }

  Map<String, dynamic> _migratePayload(Map<String, dynamic> raw) {
    final schema = (raw['schemaVersion'] as int?) ?? 1;
    if (schema >= 2) return raw;
    return _migrateV1ToV2(raw);
  }

  Map<String, dynamic> _migrateV1ToV2(Map<String, dynamic> raw) {
    final migrated = Map<String, dynamic>.from(raw);
    final player = Map<String, dynamic>.from((migrated['player'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{});
    player.putIfAbsent('classPath', () => 'vanguard');
    player.putIfAbsent('skillPoints', () => 0);
    player.putIfAbsent('unlockedSkills', () => ['vanguard_combo_core']);
    migrated['player'] = player;
    migrated['schemaVersion'] = 2;
    migrated.putIfAbsent('turnCounter', () => 0);
    migrated.putIfAbsent('comboChain', () => 0);
    migrated.putIfAbsent('lastPlayerAction', () => null);
    migrated.putIfAbsent('playerEffects', () => <Map<String, dynamic>>[]);
    migrated.putIfAbsent('enemyEffects', () => <Map<String, dynamic>>[]);
    migrated.putIfAbsent('memoryFlags', () => <String>[]);
    migrated.putIfAbsent('keeperAlignment', () => 0);
    return migrated;
  }
}
