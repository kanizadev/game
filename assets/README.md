# Game Assets Guide

This file lists what assets to add for **Echoes of the Hollow Realm** and how to name them.

## Folder Structure

- `assets/images/` - background and scene images
- `assets/icons/` - app and UI icons
- `assets/enemies/` - enemy sprites and portraits
- `assets/sounds/sfx/` - short sound effects
- `assets/sounds/bgm/` - looping music
- `assets/fonts/` - pixel fonts (`PixelifySans.ttf` is already configured)

## Naming Rules

- Use lowercase `snake_case` only
- Keep names descriptive and stable
- Avoid spaces and special characters
- Keep deterministic IDs where possible (`enemy_<name>_<tier>.png`)

Examples:

- `enemy_hollow_rat_common.png`
- `enemy_void_knight_elite.png`
- `bg_ruins_night.png`
- `sfx_ui_tick.wav`
- `bgm_battle_loop.mp3`

## Recommended Formats

- Images/UI/Sprites: `.png` (with transparency when needed)
- Icons: `.png` (multiple resolutions if used for launcher/export)
- SFX: `.wav` (short, clean, low-latency)
- BGM: `.mp3` or `.ogg` (loop-friendly)
- Font: `.ttf` or `.otf`

## Suggested Asset Checklist

### 1) Backgrounds (`assets/images/`)
- [ ] `bg_menu_terminal.png`
- [ ] `bg_ruins_night.png`
- [ ] `bg_battle_hollow_field.png`
- [ ] `bg_boss_abyss_gate.png`

### 2) Enemy Art (`assets/enemies/`)
- [ ] `enemy_hollow_rat_common.png`
- [ ] `enemy_shade_knight_elite.png`
- [ ] `enemy_abyss_keeper_boss.png`
- [ ] optional portraits: `enemy_<name>_portrait.png`

### 3) Icons (`assets/icons/`)
- [ ] `icon_inventory.png`
- [ ] `icon_stats.png`
- [ ] `icon_save.png`
- [ ] `icon_attack.png`
- [ ] `icon_defend.png`
- [ ] `icon_skill.png`

### 4) Sound Effects (`assets/sounds/sfx/`)
- [ ] `ui_tick.wav`
- [ ] `ui_blip.wav`
- [ ] `attack_slash.wav`
- [ ] `critical_impact.wav`
- [ ] `enemy_dark_hit.wav`
- [ ] `enemy_break.wav`
- [ ] `item_pop.wav`
- [ ] `levelup_8bit.wav`
- [ ] `gameover_glitch.wav`

### 5) Music (`assets/sounds/bgm/`)
- [ ] `exploration_loop.mp3`
- [ ] `battle_loop.mp3`
- [ ] `boss_loop.mp3`

## Audio Mixing Guidelines

- Keep audio subtle so logs and choices remain readable
- Leave headroom (target around `-14 LUFS` to `-18 LUFS` for BGM)
- Keep SFX short and avoid long tails
- Ensure BGM loops are seamless

## Add New Assets Safely

1. Drop files into the correct folder.
2. Keep names in `snake_case`.
3. If adding a new folder, include it in `pubspec.yaml` under `flutter/assets`.
4. Run `flutter pub get`.
5. Test by loading each asset at least once in UI/game flow.
