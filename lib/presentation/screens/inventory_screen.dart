import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../application/providers/game_provider.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});
  static const routeName = '/inventory';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1117), Color(0xFF111827)],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: state.inventory.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = state.inventory[index];
            final icon = switch (item.type) {
              _ when item.type.name == 'weapon' => FontAwesomeIcons.handFist,
              _ when item.type.name == 'armor' => FontAwesomeIcons.shieldHalved,
              _ when item.type.name == 'relic' => FontAwesomeIcons.gem,
              _ => FontAwesomeIcons.flask,
            };
            return Card(
              child: ListTile(
                leading: FaIcon(icon, size: 15),
                title: Text(item.name),
                subtitle: Text(item.description),
                trailing: Text(item.type.name.toUpperCase()),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.read(gameProvider.notifier).usePotionOutsideBattle(),
        label: const Text('Use Consumable'),
        icon: const FaIcon(FontAwesomeIcons.flask, size: 15),
      ),
    );
  }
}
