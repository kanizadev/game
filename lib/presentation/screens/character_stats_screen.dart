import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/game_provider.dart';
import '../../domain/services/level_service.dart';
import '../widgets/stat_row.dart';

class CharacterStatsScreen extends ConsumerWidget {
  const CharacterStatsScreen({super.key});
  static const routeName = '/stats';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(gameProvider).player;
    return Scaffold(
      appBar: AppBar(title: const Text('Character Stats')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1117), Color(0xFF111827)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              StatRow(label: 'Name', value: player.name),
              StatRow(label: 'Level', value: '${player.level}'),
              StatRow(label: 'HP', value: '${player.currentHp} / ${player.maxHp}'),
              StatRow(label: 'XP', value: '${player.xp}'),
              StatRow(label: 'Next Level', value: '${LevelService.xpForNextLevel(player.level)} XP'),
              StatRow(label: 'Gold', value: '${player.gold}'),
              StatRow(label: 'Attack', value: '${player.baseAttack}'),
              StatRow(label: 'Defense', value: '${player.baseDefense}'),
            ],
          ),
        ),
      ),
    );
  }
}
