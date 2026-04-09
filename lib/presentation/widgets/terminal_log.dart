import 'package:flutter/material.dart';

import 'typing_text.dart';

class TerminalLog extends StatefulWidget {
  const TerminalLog({required this.log, super.key});
  final List<String> log;

  @override
  State<TerminalLog> createState() => _TerminalLogState();
}

class _TerminalLogState extends State<TerminalLog> {
  final ScrollController _controller = ScrollController();

  @override
  void didUpdateWidget(covariant TerminalLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.log.length != widget.log.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_controller.hasClients) return;
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        border: Border.all(color: const Color(0xFF333333)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        controller: _controller,
        itemCount: widget.log.length,
        itemBuilder: (context, index) {
          final entry = widget.log[index];
          final color = _resolveColor(entry);
          final style = TextStyle(
            height: 1.35,
            color: color,
            fontFamily: 'monospace',
            fontSize: 13,
          );
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) => Opacity(opacity: value, child: child),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: index == widget.log.length - 1
                  ? TypingText(text: entry, style: style)
                  : Text(entry, style: style),
            ),
          );
        },
      ),
    );
  }

  Color _resolveColor(String entry) {
    final lower = entry.toLowerCase();
    if (lower.contains('you') || lower.contains('player') || lower.contains('soul burst')) {
      return const Color(0xFF4CAF50);
    }
    if (lower.contains('enemy') ||
        lower.contains('rat') ||
        lower.contains('shade') ||
        lower.contains('king') ||
        lower.contains('devourer') ||
        lower.contains('keeper')) {
      return const Color(0xFFFF5252);
    }
    if (lower.contains('loop') ||
        lower.contains('system') ||
        lower.contains('save') ||
        lower.contains('level up')) {
      return const Color(0xFFBB86FC);
    }
    return const Color(0xFFE0E0E0);
  }
}
