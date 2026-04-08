import 'package:flutter/material.dart';

class TerminalLog extends StatelessWidget {
  const TerminalLog({required this.log, super.key});
  final List<String> log;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF111827), Color(0xFF0F172A)]),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: ListView.builder(
        reverse: true,
        itemCount: log.length,
        itemBuilder: (context, index) {
          final entry = log[log.length - 1 - index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(entry, style: const TextStyle(height: 1.35)),
          );
        },
      ),
    );
  }
}
