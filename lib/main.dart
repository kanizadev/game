import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/character_stats_screen.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/inventory_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: RiftTextRpgApp()));
}

class RiftTextRpgApp extends StatelessWidget {
  const RiftTextRpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rift Terminal RPG',
      theme: AppTheme.darkTheme,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        GameScreen.routeName: (_) => const GameScreen(),
        InventoryScreen.routeName: (_) => const InventoryScreen(),
        CharacterStatsScreen.routeName: (_) => const CharacterStatsScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
    );
  }
}
