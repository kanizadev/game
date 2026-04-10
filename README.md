# Echoes of the Hollow Realm

A dark fantasy, text-first, turn-based RPG built with Flutter + Riverpod.

**Tagline:** _Die, learn, return... break the cycle._

## Non-Negotiable Identity

The core pillar of this game is:

**Every death changes future runs in meaningful, visible ways.**

If this is not felt within 2-3 loops, the design is considered off-target.

## Game Overview

`Echoes of the Hollow Realm` is a loop-based RPG where each run pushes deeper into a fractured rift.  
You explore through narrative choices, fight tactical turn-based battles, and shape future loops through memory flags and Keeper alignment.

The game is built to feel readable and responsive: strong terminal-style logs, clear combat intents, and meaningful decisions with trade-offs.

## Core Gameplay Loop

1. Start or load a run.
2. Enter **exploration phase** and choose story actions.
3. Advance day/beat and trigger events or encounters.
4. Enter **battle phase** when enemies appear.
5. Win for XP/gold/rift progression, or die and re-enter a stronger knowledge loop.

Every day and encounter is intended to teach something: enemy rhythm, route value, or build direction.

## Combat System

Combat is turn-based with a clear action panel:

- `Attack` - primary damage action, supports combo pressure.
- `Defend` - reduces incoming pressure and stabilizes dangerous turns.
- `Skill` - SOUL-powered action with stronger tactical effect.
- `Item` - consume healing resources.
- `Run` - chance-based escape.
- `Soul Burst` - high-impact action when fully charged.

Enemies use intent-driven behavior (`attack`, `guard`, `siphon`, `overclock` patterns via AI profile), and elites/bosses increase pressure at higher rift levels.

## Progression Systems

- **Player stats:** HP, SOUL, Attack, Defense, Luck, Level, XP, Gold.
- **Class paths:** `Vanguard`, `Arcanist`, `Shade`.
- **Skill unlock flow:** class-based unlocks at early levels.
- **Inventory types:** weapon, armor, consumable, relic.
- **Rift progression:** victory increases `riftLevel`.
- **Loop progression:** death restarts with loop growth and memory carryover rules.

## Narrative State and Choice Impact

Exploration choices influence long-term outcomes through:

- `memoryFlags` (example: Keeper marks/pacts/resistance)
- `keeperAlignment` (moral pressure and route shaping)
- story beat progression and branching choice sets

This supports replayability across loops while maintaining a consistent dark-fantasy tone.

## Current UX Features

- Splash intro with typing effect
- Home, Game, Profile, Inventory, Rulebook, and Settings flows
- Bottom navigation in game (`Profile`, `Inventory`, `Settings`)
- Inline hint panel with `Show Hint / Hide Hint`
- Auto Advance option in exploration
- Battle/exploration HUD with day/rift/loop visibility
- Save icon for explicit save, plus autosave on key progression events

## Player Profile

Players can create/edit profile data from the profile screen:

- character name
- class path selection

Profile updates are persisted in game state and saved locally.

## Save and Load

- Local persistence uses `shared_preferences`.
- Use **Start Game** for a fresh session.
- Use **Load Game** to continue.
- In-game save button forces a manual save.
- Important progression actions trigger autosave.

## Project Structure

- `lib/core` - app theming and visual style setup
- `lib/domain/models` - core data models (`GameState`, `Player`, `Enemy`, `Item`)
- `lib/domain/services` - combat, enemy AI, random events, level logic, status effects, sound
- `lib/data/local` - local save service
- `lib/application/providers` - `GameNotifier` state orchestration (Riverpod)
- `lib/presentation/screens` - screen-level UI
- `lib/presentation/widgets` - reusable UI components

## Run the Project

1. Install Flutter (stable channel)
2. From project root:
   - `flutter pub get`
   - `flutter run`

## Roadmap

Planned advanced systems are tracked in `ADVANCED_ROADMAP.md`, including deeper class trees, relic synergy sets, Keeper consequence tracks, quests, crafting, achievements, and multi-slot saves.

## Polish Direction (Execution Order)

Use this sequence to keep depth ahead of content bloat:

### Phase 1 - Core Depth

- Expand status-effect interactions (clear logs + strong tactical impact)
- Add at least 10 meaningful relics with explicit trade-offs
- Improve enemy behavior into multi-phase pressure patterns

### Phase 2 - Strategic Structure

- Introduce lightweight node/path exploration per day (battle/event/shop/elite)
- Add shop + economy balancing loops
- Redesign at least 1 elite and 1 boss for stronger identity

### Phase 3 - Identity Systems

- Build a 3-layer memory meta system:
  - **Memory Echoes** (permanent progression bonuses)
  - **World State Changes** (dialogue/routes/boss behavior reactions)
  - **Corruption** (high power with meaningful drawbacks)
- Expand reactive narrative callbacks by class, alignment, and memory history

### Phase 4 - Presentation Polish

- Tighten combat feedback (impact lines, status clarity, enemy reaction text)
- Increase intent readability (forecasted threats, not generic labels)
- Standardize terminology and spacing across combat logs and UI
- Run balance tuning across 3-5 full loops per class archetype

### Practical Rule

- Adding more enemies/items/screens alone creates a bigger prototype.
- Deepening interaction, feedback, and system synergy creates a polished game.
