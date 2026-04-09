import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/game_provider.dart';
import '../widgets/typing_text.dart';
import 'game_screen.dart';
import 'home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  static const routeName = '/';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final loaded = await ref.read(gameProvider.notifier).loadGame();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, loaded ? GameScreen.routeName : HomeScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: TypingText(text: 'ECHOES OF THE HOLLOW REALM v1.0\\nInitializing...\\n', speed: Duration(milliseconds: 30)),
        ),
      );
}
