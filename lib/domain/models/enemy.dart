enum EnemyTier { common, elite, boss }

class Enemy {
  const Enemy({
    required this.id,
    required this.name,
    required this.tier,
    required this.maxHp,
    required this.currentHp,
    required this.attack,
    required this.defense,
    required this.xpReward,
    required this.goldReward,
    this.weakToMagic = false,
    this.drainsHp = false,
    this.mirrorStats = false,
    this.aiProfile = 'aggressive',
    this.intent = 'attack',
  });

  final String id;
  final String name;
  final EnemyTier tier;
  final int maxHp;
  final int currentHp;
  final int attack;
  final int defense;
  final int xpReward;
  final int goldReward;
  final bool weakToMagic;
  final bool drainsHp;
  final bool mirrorStats;
  final String aiProfile;
  final String intent;

  Enemy copyWith({int? currentHp, int? attack, int? defense, String? intent}) => Enemy(
        id: id,
        name: name,
        tier: tier,
        maxHp: maxHp,
        currentHp: currentHp ?? this.currentHp,
        attack: attack ?? this.attack,
        defense: defense ?? this.defense,
        xpReward: xpReward,
        goldReward: goldReward,
        weakToMagic: weakToMagic,
        drainsHp: drainsHp,
        mirrorStats: mirrorStats,
        aiProfile: aiProfile,
        intent: intent ?? this.intent,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tier': tier.name,
        'maxHp': maxHp,
        'currentHp': currentHp,
        'attack': attack,
        'defense': defense,
        'xpReward': xpReward,
        'goldReward': goldReward,
        'weakToMagic': weakToMagic,
        'drainsHp': drainsHp,
        'mirrorStats': mirrorStats,
        'aiProfile': aiProfile,
        'intent': intent,
      };

  factory Enemy.fromJson(Map<String, dynamic> json) => Enemy(
        id: json['id'] as String,
        name: json['name'] as String,
        tier: EnemyTier.values.firstWhere(
          (e) => e.name == (json['tier'] as String? ?? 'common'),
        ),
        maxHp: json['maxHp'] as int,
        currentHp: json['currentHp'] as int,
        attack: json['attack'] as int,
        defense: json['defense'] as int,
        xpReward: json['xpReward'] as int,
        goldReward: json['goldReward'] as int,
        weakToMagic: (json['weakToMagic'] as bool?) ?? false,
        drainsHp: (json['drainsHp'] as bool?) ?? false,
        mirrorStats: (json['mirrorStats'] as bool?) ?? false,
        aiProfile: (json['aiProfile'] as String?) ?? 'aggressive',
        intent: (json['intent'] as String?) ?? 'attack',
      );
}
