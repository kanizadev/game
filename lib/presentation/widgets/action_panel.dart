import 'package:flutter/material.dart';

class ActionPanel extends StatelessWidget {
  const ActionPanel({super.key, required this.onAttack, required this.onDefend, required this.onItem, required this.onRun, required this.enabled});
  final VoidCallback onAttack;
  final VoidCallback onDefend;
  final VoidCallback onItem;
  final VoidCallback onRun;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _actionButton('Attack', Icons.gps_fixed_rounded, onAttack),
          _actionButton('Defend', Icons.shield_outlined, onDefend),
          _actionButton('Use Item', Icons.healing_rounded, onItem),
          _actionButton('Run', Icons.directions_run_rounded, onRun),
        ],
      );

  Widget _actionButton(String text, IconData icon, VoidCallback onPressed) => SizedBox(
        width: 130,
        child: ElevatedButton.icon(onPressed: enabled ? onPressed : null, icon: Icon(icon, size: 18), label: Text(text)),
      );
}
