import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
        constraints: const BoxConstraints(minHeight: 120, maxHeight: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xEE070C0A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          border: Border.all(color: const Color(0xFF1F5A41)),
        ),
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            _ActionButton(label: 'Attack', icon: FontAwesomeIcons.handFist, enabled: enabled, onPressed: onAttack),
            _ActionButton(label: 'Defend', icon: FontAwesomeIcons.shieldHalved, enabled: enabled, onPressed: onDefend),
            _ActionButton(label: 'Skill', icon: FontAwesomeIcons.burst, enabled: enabled, onPressed: onSkill),
            _ActionButton(label: 'Item', icon: FontAwesomeIcons.flask, enabled: enabled, onPressed: onItem),
          ],
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
  final FaIconData icon;
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
            color: const Color(0xFF0A140E),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF1F5A41)),
            boxShadow: _pressed
                ? const [
                    BoxShadow(
                      color: Color(0x662CFF8F),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
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
                    FaIcon(widget.icon, size: 16, color: const Color(0xFF73FFD9)),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Color(0xFFB7FFD8),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PixelifySans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
