import 'dart:math';

import '../models/enemy.dart';
import '../models/game_state.dart';

class RandomEventService {
  RandomEventService({Random? random}) : _random = random ?? Random();
  final Random _random;

  Enemy randomEnemy(int playerLevel, int riftLevel) {
    final templates = [('Rift Rat', 40, 9, 2, 35, 8), ('Ash Goblin', 55, 12, 4, 45, 13), ('Bone Wisp', 70, 14, 5, 60, 18), ('Night Marauder', 90, 18, 7, 80, 25)];
    final t = templates[_random.nextInt(templates.length)];
    final effectiveLevel = playerLevel + (riftLevel - 1);
    final scale = 1 + ((effectiveLevel - 1) * 0.15);
    return Enemy(id: t.$1.toLowerCase().replaceAll(' ', '_'), name: t.$1, maxHp: (t.$2 * scale).round(), currentHp: (t.$2 * scale).round(), attack: (t.$3 * scale).round(), defense: (t.$4 * scale).round(), xpReward: (t.$5 * scale).round(), goldReward: (t.$6 * scale).round());
  }

  List<StoryChoice> nextChoices(int storyBeat) {
    if (storyBeat % 3 == 0) {
      return const [StoryChoice(id: 'scout', text: 'Scout the ruins'), StoryChoice(id: 'rest', text: 'Rest by the fire'), StoryChoice(id: 'merchant', text: 'Search for a merchant')];
    }
    return const [StoryChoice(id: 'forward', text: 'Advance deeper into the rift'), StoryChoice(id: 'listen', text: 'Listen for danger'), StoryChoice(id: 'forage', text: 'Forage for supplies')];
  }

  bool shouldTriggerEncounter(int day, int riftLevel) {
    final chance = (45 + (day ~/ 3) + (riftLevel * 3)).clamp(45, 85);
    return _random.nextInt(100) < chance;
  }

  String flavorText(String choiceId) {
    switch (choiceId) {
      case 'rest':
        return 'You recover your breath, but shadows move nearby.';
      case 'merchant':
        return 'A hooded trader offers supplies and vanishes in mist.';
      case 'listen':
        return 'Faint claws scrape stone in the dark.';
      case 'forage':
        return 'You gather herbs and old coins among broken relics.';
      default:
        return 'You move carefully through the fractured corridor.';
    }
  }
}
