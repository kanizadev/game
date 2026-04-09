import 'package:flutter/material.dart';

class ActionPanel extends StatelessWidget {
  const ActionPanel({
    super.key,
    required this.onAttack,
    required this.onDefend,
    required this.onItem,
    required this.onSkill,
    required this.onSoulBurst,
    required this.onRun,
    required this.enabled,
    required this.soulBurstReady,
  });
  final VoidCallback onAttack;
  final VoidCallback onDefend;
  final VoidCallback onItem;
  final VoidCallback onSkill;
  final VoidCallback onSoulBurst;
  final VoidCallback onRun;
  final bool enabled;
  final bool soulBurstReady;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _actionButton('Attack', Icons.gps_fixed_rounded, onAttack),
          _actionButton('Cast Skill', Icons.auto_awesome, onSkill),
          _actionButton('Defend', Icons.shield_outlined, onDefend),
          _actionButton('Use Item', Icons.healing_rounded, onItem),
          _actionButton('Soul Burst', Icons.flash_on_rounded, onSoulBurst, overrideEnabled: enabled && soulBurstReady),
          _actionButton('Run', Icons.directions_run_rounded, onRun),
        ],
      );

  Widget _actionButton(String text, IconData icon, VoidCallback onPressed, {bool? overrideEnabled}) => SizedBox(
        width: 130,
        child: ElevatedButton.icon(
          onPressed: (overrideEnabled ?? enabled) ? onPressed : null,
          icon: Icon(icon, size: 18),
          label: Text(text),
        ),
      );
}
