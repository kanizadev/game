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
      return GameState.fromJson(jsonDecode(payload) as Map<String, dynamic>);
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
}
