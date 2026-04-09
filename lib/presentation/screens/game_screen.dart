import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  Color _damagePopupColor = const Color(0xFFB7FFD8);
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
            icon: const FaIcon(FontAwesomeIcons.boxArchive, size: 16),
          ),
          IconButton(
            onPressed: () {
              notifier.playMenuOpen();
              Navigator.pushNamed(context, CharacterStatsScreen.routeName);
            },
            icon: const FaIcon(FontAwesomeIcons.user, size: 16),
          ),
          IconButton(
            onPressed: () async {
              await notifier.saveGame();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game saved.')));
            },
            icon: const FaIcon(FontAwesomeIcons.floppyDisk, size: 16),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050807), Color(0xFF060B08), Color(0xFF050807)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _ScanlineLayer()),
            AnimatedOpacity(
              opacity: _showFlash ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                child: Container(color: _flashColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  final battleControls = state.phase == GamePhase.battle
                      ? ActionPanel(
                          enabled: state.isPlayerTurn,
                          soulBurstReady: state.player.soulBurstCharge >= 100,
                          onAttack: notifier.playerAttack,
                          onDefend: notifier.playerDefend,
                          onItem: notifier.usePotionInBattle,
                          onSkill: notifier.castSkill,
                          onRun: notifier.playerRun,
                          onSoulBurst: notifier.useSoulBurst,
                        )
                      : _buildExplorationPanel(state, notifier, context);

                  if (wide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopHud(state: state),
                        const SizedBox(height: 8),
                        _TurnBanner(state: state),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: TerminalLog(log: state.log)),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: battleControls),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopHud(state: state),
                      const SizedBox(height: 8),
                      _TurnBanner(state: state),
                      Expanded(child: TerminalLog(log: state.log)),
                      battleControls,
                    ],
                  );
                },
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
      _triggerDamagePopup('-$damage', const Color(0xFF2CFF8F));
      _triggerFlash(const Color(0x252CFF8F));
      return;
    }

    if (entry.contains('hits you')) {
      _triggerDamagePopup('-$damage', const Color(0xFFFF7575));
      _triggerFlash(const Color(0x30FF7575));
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
            color: const Color(0xEE070C0A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: const Color(0xFF1F5A41)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F5A41),
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
                      icon: const FaIcon(FontAwesomeIcons.flask, size: 14),
                      label: const Text('Use Consumable'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.inventory.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFF1F5A41)),
                  itemBuilder: (context, index) {
                    final item = state.inventory[index];
                    return ListTile(
                      leading: FaIcon(_itemIcon(item.type), size: 14, color: const Color(0xFF73FFD9)),
                      title: Text(item.name, style: const TextStyle(color: Color(0xFFB7FFD8))),
                      subtitle: Text(item.description, style: const TextStyle(color: Color(0xFF8ED2AE))),
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

  FaIconData _itemIcon(ItemType type) => switch (type) {
        ItemType.weapon => FontAwesomeIcons.handFist,
        ItemType.armor => FontAwesomeIcons.shieldHalved,
        ItemType.relic => FontAwesomeIcons.gem,
        ItemType.consumable => FontAwesomeIcons.flask,
      };

  Widget _buildExplorationPanel(
    GameState state,
    GameNotifier notifier,
    BuildContext context,
  ) {
    if (state.phase == GamePhase.gameOver) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          icon: const FaIcon(FontAwesomeIcons.house, size: 16),
          label: const Text('Return to Home'),
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 120, maxHeight: 170),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xEE070C0A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border.all(color: const Color(0xFF1F5A41)),
      ),
      child: SingleChildScrollView(
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
              icon: const FaIcon(FontAwesomeIcons.forwardStep, size: 16),
              label: const Text('Advance Day'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final text = state.phase != GamePhase.battle
        ? 'Exploration'
        : state.isPlayerTurn
            ? 'Your Turn'
            : 'Enemy Turn (${state.enemy?.intent ?? 'attack'})';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xAA0A140E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1F5A41)),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.waveSquare, size: 12, color: Color(0xFF73FFD9)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Color(0xFFB7FFD8), fontSize: 12)),
          const Spacer(),
          Text(
            'Combo x${state.comboChain}',
            style: const TextStyle(color: Color(0xFF73FFD9), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final enemy = state.enemy;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 108),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xEE070C0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1F5A41)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF2CFF8F), Color(0xFF73FFD9)]),
              ),
              child: SizedBox(
                width: 48,
                height: 48,
                child: FaIcon(
                  FontAwesomeIcons.user,
                  size: 20,
                  color: Color(0xFF031108),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${state.player.name}  Lv.${state.player.level}',
                  style: const TextStyle(
                    color: Color(0xFFB7FFD8),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                _StatBar(
                  value: state.player.currentHp / state.player.maxHp,
                  fillColor: const Color(0xFFFF7575),
                  pulseWhenLow: state.player.currentHp / state.player.maxHp <= 0.3,
                ),
                const SizedBox(height: 4),
                _StatBar(
                  value: state.player.xp / (state.player.level * 70),
                  fillColor: const Color(0xFF73FFD9),
                ),
                const SizedBox(height: 4),
                _StatBar(
                  value: state.player.currentSoul / state.player.maxSoul,
                  fillColor: const Color(0xFF2CFF8F),
                ),
              ],
            ),
          ),
          if (enemy != null)
            SizedBox(
              width: 84,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 34,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF1F5A41)),
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFF0B1B12),
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.skull,
                          size: 14,
                          color: Color(0xFFFF7575),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enemy.name,
                      style: const TextStyle(color: Color(0xFFFF7575), fontSize: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
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
        child: SizedBox(
          height: 10,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF0B1B12),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: widget.value.clamp(0, 1),
                        child: ColoredBox(color: widget.fillColor),
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

class _ScanlineLayer extends StatelessWidget {
  const _ScanlineLayer();

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Column(
          children: List.generate(
            72,
            (index) => Expanded(
              child: ColoredBox(
                color: index.isEven ? const Color(0x0800FF95) : Colors.transparent,
              ),
            ),
          ),
        ),
      );
}
