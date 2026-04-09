class SkillNode {
  const SkillNode({
    required this.id,
    required this.name,
    required this.description,
    required this.classPath,
    required this.cost,
  });

  final String id;
  final String name;
  final String description;
  final String classPath;
  final int cost;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'classPath': classPath,
        'cost': cost,
      };

  factory SkillNode.fromJson(Map<String, dynamic> json) => SkillNode(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        classPath: json['classPath'] as String,
        cost: json['cost'] as int,
      );
}
