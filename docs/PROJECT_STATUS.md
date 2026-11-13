# Dream World 3D — project status

## Implemented

- Phase 1B pastel living room, modular procedural avatar, movement/orbit/collision, sofa seating, menus and pause.
- Phase 1C: optional 24-character plain-text name; six hair/outfit swatches and built-in HSV wheel; live 3D preview with Apply/Cancel.
- Independent rug/cushion/curtain presets and whole-theme preview: Rosewater, Mint Morning, unlockable `lavender_dream`.
- Reachable coffee-table card box; one range/facing/visibility resolver owns both the prompt and E action. E still stands when seated.
- Cozy Pairs: shuffled 4×3 six-pair board, original local icon art, brief flips, matched states, move/pair counters, Restart and Exit.
- First legitimate win unlocks Lavender Dream once; Apply to My Room or defer; optional replays update personal best.
- Small dismissible contextual hints, short notices, fourteen original local PCM UI/interaction cues, persisted volume/mute.
- One session state owns input: MENU / PLAY / PAUSE / PERSONALIZE / DECOR / PUZZLE / HOME. Panels may open while seated and preserve the seat.

- Phase 1D: E switches the existing floor lamp, opens/closes the curtains and waters the left houseplant. Local light and fabric transitions are reversible; watering reuses a short effect pool.
- Optional “Make a cozy corner” hint (H): lamp on, curtains closed, plant watered once. Completion permanently adds a miniature house keepsake to the bookshelf.
- Reward Retry Save appears only after failure and disappears after recovery. Decor distinguishes selected/focused/locked choices and reports Mixed whole-room palettes.

- Phase 2A: physically connected furnished kitchen and bedroom, collision through real doorways, working bedside lamp, make-bed and rest actions.
- Three recipes: Cloud Pancakes (whisk/flip), Berry Cupcakes (butter/flour/berries then bake), Starry Vegetable Soup (carrot/greens/star pasta then stir/season). Free supplies, explicit station sequence, input-based quality, distinct 3D ingredients/preparation/cookware/finished dishes, contained steam and procedural avatar gestures.
- Event-driven Morning/Afternoon/Evening/Night atmosphere and sleep-to-next-day transition. No real-time waiting or survival meters.
- Q: three automatic-reward daily goals selected from thirteen real objectives across seven rotating combinations. Coins: 3 per goal +6 per set, 6/2/0 meal coins per recipe/day. Stable receipts, claimed state and atomic transactions prevent duplicate rewards.
- J or Decor's catalog button: six permanent purchasable finishes across four visible kitchen/bedroom channels. Free 3D preview, distinct ownership/affordability/equipment state, safe Buy & equip and free re-equipping.
- My First Cozy Week: three completed daily sets earn an amber bedside keepsake (+10 coins); seven earn a seven-star wall frame (+20). Skipping days cannot earn these rewards. Goals and recipes continue after Day 7; this is a bounded foundation, not an endless-content claim.
- Contextual, skippable first-day guidance, station prompts and input hints; older saves skip the new-player recipe introduction.

## Actual extension points

- Appearance dictionary (`display_name`, `hair`, `accent`) → `avatar.apply_appearance(data)`. Explicit instance-local channels retain texture/roughness; cached materials never change.
- Stable IDs in `style_data.gd`: `living_room.rug`, `living_room.sofa_cushions`, `living_room.curtains`; `room.apply_decor(data)` changes surfaces without rebuilding meshes/collision.
- `pairs_rules.gd` owns rules; `cozy_pairs.gd` owns presentation/timers. A single `{puzzle_id: "cozy_pairs", moves: N}` completion reaches `main.puzzle_completed()` for validation, reward and persistence. The puzzle does not touch room nodes or save files.
- `main.gd` owns session/UI state, confirmed data and progression. Preview drafts belong to `personal_decor.gd`, not the save object.

- Room controls use stable IDs `living_room.floor_lamp`, `living_room.curtains`, `living_room.houseplant`; `apply_state` restores settled visuals, `capture_state` captures booleans. Explicit dispatch rejects unsupported interaction IDs.

- `home_rules.gd`: data-driven recipe/catalog/goal definitions and persistent day/economy rules. `cooking_rules.gd`: transient timing/ingredient state and quality scoring. `home_controller.gd`: physical station dispatch, modal journey and one rollback-capable economic commit path. `home_panel.gd`: presentation only. `home_rooms.gd`: furnished geometry, palette channels, food feedback and controlled lighting.
- New stable station IDs: `kitchen.fridge`, `kitchen.prep`, `kitchen.stove`, `bedroom.bed`, `bedroom.make`, `bedroom.lamp`, `bedroom.rest`. These use the existing visibility/facing/range resolver. New room traversal uses the existing player and spring arm.

## Save version and safety

Schema **4**, extending `user://rosewater.cfg`. Migration retains an exact `.v1.bak`, `.v2.bak` or `.v3.bak` according to the previous schema.
Atomic temporary writes retain a `.last_good` file and preserve unknown config fields. Malformed new values receive defaults;
a corrupt whole file may recover last-good data but blocks automatic overwrite. Future schemas are protected from downgrade.
Only confirmed appearance/decor, earned unlock/best, settings, guidance, settled room targets and the permanent cozy-corner flag persist. Day/period, coin balance, ownership/equipment, daily claims/receipts, completed-day/milestone records, bed and bedside-light state also persist. Temporary cooking, animation progress and water effects never persist. Failed economic writes roll back currency and ownership together; pending plated meals can retry. Unfinished puzzle rounds do **not** persist.
Real saves are never used as test fixtures; tests inject paths and use separate XDG user-data roots.

## Deferred roadmap

Authored avatar/rig improvements, more hairstyles, multiple profiles/homes, furniture placement, more rooms/floors/recipes, NPCs/relationships, visitors, pets, careers and hobbies.
No unused frameworks for these future systems, network services or retention claims were added.

## Known limits and latest evidence

Procedural art remains below the premium reference target; no baked bounce/AO or production character rig. The mirror uses a reflective material, not a real-time reflection viewport. New gestures are procedural reaches, not a production animation rig. Recipes share a forgiving timing foundation with different ingredient actions and cookware; the daily combination sequence repeats weekly.
Audio resources decode and run through the cloud dummy driver; audible playback is not verified. Windows export/benchmarking is a separate task.
Current evidence: [`review/phase2a/RESULTS.md`](review/phase2a/RESULTS.md). Prior phase reviews remain available.
Open `project.godot` in Godot 4.6.x, F5; C personalizes, B decorates, E interacts, H toggles the optional cozy hint, Q opens daily goals, J opens the compact catalog, Esc closes the top UI or pauses.
