class Enemy {
  const Enemy({required this.id, required this.name, required this.maxHp, required this.currentHp, required this.attack, required this.defense, required this.xpReward, required this.goldReward});

  final String id;
  final String name;
  final int maxHp;
  final int currentHp;
  final int attack;
  final int defense;
  final int xpReward;
  final int goldReward;

  Enemy copyWith({int? currentHp}) => Enemy(id: id, name: name, maxHp: maxHp, currentHp: currentHp ?? this.currentHp, attack: attack, defense: defense, xpReward: xpReward, goldReward: goldReward);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'maxHp': maxHp, 'currentHp': currentHp, 'attack': attack, 'defense': defense, 'xpReward': xpReward, 'goldReward': goldReward};

  factory Enemy.fromJson(Map<String, dynamic> json) => Enemy(
        id: json['id'] as String,
        name: json['name'] as String,
        maxHp: json['maxHp'] as int,
        currentHp: json['currentHp'] as int,
        attack: json['attack'] as int,
        defense: json['defense'] as int,
        xpReward: json['xpReward'] as int,
        goldReward: json['goldReward'] as int,
      );
}
