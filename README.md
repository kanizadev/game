# Rift Terminal RPG (Flutter)

A complete text-based RPG mobile app built with Flutter and Riverpod.

## Included Features
- Terminal/chat style interface with story log
- Splash, Home, Game, Inventory, Character Stats, and Settings screens
- Turn-based combat (Attack, Defend, Use Item, Run)
- Random enemy encounters and story choices
- Player progression (HP, XP, Level, Gold)
- Inventory with weapons and potions
- Save/load game via local storage (`shared_preferences`)
- Optional simple sound effect toggle
- Typing animation on splash intro

## Architecture
- `lib/core`: theme and global UI settings
- `lib/domain/models`: `Player`, `Enemy`, `Item`, `GameState`
- `lib/domain/services`: battle, random events, leveling logic
- `lib/data/local`: persistence service
- `lib/application/providers`: Riverpod game state controller
- `lib/presentation/screens`: app screens
- `lib/presentation/widgets`: reusable UI widgets

## How to Run
1. Install Flutter SDK (stable channel).
2. From project root run:
   - `flutter pub get`
   - `flutter run`

## Notes
- Use `Start Game` for a fresh session.
- Use `Load Game` to continue saved progress.
- Use save icon in the Game screen app bar to store progress.
