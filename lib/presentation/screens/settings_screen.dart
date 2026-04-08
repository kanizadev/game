import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/game_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1117), Color(0xFF111827)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: SwitchListTile(
                title: const Text('Enable simple beep effects'),
                subtitle: const Text('Uses platform click sound for combat events.'),
                value: state.soundEnabled,
                onChanged: (value) => ref.read(gameProvider.notifier).toggleSound(value),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(gameProvider.notifier).clearSave();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save data deleted.')));
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Save Data'),
            ),
          ],
        ),
      ),
    );
  }
}
