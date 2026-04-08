import 'enemy.dart';
import 'item.dart';
import 'player.dart';

enum GamePhase { exploring, battle, gameOver }

class StoryChoice {
  const StoryChoice({required this.id, required this.text});
  final String id;
  final String text;
  Map<String, dynamic> toJson() => {'id': id, 'text': text};
  factory StoryChoice.fromJson(Map<String, dynamic> json) => StoryChoice(id: json['id'] as String, text: json['text'] as String);
}

class GameState {
  const GameState({
    required this.player,
    required this.inventory,
    required this.log,
    required this.phase,
    required this.enemy,
    required this.choices,
    required this.isPlayerTurn,
    required this.soundEnabled,
    required this.storyBeat,
    required this.day,
    required this.riftLevel,
  });

  factory GameState.initial() => GameState(
        player: Player.initial(),
        inventory: const [
          Item(id: 'rust_blade', name: 'Rust Blade', type: ItemType.weapon, value: 4, description: 'Old sword. Adds +4 attack.'),
          Item(id: 'small_potion', name: 'Small Potion', type: ItemType.potion, value: 25, description: 'Restores 25 HP.'),
        ],
        log: const ['> Boot complete. Welcome, Warden.'],
        phase: GamePhase.exploring,
        enemy: null,
        choices: const [StoryChoice(id: 'scout', text: 'Scout the ruins'), StoryChoice(id: 'rest', text: 'Rest by the fire'), StoryChoice(id: 'merchant', text: 'Visit a traveling merchant')],
        isPlayerTurn: true,
        soundEnabled: false,
        storyBeat: 0,
        day: 1,
        riftLevel: 1,
      );

  final Player player;
  final List<Item> inventory;
  final List<String> log;
  final GamePhase phase;
  final Enemy? enemy;
  final List<StoryChoice> choices;
  final bool isPlayerTurn;
  final bool soundEnabled;
  final int storyBeat;
  final int day;
  final int riftLevel;

  GameState copyWith({
    Player? player,
    List<Item>? inventory,
    List<String>? log,
    GamePhase? phase,
    Enemy? enemy,
    List<StoryChoice>? choices,
    bool? isPlayerTurn,
    bool? soundEnabled,
    int? storyBeat,
    int? day,
    int? riftLevel,
    bool clearEnemy = false,
  }) =>
      GameState(
        player: player ?? this.player,
        inventory: inventory ?? this.inventory,
        log: log ?? this.log,
        phase: phase ?? this.phase,
        enemy: clearEnemy ? null : (enemy ?? this.enemy),
        choices: choices ?? this.choices,
        isPlayerTurn: isPlayerTurn ?? this.isPlayerTurn,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        storyBeat: storyBeat ?? this.storyBeat,
        day: day ?? this.day,
        riftLevel: riftLevel ?? this.riftLevel,
      );

  Map<String, dynamic> toJson() => {
        'player': player.toJson(),
        'inventory': inventory.map((i) => i.toJson()).toList(),
        'log': log,
        'phase': phase.name,
        'enemy': enemy?.toJson(),
        'choices': choices.map((c) => c.toJson()).toList(),
        'isPlayerTurn': isPlayerTurn,
        'soundEnabled': soundEnabled,
        'storyBeat': storyBeat,
        'day': day,
        'riftLevel': riftLevel,
      };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        player: Player.fromJson(json['player'] as Map<String, dynamic>),
        inventory: (json['inventory'] as List).map((e) => Item.fromJson(e as Map<String, dynamic>)).toList(),
        log: (json['log'] as List).map((e) => e as String).toList(),
        phase: GamePhase.values.firstWhere((e) => e.name == json['phase']),
        enemy: json['enemy'] == null ? null : Enemy.fromJson(json['enemy'] as Map<String, dynamic>),
        choices: (json['choices'] as List).map((e) => StoryChoice.fromJson(e as Map<String, dynamic>)).toList(),
        isPlayerTurn: json['isPlayerTurn'] as bool,
        soundEnabled: json['soundEnabled'] as bool,
        storyBeat: json['storyBeat'] as int,
        day: (json['day'] as int?) ?? 1,
        riftLevel: (json['riftLevel'] as int?) ?? 1,
      );
}
