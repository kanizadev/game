import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../application/providers/game_provider.dart';
import '../../domain/models/player_class.dart';
import '../../domain/services/level_service.dart';
import '../widgets/stat_row.dart';

class CharacterStatsScreen extends ConsumerWidget {
  const CharacterStatsScreen({super.key});
  static const routeName = '/stats';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final player = state.player;
    return Scaffold(
      appBar: AppBar(title: const Text('Person Profile')),
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
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF111827), Color(0xFF1F2937)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      child: const FaIcon(FontAwesomeIcons.user, size: 30),
                    ),
                    const SizedBox(height: 10),
                    Text(player.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Bound Soul • Loop ${state.loopCount}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"Die, learn, return... break the cycle."',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      StatRow(label: 'Level', value: '${player.level}'),
                      StatRow(label: 'XP', value: '${player.xp}'),
                      StatRow(label: 'Next Level', value: '${LevelService.xpForNextLevel(player.level)} XP'),
                      StatRow(label: 'Gold', value: '${player.gold}'),
                      StatRow(label: 'Class', value: player.classPath.label),
                      StatRow(label: 'Skill Points', value: '${player.skillPoints}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      StatRow(label: 'HP', value: '${player.currentHp} / ${player.maxHp}'),
                      StatRow(label: 'SOUL', value: '${player.currentSoul} / ${player.maxSoul}'),
                      StatRow(label: 'Attack', value: '${player.baseAttack}'),
                      StatRow(label: 'Defense', value: '${player.baseDefense}'),
                      StatRow(label: 'Luck', value: '${player.luck}'),
                      StatRow(label: 'Soul Burst', value: '${player.soulBurstCharge}%'),
                      StatRow(label: 'Unlocked Skills', value: '${player.unlockedSkills.length}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
