enum StatusEffectType { burn, weaken, shield, regen }

class StatusEffect {
  const StatusEffect({
    required this.id,
    required this.type,
    required this.potency,
    required this.remainingTurns,
    this.source = 'system',
  });

  final String id;
  final StatusEffectType type;
  final int potency;
  final int remainingTurns;
  final String source;

  StatusEffect copyWith({
    int? potency,
    int? remainingTurns,
  }) =>
      StatusEffect(
        id: id,
        type: type,
        potency: potency ?? this.potency,
        remainingTurns: remainingTurns ?? this.remainingTurns,
        source: source,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'potency': potency,
        'remainingTurns': remainingTurns,
        'source': source,
      };

  factory StatusEffect.fromJson(Map<String, dynamic> json) => StatusEffect(
        id: json['id'] as String,
        type: StatusEffectType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? StatusEffectType.burn.name),
        ),
        potency: (json['potency'] as int?) ?? 0,
        remainingTurns: (json['remainingTurns'] as int?) ?? 1,
        source: (json['source'] as String?) ?? 'system',
      );
}
