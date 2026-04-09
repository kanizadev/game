import 'package:flutter/material.dart';

class RulebookScreen extends StatelessWidget {
  const RulebookScreen({super.key});
  static const routeName = '/rulebook';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rulebook')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050807), Color(0xFF060B08), Color(0xFF050807)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const _HeaderCard(),
            const SizedBox(height: 10),
            const _QuickReferenceCard(),
            const SizedBox(height: 10),
            const _RuleCard(
              title: 'Combat System',
              lines: [
                'Turn order: You act first, then enemy responds if alive.',
                'Actions: Attack, Defend, Skill, Item, Run, Soul Burst.',
                'Run is not guaranteed; failed escape gives enemy a free turn.',
                'Defend reduces incoming damage and stabilizes dangerous turns.',
                'Soul Burst is strongest when used on elite/boss turns or near lethal thresholds.',
              ],
            ),
            const _RuleCard(
              title: 'Status Effects and Combo',
              lines: [
                'Burn: deals damage at turn ticks.',
                'Regen: restores HP at turn ticks.',
                'Shield: lowers incoming pressure for short windows.',
                'Weaken: lowers outgoing damage from the affected target.',
                'Consecutive offensive pressure builds combo; combo amplifies tempo and control.',
              ],
            ),
            const _RuleCard(
              title: 'Enemy Intent and AI Patterns',
              lines: [
                'Enemies telegraph behavior through intent states (attack, guard, siphon, overclock).',
                'Elites and bosses gain pattern turns that spike pressure.',
                'Siphon-style enemies can recover HP from successful hits.',
                'When intent becomes dangerous, prioritize Defend, Item timing, or Burst denial.',
              ],
            ),
            const _RuleCard(
              title: 'Progression and Build Identity',
              lines: [
                'Victory grants XP and gold.',
                'Leveling increases core stats and grants skill points.',
                'Class path defines growth curve and playstyle focus.',
                'Starter skill unlocks create early build identity; relics then specialize further.',
              ],
            ),
            const _RuleCard(
              title: 'Loop Knowledge and Story Power',
              lines: [
                'Death restarts the loop but not your understanding.',
                'Story choices can change Keeper alignment and set memory flags.',
                'Memory flags unlock new branches and altered outcomes in future loops.',
                'Strong runs come from combining tactical combat with long-term loop decisions.',
              ],
            ),
            const _RuleCard(
              title: 'Advanced Survival Principles',
              lines: [
                'Treat HP and SOUL as tempo resources, not just survival bars.',
                'Bank Soul Burst for swing turns instead of using it on low-threat targets.',
                'Keep at least one emergency consumable before pushing rift depth.',
                'Adapt route choices to current relic set and Keeper alignment.',
                'If a loop fails, extract information: enemy intent rhythm, breakpoints, and decision value.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.title,
    required this.lines,
  });

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('> $line'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ECHOES OF THE HOLLOW REALM',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('> Die, learn, return... break the cycle.'),
            const SizedBox(height: 6),
            const Text(
              '> This rulebook explains high-value play patterns, not only basic controls.',
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReferenceCard extends StatelessWidget {
  const _QuickReferenceCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _Tag(text: 'HP=0 -> Loop Reset'),
            _Tag(text: 'Soul Burst at 100%'),
            _Tag(text: 'Defend for Threat Turns'),
            _Tag(text: 'Combo = Pressure'),
            _Tag(text: 'Memory Flags Unlock Paths'),
            _Tag(text: 'Keeper Alignment Matters'),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F5A41)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
