class Player {
  const Player({required this.name, required this.maxHp, required this.currentHp, required this.xp, required this.level, required this.gold, required this.baseAttack, required this.baseDefense});

  factory Player.initial() => const Player(name: 'Warden', maxHp: 100, currentHp: 100, xp: 0, level: 1, gold: 20, baseAttack: 12, baseDefense: 5);

  final String name;
  final int maxHp;
  final int currentHp;
  final int xp;
  final int level;
  final int gold;
  final int baseAttack;
  final int baseDefense;

  Player copyWith({String? name, int? maxHp, int? currentHp, int? xp, int? level, int? gold, int? baseAttack, int? baseDefense}) => Player(
        name: name ?? this.name,
        maxHp: maxHp ?? this.maxHp,
        currentHp: currentHp ?? this.currentHp,
        xp: xp ?? this.xp,
        level: level ?? this.level,
        gold: gold ?? this.gold,
        baseAttack: baseAttack ?? this.baseAttack,
        baseDefense: baseDefense ?? this.baseDefense,
      );

  Map<String, dynamic> toJson() => {'name': name, 'maxHp': maxHp, 'currentHp': currentHp, 'xp': xp, 'level': level, 'gold': gold, 'baseAttack': baseAttack, 'baseDefense': baseDefense};

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        name: json['name'] as String,
        maxHp: json['maxHp'] as int,
        currentHp: json['currentHp'] as int,
        xp: json['xp'] as int,
        level: json['level'] as int,
        gold: json['gold'] as int,
        baseAttack: json['baseAttack'] as int,
        baseDefense: json['baseDefense'] as int,
      );
}
