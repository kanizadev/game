enum ItemType { weapon, consumable, armor, relic }

class Item {
  const Item({required this.id, required this.name, required this.type, required this.value, required this.description});
  final String id;
  final String name;
  final ItemType type;
  final int value;
  final String description;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'type': type.name, 'value': value, 'description': description};

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        name: json['name'] as String,
        type: ItemType.values.firstWhere((e) => e.name == json['type']),
        value: json['value'] as int,
        description: json['description'] as String,
      );
}
