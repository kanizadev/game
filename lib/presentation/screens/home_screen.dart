import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/game_provider.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rift Terminal RPG')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1117), Color(0xFF111827), Color(0xFF0D1117)],
          ),
        ),
        child: Center(
          child: Card(
            child: SizedBox(
              width: 310,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('RIFT TERMINAL', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    Text('Enter the anomaly and survive another day.', style: TextStyle(color: Colors.grey.shade300)),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await ref.read(gameProvider.notifier).startNewGame();
                          if (!context.mounted) return;
                          Navigator.pushNamed(context, GameScreen.routeName);
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start Game'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final loaded = await ref.read(gameProvider.notifier).loadGame();
                          if (!context.mounted) return;
                          if (loaded) {
                            Navigator.pushNamed(context, GameScreen.routeName);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No save file found.')));
                          }
                        },
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Load Game'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('Settings'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
