import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/game_provider.dart';
import '../../domain/models/game_state.dart';
import '../widgets/action_panel.dart';
import '../widgets/terminal_log.dart';
import 'character_stats_screen.dart';
import 'inventory_screen.dart';

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
          IconButton(onPressed: () => Navigator.pushNamed(context, InventoryScreen.routeName), icon: const Icon(Icons.backpack_outlined)),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1117), Color(0xFF111827), Color(0xFF0D1117)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopHud(state: state),
              const SizedBox(height: 10),
              Expanded(child: TerminalLog(log: state.log)),
              const SizedBox(height: 12),
              if (state.phase == GamePhase.battle)
                ActionPanel(
                  enabled: state.isPlayerTurn,
                  soulBurstReady: state.player.soulBurstCharge >= 100,
                  onAttack: notifier.playerAttack,
                  onDefend: notifier.playerDefend,
                  onItem: notifier.usePotionInBattle,
                  onSkill: notifier.castSkill,
                  onSoulBurst: notifier.useSoulBurst,
                  onRun: notifier.playerRun,
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...state.choices.map((choice) => ElevatedButton(onPressed: () => notifier.chooseStoryOption(choice.id), child: Text(choice.text))),
                    ElevatedButton.icon(onPressed: notifier.advanceTurnDay, icon: const Icon(Icons.skip_next), label: const Text('Advance Day')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final enemy = state.enemy;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF111827), Color(0xFF1F2937)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SESSION HUD', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Text(
            'Loop ${state.loopCount} | Day ${state.day} | Rift ${state.riftLevel} | HP ${state.player.currentHp}/${state.player.maxHp} | '
            'SOUL ${state.player.currentSoul}/${state.player.maxSoul} | Burst ${state.player.soulBurstCharge}%',
          ),
          Text('LVL ${state.player.level} | XP ${state.player.xp} | Gold ${state.player.gold} | LUCK ${state.player.luck}'),
          if (enemy != null) Text('Enemy: ${enemy.name} (${enemy.currentHp}/${enemy.maxHp} HP)'),
        ],
      ),
    );
  }
}
