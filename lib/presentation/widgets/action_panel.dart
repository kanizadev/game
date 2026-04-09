import 'dart:ui';

import 'package:flutter/material.dart';

class ActionPanel extends StatelessWidget {
  const ActionPanel({
    super.key,
    required this.onAttack,
    required this.onDefend,
    required this.onItem,
    required this.onSkill,
    required this.enabled,
  });
  final VoidCallback onAttack;
  final VoidCallback onDefend;
  final VoidCallback onItem;
  final VoidCallback onSkill;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Container(
        height: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x22FFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: const Color(0x66FFFFFF)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _ActionButton(label: 'Attack', icon: Icons.gps_fixed_rounded, enabled: enabled, onPressed: onAttack),
                _ActionButton(label: 'Defend', icon: Icons.shield_outlined, enabled: enabled, onPressed: onDefend),
                _ActionButton(label: 'Skill', icon: Icons.auto_awesome, enabled: enabled, onPressed: onSkill),
                _ActionButton(label: 'Item', icon: Icons.healing_rounded, enabled: enabled, onPressed: onItem),
              ],
            ),
          ),
        ),
      );
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        scale: _pressed ? 0.95 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: const Color(0x1FFFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x66FFFFFF)),
            boxShadow: _pressed
                ? const [
                    BoxShadow(
                      color: Color(0x667C4DFF),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
              onTapCancel: () => setState(() => _pressed = false),
              onTap: widget.enabled
                  ? () {
                      setState(() => _pressed = false);
                      widget.onPressed();
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(widget.icon, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
