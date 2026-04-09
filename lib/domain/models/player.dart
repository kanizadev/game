import 'player_class.dart';

class Player {
  const Player({
    required this.name,
    required this.maxHp,
    required this.currentHp,
    required this.maxSoul,
    required this.currentSoul,
    required this.xp,
    required this.level,
    required this.gold,
    required this.baseAttack,
    required this.baseDefense,
    required this.luck,
    required this.soulBurstCharge,
    required this.classPath,
    required this.skillPoints,
    required this.unlockedSkills,
  });

  factory Player.initial() => const Player(
        name: 'Bound Soul',
        maxHp: 110,
        currentHp: 110,
        maxSoul: 50,
        currentSoul: 50,
        xp: 0,
        level: 1,
        gold: 20,
        baseAttack: 12,
        baseDefense: 5,
        luck: 8,
        soulBurstCharge: 0,
        classPath: PlayerClass.vanguard,
        skillPoints: 0,
        unlockedSkills: ['vanguard_combo_core'],
      );

  final String name;
  final int maxHp;
  final int currentHp;
  final int maxSoul;
  final int currentSoul;
  final int xp;
  final int level;
  final int gold;
  final int baseAttack;
  final int baseDefense;
  final int luck;
  final int soulBurstCharge;
  final PlayerClass classPath;
  final int skillPoints;
  final List<String> unlockedSkills;

  Player copyWith({
    String? name,
    int? maxHp,
    int? currentHp,
    int? maxSoul,
    int? currentSoul,
    int? xp,
    int? level,
    int? gold,
    int? baseAttack,
    int? baseDefense,
    int? luck,
    int? soulBurstCharge,
    PlayerClass? classPath,
    int? skillPoints,
    List<String>? unlockedSkills,
  }) =>
      Player(
        name: name ?? this.name,
        maxHp: maxHp ?? this.maxHp,
        currentHp: currentHp ?? this.currentHp,
        maxSoul: maxSoul ?? this.maxSoul,
        currentSoul: currentSoul ?? this.currentSoul,
        xp: xp ?? this.xp,
        level: level ?? this.level,
        gold: gold ?? this.gold,
        baseAttack: baseAttack ?? this.baseAttack,
        baseDefense: baseDefense ?? this.baseDefense,
        luck: luck ?? this.luck,
        soulBurstCharge: soulBurstCharge ?? this.soulBurstCharge,
        classPath: classPath ?? this.classPath,
        skillPoints: skillPoints ?? this.skillPoints,
        unlockedSkills: unlockedSkills ?? this.unlockedSkills,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'maxHp': maxHp,
        'currentHp': currentHp,
        'maxSoul': maxSoul,
        'currentSoul': currentSoul,
        'xp': xp,
        'level': level,
        'gold': gold,
        'baseAttack': baseAttack,
        'baseDefense': baseDefense,
        'luck': luck,
        'soulBurstCharge': soulBurstCharge,
        'classPath': classPath.name,
        'skillPoints': skillPoints,
        'unlockedSkills': unlockedSkills,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        name: json['name'] as String,
        maxHp: json['maxHp'] as int,
        currentHp: json['currentHp'] as int,
        maxSoul: (json['maxSoul'] as int?) ?? 50,
        currentSoul: (json['currentSoul'] as int?) ?? ((json['maxSoul'] as int?) ?? 50),
        xp: json['xp'] as int,
        level: json['level'] as int,
        gold: json['gold'] as int,
        baseAttack: json['baseAttack'] as int,
        baseDefense: json['baseDefense'] as int,
        luck: (json['luck'] as int?) ?? 8,
        soulBurstCharge: (json['soulBurstCharge'] as int?) ?? 0,
        classPath: playerClassFromName(json['classPath'] as String?),
        skillPoints: (json['skillPoints'] as int?) ?? 0,
        unlockedSkills: (json['unlockedSkills'] as List?)?.map((e) => e as String).toList() ?? const ['vanguard_combo_core'],
      );
}
