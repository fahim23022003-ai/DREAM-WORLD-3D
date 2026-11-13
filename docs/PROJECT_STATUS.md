# Dream World 3D — project status

## Implemented

- Phase 1B pastel living room, modular procedural avatar, movement/orbit/collision, sofa seating, menus and pause.
- Phase 1C: optional 24-character plain-text name; six hair/outfit swatches and built-in HSV wheel; live 3D preview with Apply/Cancel.
- Independent rug/cushion/curtain presets and whole-theme preview: Rosewater, Mint Morning, unlockable `lavender_dream`.
- Reachable coffee-table card box; one range/facing/visibility resolver owns both the prompt and E action. E still stands when seated.
- Cozy Pairs: shuffled 4×3 six-pair board, original local icon art, brief flips, matched states, move/pair counters, Restart and Exit.
- First legitimate win unlocks Lavender Dream once; Apply to My Room or defer; optional replays update personal best.
- Small dismissible contextual hints, short notices, thirty original local PCM UI/interaction cues, persisted volume/mute.
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

- Phase 2B: a physical east-side garden entrance, pastel paths, safe fence, three working planters, flowers/pots/grass, bench, patio table and watering can, fairy lights, butterflies and distant meadow scenery.
- Three distinct crops, five visible soil/seed/sprout/growing/ready states, once-per-day watering, activity/sleep growth, harvesting/replanting and a bounded basket (9 each). Seeds are free; unwatered plants wait safely. Optional matching produce adds two cooking coins without restricting free supplies.
- Mimi (pink, twin-bun baker) and Noah (mint, capped gardener) use the existing procedural avatar with distinct silhouettes. Collision-aware arrival, wandering, waiting, conversation, relaxation and departure run on controlled garden/patio routes. Invitations bring them back naturally.
- Two authored friendships: six base dialogue variants each, context/choice reactions, daily chat/food limits and six repeatable request variants. Requests persist without deadlines; produce gifts consume exactly one item and cooking requests observe meals plated after acceptance.
- Friend at 4 XP; Close Friend at 10 XP plus seven distinct shared in-game days. XP caps at 12. Meaningful conversations/shares/requests record shared days; spam and offline absence do not affect progress.
- One optional daily event from six activities, avoiding the last three events: surprise request visit, bloom, baking, lost ribbon, friendship afternoon and moonlit patio. Events have real world/input conditions, clear detail cards and durable one-time rewards.
- Cozy Connections (L): relationship cards, produce discoveries, optional promises/events, five early permanent garden keepsakes and a future Close Friend figurine. The wind chime, welcome picture, picnic tea set, friendship portrait, companion figurine and moonstone appear by the flower fence when earned.
- Six more permanent catalog upgrades (12 total): flowering arch, garden lantern, lavender planter finish, rosewood bench, strawberry picnic cloth and friends-together frame. Original prices, ownership and coins remain intact.
- After the first neighborhood activity, the next day selects three valid home/garden/social goals with readiness checks and recent-goal avoidance. Current-day legacy goals/claims remain untouched. My First Cozy Week remains available beyond this discovery.
- Daily goals and requests use objective cards and reward/progress badges; journal uses friend/keepsake cards. A single contextual hint has priority and T dismisses it. Wider/lower station views, front-facing boundary-aware social framing, close-wall field of view and a near-head visibility guard improve composition while retaining manual orbit/zoom.

- Phase 2C: contextual visitor bench/table seating, natural stand recovery, greetings/turns, conversational and item-giving gestures, blinking and expressive smiles. Mimi has a baker's apron and Noah has articulated trousers and a distinct cap; existing avatar swatches remain supported.
- Three physical shared activities: patio tea with blend choices and visible cups, a garden picnic with cloth/dialogue choices, and real help watering a dry planted crop. One shared-activity friendship benefit per visitor/in-game day; story progress remains available without additional friendship farming.
- Three complete optional stories: Mimi's Baking Surprise (fresh berry, cupcakes, shared tea), Noah's Little Garden (lavender plant/water/harvest and help), and Rosewater Housewarming (prepare a meal, both-friend picnic, group toast). Chapters have no deadlines and produce permanent kitchen/garden memories. Completed housewarming permits later group picnics and reunions without repeating story rewards.
- Fixed journal pages separate friends, stories, keepsakes and discoveries, preventing sliced scroll headings. Story cards show the actual next chapter. A compact sleep summary records earned coins, meaningful moments, friendship changes, growing beds and tomorrow's objectives.
- Full controls move to F1/Help; a small contextual hint has a persistent Hide tips action and T shortcut. Automatic guidance no longer leaves a hidden legacy dismissal action. Social framing keeps faces beside the panel; automatic camera turns interpolate while manual orbit/zoom remains intact.
- Art improvements include layered branching trees, varied path stones, flower arrangements, kitchen backsplash/cabinet edging, quilt stitching, grounded seating and purposeful household details. Shadow contrast is restrained; low-cost primitive sharing, fewer redundant subdivisions and spatial static batches reduce rendering work without merging customizable or animated surfaces.
- Eight further original PCM cues add sitting/standing, shared/social/story/day-end feedback and quiet interior/evening atmosphere through the existing volume/mute controls (30 cues total).

## Actual extension points

- Appearance dictionary (`display_name`, `hair`, `accent`) → `avatar.apply_appearance(data)`. Explicit instance-local channels retain texture/roughness; cached materials never change.
- Stable IDs in `style_data.gd`: `living_room.rug`, `living_room.sofa_cushions`, `living_room.curtains`; `room.apply_decor(data)` changes surfaces without rebuilding meshes/collision.
- `pairs_rules.gd` owns rules; `cozy_pairs.gd` owns presentation/timers. A single `{puzzle_id: "cozy_pairs", moves: N}` completion reaches `main.puzzle_completed()` for validation, reward and persistence. The puzzle does not touch room nodes or save files.
- `main.gd` owns session/UI state, confirmed data and progression. Preview drafts belong to `personal_decor.gd`, not the save object.

- Room controls use stable IDs `living_room.floor_lamp`, `living_room.curtains`, `living_room.houseplant`; `apply_state` restores settled visuals, `capture_state` captures booleans. Explicit dispatch rejects unsupported interaction IDs.

- `home_rules.gd`: data-driven recipe/catalog/goal definitions and persistent day/economy rules. `cooking_rules.gd`: transient timing/ingredient state and quality scoring. `home_controller.gd`: physical station dispatch, modal journey and one rollback-capable economic commit path. `home_panel.gd`: presentation only. `home_rooms.gd`: furnished geometry, palette channels, food feedback and controlled lighting.
- New stable station IDs: `kitchen.fridge`, `kitchen.prep`, `kitchen.stove`, `bedroom.bed`, `bedroom.make`, `bedroom.lamp`, `bedroom.rest`. These use the existing visibility/facing/range resolver. New room traversal uses the existing player and spring arm.

- `garden_rules.gd`: care/growth/inventory rules. `friendship_rules.gd`: authored identities/dialogue/preferences/requests and relationship thresholds. `neighborhood_events.gd`: event definitions and recent-history scheduling. `neighborhood_rules.gd`: validated persistent neighborhood data, event observations and legitimate rewards. `neighbor_actor.gd`: transient collision-aware visitor state/motion. `neighborhood_controller.gd`: physical dispatch and coherent UI flow through the existing `home.commit()` transaction. `garden_world.gd`: original geometry, crop/keepsake feedback, reusable water and atmosphere.
- Stable `garden.plot0/1/2`, `garden.board/rest/bloom/moon/lost` and `neighbor.mimi/noah` targets use the existing resolver. `home_rules.catalog()` and `goal_definitions()` merge new definitions while retaining the original base constants for compatibility.

- `cozy_story_rules.gd` owns settled chapters, one-time memories, bounded activity benefits and day summaries; `cozy_life_controller.gd` owns reservations, physical shared-activity routing, interruption/retry and story UI. `cozy_social_world.gd` owns chairs, cups, picnic, bell, reusable celebration effects and earned memories. `cozy_art.gd` batches only settled geometry, preserving explicit customization exclusions. `player.social_owned` and visitor pose offsets are transient and never saved.

## Save version and safety

Schema **6**, extending `user://rosewater.cfg`. Migration retains an exact `.v1.bak`, `.v2.bak`, `.v3.bak` `.v4.bak` or `.v5.bak` according to the previous schema.
Atomic temporary writes retain a `.last_good` file and preserve unknown config fields. Malformed new values receive defaults;
a corrupt whole file may recover last-good data but blocks automatic overwrite. Future schemas are protected from downgrade.
Only confirmed appearance/decor, earned unlock/best, settings, guidance, settled room targets and the permanent cozy-corner flag persist. Day/period, coin balance, ownership/equipment, daily claims/receipts, completed-day/milestone records, bed and bedside-light state also persist. Crops/care cycles, produce, per-person friendship/shared days/request receipts, event/history state, journal rewards and new ownership/equipment also persist. Story chapters/step receipts, three earned story memories, daily activity limits, tea/picnic choices and the compact previous-day summary also persist. NPC positions/routes, seat reservations, pose ownership, dialogue focus, temporary cooking, animation progress and water effects never persist. Failed economic writes roll back currency and ownership together; pending plated meals can retry. Unfinished puzzle rounds do **not** persist.
Real saves are never used as test fixtures; tests inject paths and use separate XDG user-data roots.

## Deferred roadmap

Authored avatar/rig improvements, more hairstyles, multiple profiles/homes, furniture placement, more rooms/floors/recipes, more NPCs/relationships and locations, pets, careers and hobbies.
No unused frameworks for these future systems, network services or retention claims were added.

## Known limits and latest evidence

Procedural art remains below the premium reference target; no baked bounce/AO or production character rig. The mirror uses a reflective material, not a real-time reflection viewport. Social poses and gestures use articulated procedural limbs, not a production animation rig. Recipes share a forgiving timing foundation with different ingredient actions and cookware; the original seven goal combinations remain the migration fallback. New events form a bounded six-event pool, and visitors use authored garden routes rather than autonomous whole-house navigation. Close friendships require shared in-game days, without real-world waiting.
Audio resources decode and run through the cloud dummy driver; audible playback is not verified. A Godot 4.6.3 Windows x86_64 release export is prepared and structurally checked; native Windows execution remains unverified.
Final verification: **1149/1149 checks** across 36 suites, including all 762 Phase 1–2B regressions. Both actual process-restart Continue checks passed; schema 1–5 fixtures migrate to 6. Four matched llvmpipe views show 21.52–33.40% lower median frame time, not a hardware FPS claim.
Current evidence: [`review/phase2c/RESULTS.md`](review/phase2c/RESULTS.md). Prior phase reviews remain available.
Open `project.godot` in Godot 4.6.x, F5; C personalizes, B decorates, E interacts, H toggles the optional cozy hint, Q opens daily goals, J opens the compact catalog, L opens Cozy Connections, T toggles hints, F1 opens controls, Esc closes the top UI or pauses.
