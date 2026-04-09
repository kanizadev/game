# Advanced Systems Roadmap

## Milestone 2 - Deep Progression and Narrative Weight

- Expand class paths from starter perks into 3-tier trees (Vanguard, Arcanist, Shade).
- Add relic synergy sets:
  - Echo Set: loop resilience and memory amplification.
  - Hollow Set: burst damage with corruption drawbacks.
  - Keeper Set: high control, alignment penalties.
- Add Keeper consequence tracks:
  - `keeper_pact` route: power-heavy, harsher loop costs.
  - `keeper_resisted` route: safer scaling, unique anti-boss options.
- Add event families that branch from `memoryFlags` and `keeperAlignment`.
- Introduce elite encounter patterns with multi-step intents and telegraphs.

## Milestone 3 - Meta Systems Layer

- Quests:
  - Daily contract board tied to day/loop count.
  - Story contracts unlocked by loop memories.
- Shop:
  - Rotating inventory by rift tier.
  - Risk/reward purchases (cursed stock at discount).
- Crafting:
  - Salvage relic fragments and enemy essences.
  - Craft deterministic upgrades with explicit trade-offs.
- Achievements:
  - Loop mastery, boss streaks, no-item clears, Keeper alignment endings.
- Save slots:
  - Multi-profile saves (`slot_1..slot_n`) with summary metadata and class/alignment preview.

## Delivery Notes

- Keep state transitions explicit in provider/service methods.
- Maintain combat readability and text-first UX.
- Preserve dark fantasy time-loop tone in new logs and events.
