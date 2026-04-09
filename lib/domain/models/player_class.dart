enum PlayerClass { vanguard, arcanist, shade }

extension PlayerClassX on PlayerClass {
  String get label => switch (this) {
        PlayerClass.vanguard => 'Vanguard',
        PlayerClass.arcanist => 'Arcanist',
        PlayerClass.shade => 'Shade',
      };
}

PlayerClass playerClassFromName(String? value) {
  return PlayerClass.values.firstWhere(
    (e) => e.name == value,
    orElse: () => PlayerClass.vanguard,
  );
}
