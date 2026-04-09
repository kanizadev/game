import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/game_provider.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/item.dart';
import '../widgets/action_panel.dart';
import '../widgets/terminal_log.dart';
import 'character_stats_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});
  static const routeName = '/game';

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int _observedLogLength = 0;
  String? _damagePopupText;
  Color _damagePopupColor = const Color(0xFFE0E0E0);
  bool _showDamagePopup = false;
  Color _flashColor = Colors.transparent;
  bool _showFlash = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(gameProvider);
    _observedLogLength = state.log.length;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    _handleNewLogEntries(state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Echoes of the Hollow Realm'),
        actions: [
          IconButton(
            onPressed: () {
              notifier.playMenuOpen();
              _showInventoryModal(context, state, notifier);
            },
            icon: const Icon(Icons.backpack_outlined),
          ),
          IconButton(
            onPressed: () {
              notifier.playMenuOpen();
              Navigator.pushNamed(context, CharacterStatsScreen.routeName);
            },
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            onPressed: () async {
              await notifier.saveGame();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game saved.')));
            },
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E1A), Color(0xFF121528), Color(0xFF0B1020)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _AmbientParticleLayer()),
            AnimatedOpacity(
              opacity: _showFlash ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                child: Container(color: _flashColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopHud(state: state),
                  Expanded(child: TerminalLog(log: state.log)),
                  if (state.phase == GamePhase.battle)
                    ActionPanel(
                      enabled: state.isPlayerTurn,
                      onAttack: notifier.playerAttack,
                      onDefend: notifier.playerDefend,
                      onItem: notifier.usePotionInBattle,
                      onSkill: notifier.castSkill,
                    )
                  else if (state.phase == GamePhase.gameOver)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Return to Home'),
                      ),
                    )
                  else
                    Container(
                      height: 140,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0x22FFFFFF),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        border: Border.all(color: const Color(0x66FFFFFF)),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...state.choices.map(
                            (choice) => ElevatedButton(
                              onPressed: () => notifier.chooseStoryOption(choice.id),
                              child: Text(choice.text),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: notifier.advanceTurnDay,
                            icon: const Icon(Icons.skip_next),
                            label: const Text('Advance Day'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 140,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  offset: _showDamagePopup ? Offset.zero : const Offset(0, -0.2),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: _showDamagePopup ? 1 : 0,
                    child: Center(
                      child: Text(
                        _damagePopupText ?? '',
                        style: TextStyle(
                          color: _damagePopupColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          shadows: const [
                            Shadow(color: Color(0xAA000000), blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNewLogEntries(GameState state) {
    if (state.log.length <= _observedLogLength) return;
    final newEntries = state.log.sublist(_observedLogLength);
    _observedLogLength = state.log.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final entry in newEntries) {
        _processLogEntryForFx(entry);
      }
    });
  }

  void _processLogEntryForFx(String entry) {
    final damageMatch = RegExp(r'for (\d+) damage').firstMatch(entry);
    if (damageMatch == null) return;
    final damage = damageMatch.group(1);
    if (damage == null) return;

    if (entry.contains('You strike') ||
        entry.contains('Soul Fire') ||
        entry.contains('Soul Burst') ||
        entry.contains('CRITICAL')) {
      _triggerDamagePopup('-$damage', const Color(0xFF4CAF50));
      _triggerFlash(const Color(0x334FC3F7));
      return;
    }

    if (entry.contains('hits you')) {
      _triggerDamagePopup('-$damage', const Color(0xFFFF5252));
      _triggerFlash(const Color(0x44FF5252));
    }
  }

  void _triggerDamagePopup(String text, Color color) {
    setState(() {
      _damagePopupText = text;
      _damagePopupColor = color;
      _showDamagePopup = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 520), () {
      if (!mounted) return;
      setState(() => _showDamagePopup = false);
    });
  }

  void _triggerFlash(Color color) {
    setState(() {
      _flashColor = color;
      _showFlash = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 160), () {
      if (!mounted) return;
      setState(() => _showFlash = false);
    });
  }

  Future<void> _showInventoryModal(
    BuildContext context,
    GameState state,
    GameNotifier notifier,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x22FFFFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: const Color(0x66FFFFFF)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(
                      'Inventory',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        notifier.playUiClick();
                        notifier.usePotionOutsideBattle();
                      },
                      icon: const Icon(Icons.healing),
                      label: const Text('Use Consumable'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.inventory.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFF333333)),
                  itemBuilder: (context, index) {
                    final item = state.inventory[index];
                    return ListTile(
                      leading: Icon(_itemIcon(item.type), color: const Color(0xFF7C4DFF)),
                      title: Text(item.name, style: const TextStyle(color: Color(0xFFE0E0E0))),
                      subtitle: Text(item.description, style: const TextStyle(color: Color(0xFFB0B0B0))),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _itemIcon(ItemType type) => switch (type) {
        ItemType.weapon => Icons.gpp_good_outlined,
        ItemType.armor => Icons.shield_outlined,
        ItemType.relic => Icons.auto_awesome,
        ItemType.consumable => Icons.healing_rounded,
      };
}

class _TopHud extends StatelessWidget {
  const _TopHud({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final enemy = state.enemy;
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x22FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x66FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF2196F3)]),
              ),
              child: SizedBox(width: 48, height: 48, child: Icon(Icons.person, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.player.name}  Lv.${state.player.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                _StatBar(
                  value: state.player.currentHp / state.player.maxHp,
                  fillColor: const Color(0xFFFF4D4D),
                  pulseWhenLow: state.player.currentHp / state.player.maxHp <= 0.3,
                ),
                const SizedBox(height: 6),
                _StatBar(
                  value: state.player.xp / (state.player.level * 70),
                  fillColor: const Color(0xFFFFD54F),
                ),
                const SizedBox(height: 6),
                _StatBar(
                  value: state.player.currentSoul / state.player.maxSoul,
                  fillColor: const Color(0xFF4FC3F7),
                ),
              ],
            ),
          ),
          if (enemy != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                enemy.name,
                style: const TextStyle(color: Color(0xFFFF5252), fontSize: 11),
              ),
            ),
        ],
          ),
        ),
      ),
    );
  }
}

class _StatBar extends StatefulWidget {
  const _StatBar({
    required this.value,
    required this.fillColor,
    this.pulseWhenLow = false,
  });

  final double value;
  final Color fillColor;
  final bool pulseWhenLow;

  @override
  State<_StatBar> createState() => _StatBarState();
}

class _StatBarState extends State<_StatBar> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.65,
      upperBound: 1,
    );
    if (widget.pulseWhenLow) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _StatBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulseWhenLow && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.pulseWhenLow && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 1;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) => DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: widget.pulseWhenLow
                ? [
                    BoxShadow(
                      color: widget.fillColor.withValues(alpha: 0.34 * _pulseController.value),
                      blurRadius: 12 * _pulseController.value,
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 8,
          child: Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFF333333)),
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeInOut,
                alignment: Alignment.centerLeft,
                widthFactor: widget.value.clamp(0, 1),
                child: ColoredBox(color: widget.fillColor),
              ),
            ],
          ),
        ),
      ),
      );
}

class _AmbientParticleLayer extends StatelessWidget {
  const _AmbientParticleLayer();

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Stack(
          children: const [
            Positioned(
              top: 80,
              left: -40,
              child: _GlowOrb(size: 140, color: Color(0x337C4DFF)),
            ),
            Positioned(
              top: 260,
              right: -30,
              child: _GlowOrb(size: 110, color: Color(0x224FC3F7)),
            ),
            Positioned(
              bottom: 120,
              left: 30,
              child: _GlowOrb(size: 90, color: Color(0x22FFFFFF)),
            ),
          ],
        ),
      );
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.6, end: 1),
        duration: const Duration(milliseconds: 2400),
        curve: Curves.easeInOut,
        onEnd: () {},
        builder: (context, value, _) => Opacity(
          opacity: value * 0.8,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color, Colors.transparent],
              ),
            ),
          ),
        ),
      );
}
