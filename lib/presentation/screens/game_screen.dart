import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../application/providers/game_provider.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/item.dart';
import '../widgets/action_panel.dart';
import '../widgets/terminal_log.dart';
import 'character_stats_screen.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});
  static const routeName = '/game';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rift Session'),
        actions: [
          IconButton(
            onPressed: () => _showInventoryModal(context, state, notifier),
            icon: const Icon(Icons.backpack_outlined),
          ),
          IconButton(onPressed: () => Navigator.pushNamed(context, CharacterStatsScreen.routeName), icon: const Icon(Icons.person_outline)),
          IconButton(
            onPressed: () async {
              await notifier.saveGame();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game saved.')));
            },
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF0D0D0D),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopHud(state: state),
              Expanded(child: TerminalLog(log: state.log)),
              if (state.phase == GamePhase.battle)
                ActionPanel(
                  enabled: state.isPlayerTurn,
                  onAttack: notifier.playerAttack,
                  onDefend: notifier.playerDefend,
                  onItem: notifier.usePotionInBattle,
                  onSkill: notifier.castSkill,
                )
              else if (state.phase == GamePhase.gameOver)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Return to Home'),
                  ),
                )
              else
                Container(
                  height: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...state.choices.map(
                        (choice) => ElevatedButton(
                          onPressed: () => notifier.chooseStoryOption(choice.id),
                          child: Text(choice.text),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: notifier.advanceTurnDay,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Advance Day'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showInventoryModal(
    BuildContext context,
    GameState state,
    GameNotifier notifier,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.6,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text('Inventory', style: GoogleFonts.jetBrainsMono(fontSize: 16, color: Colors.white)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: notifier.usePotionOutsideBattle,
                      icon: const Icon(Icons.healing),
                      label: const Text('Use Consumable'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.inventory.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFF333333)),
                  itemBuilder: (context, index) {
                    final item = state.inventory[index];
                    return ListTile(
                      leading: Icon(_itemIcon(item.type), color: const Color(0xFF7C4DFF)),
                      title: Text(item.name, style: const TextStyle(color: Color(0xFFE0E0E0))),
                      subtitle: Text(item.description, style: const TextStyle(color: Color(0xFFB0B0B0))),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _itemIcon(ItemType type) => switch (type) {
        ItemType.weapon => Icons.gpp_good_outlined,
        ItemType.armor => Icons.shield_outlined,
        ItemType.relic => Icons.auto_awesome,
        ItemType.consumable => Icons.healing_rounded,
      };
}

class _TopHud extends StatelessWidget {
  const _TopHud({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final enemy = state.enemy;
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF2196F3)]),
              ),
              child: SizedBox(width: 48, height: 48, child: Icon(Icons.person, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.player.name}  Lv.${state.player.level}',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                _StatBar(
                  value: state.player.currentHp / state.player.maxHp,
                  fillColor: const Color(0xFFFF4D4D),
                ),
                const SizedBox(height: 6),
                _StatBar(
                  value: state.player.xp / (state.player.level * 70),
                  fillColor: const Color(0xFFFFD54F),
                ),
                const SizedBox(height: 6),
                _StatBar(
                  value: state.player.currentSoul / state.player.maxSoul,
                  fillColor: const Color(0xFF4FC3F7),
                ),
              ],
            ),
          ),
          if (enemy != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                enemy.name,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFFFF5252),
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.value,
    required this.fillColor,
  });

  final double value;
  final Color fillColor;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 8,
          child: Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFF333333)),
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0, 1),
                child: ColoredBox(color: fillColor),
              ),
            ],
          ),
        ),
      );
}
