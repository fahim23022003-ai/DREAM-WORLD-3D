# Dream World 3D — project status

## Implemented

- Phase 1B pastel living room, modular procedural avatar, movement/orbit/collision, sofa seating, menus and pause.
- Phase 1C: optional 24-character plain-text name; six hair/outfit swatches and built-in HSV wheel; live 3D preview with Apply/Cancel.
- Independent rug/cushion/curtain presets and whole-theme preview: Rosewater, Mint Morning, unlockable `lavender_dream`.
- Reachable coffee-table card box; one range/facing/visibility resolver owns both the prompt and E action. E still stands when seated.
- Cozy Pairs: shuffled 4×3 six-pair board, original local icon art, brief flips, matched states, move/pair counters, Restart and Exit.
- First legitimate win unlocks Lavender Dream once; Apply to My Room or defer; optional replays update personal best.
- Small dismissible contextual hints, short notices, six original local PCM UI cues, persisted volume/mute.
- One session state owns input: MENU / PLAY / PAUSE / PERSONALIZE / DECOR / PUZZLE. Panels may open while seated and preserve the seat.

- Phase 1D: E switches the existing floor lamp, opens/closes the curtains and waters the left houseplant. Local light and fabric transitions are reversible; watering reuses a short effect pool.
- Optional “Make a cozy corner” hint (H): lamp on, curtains closed, plant watered once. Completion permanently adds a miniature house keepsake to the bookshelf.
- Reward Retry Save appears only after failure and disappears after recovery. Decor distinguishes selected/focused/locked choices and reports Mixed whole-room palettes.

## Actual extension points

- Appearance dictionary (`display_name`, `hair`, `accent`) → `avatar.apply_appearance(data)`. Explicit instance-local channels retain texture/roughness; cached materials never change.
- Stable IDs in `style_data.gd`: `living_room.rug`, `living_room.sofa_cushions`, `living_room.curtains`; `room.apply_decor(data)` changes surfaces without rebuilding meshes/collision.
- `pairs_rules.gd` owns rules; `cozy_pairs.gd` owns presentation/timers. A single `{puzzle_id: "cozy_pairs", moves: N}` completion reaches `main.puzzle_completed()` for validation, reward and persistence. The puzzle does not touch room nodes or save files.
- `main.gd` owns session/UI state, confirmed data and progression. Preview drafts belong to `personal_decor.gd`, not the save object.

- Room controls use stable IDs `living_room.floor_lamp`, `living_room.curtains`, `living_room.houseplant`; `apply_state` restores settled visuals, `capture_state` captures booleans. Explicit dispatch rejects unsupported interaction IDs.

## Save version and safety

Schema **3**, extending `user://rosewater.cfg`. Migration retains an exact `.v1.bak` or `.v2.bak` according to the previous schema.
Atomic temporary writes retain a `.last_good` file and preserve unknown config fields. Malformed new values receive defaults;
a corrupt whole file may recover last-good data but blocks automatic overwrite. Future schemas are protected from downgrade.
Only confirmed appearance/decor, earned unlock/best, settings, guidance, settled room targets and the permanent cozy-corner flag persist. Temporary animation progress and water effects never persist. Unfinished puzzle rounds do **not** persist.
Real saves are never used as test fixtures; tests inject paths and use separate XDG user-data roots.

## Deferred roadmap

Authored avatar/rig improvements, more hairstyles, multiple profiles/homes, furniture placement, extra rooms/floors and more mini-games.
No stubs, shops, currencies, daily systems, network services or retention claims were added.

## Known limits and latest evidence

Procedural art remains below the premium reference target; no baked bounce/AO or production character rig. One short puzzle is not hours of content.
Audio resources decode and run through the cloud dummy driver; audible playback is not verified. Windows export/benchmarking is a separate task.
Current evidence: [`review/phase1d/RESULTS.md`](review/phase1d/RESULTS.md). Prior phase reviews remain available.
Open `project.godot` in Godot 4.6.x, F5; C personalizes, B decorates, E interacts, H toggles the optional cozy hint, Esc closes the top UI or pauses.
