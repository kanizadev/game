import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../application/providers/game_provider.dart';
import '../../domain/models/player_class.dart';
import '../../domain/services/level_service.dart';
import '../widgets/stat_row.dart';

class CharacterStatsScreen extends ConsumerStatefulWidget {
  const CharacterStatsScreen({super.key});
  static const routeName = '/stats';

  @override
  ConsumerState<CharacterStatsScreen> createState() => _CharacterStatsScreenState();
}

class _CharacterStatsScreenState extends ConsumerState<CharacterStatsScreen> {
  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showProfileEditor(context, player.name, player.classPath),
                      icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 14),
                      label: const Text('Create / Edit Profile'),
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
                      StatRow(label: 'Echo Shards', value: '${state.echoShards}'),
                      StatRow(
                        label: 'Memory Echoes',
                        value: state.unlockedEchoes.isEmpty ? 'None' : state.unlockedEchoes.join(', '),
                      ),
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

  Future<void> _showProfileEditor(
    BuildContext context,
    String currentName,
    PlayerClass currentClass,
  ) async {
    final nameController = TextEditingController(text: currentName);
    var selectedClass = currentClass;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xEE070C0A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F5A41)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile Setup', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Bound Soul',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<PlayerClass>(
                  value: selectedClass,
                  items: PlayerClass.values
                      .map(
                        (c) => DropdownMenuItem<PlayerClass>(
                          value: c,
                          child: Text(c.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setSheetState(() => selectedClass = value);
                  },
                  decoration: const InputDecoration(labelText: 'Class'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(gameProvider.notifier).updatePlayerProfile(
                            name: nameController.text,
                            classPath: selectedClass,
                          );
                      Navigator.pop(context);
                    },
                    icon: const FaIcon(FontAwesomeIcons.check, size: 14),
                    label: const Text('Save Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    nameController.dispose();
  }
}
