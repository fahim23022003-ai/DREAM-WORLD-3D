# Phase 2C — The Cozy Life Experience

Godot **4.6.3**, Compatibility renderer. Branch `work`, baseline `66ea36571c68de7772923d57c1a18a7810341ca0`. This is one integrated extension of the existing home session, gardening, friendships, currency, goals and save transaction. No new service, production rig or unrelated simulation framework was introduced.

## What players can actually do

Approach Mimi or Noah with E, choose **Shared activities**, and walk together to a real activity location:

- **Cozy tea time:** both participants approach opposite patio chairs, sit, and reach across visible cups and a teapot. Berry and lavender choices produce different dialogue and persistent cup palettes.
- **Garden picnic:** participants sit on a physical blanket with cups, basket and food. Funny stories and cloud-watching have different feedback and fabric colors. Completing the housewarming permits later group picnics with both visitors.
- **Garden help:** a visitor approaches an actually dry planted crop, reaches toward it, and waters it through the existing gardening rules. It cannot create another harvest or bypass once-per-day care. It also contributes to the existing garden objective/request conditions.

A completed shared activity provides at most one friendship benefit per person/in-game day across all three activities. Repeating a moment remains possible without farming friendship. Existing chat, food/request limits and the seven meaningful shared-day Close Friend requirement remain intact.

Visitors now reserve separate bench places, approach through the clear planter corridor, actually sit, and stand before returning or departing. Seating collision follows the occupied bench location rather than blocking the walkway in front. Visitors can move away from a nearby player while continuing to yield before walking toward them. Table approaches use clear side positions. Esc cancels an unfinished activity without changing currencies, crop state, friendship or story progress. Interrupted poses and reservations recover safely.

The articulated avatar adds blinking, expressive mouth motion, greeting/waving, turning, conversational reach, visible item parcels during giving/receiving, and happy reward gestures. Mimi has a small baker's apron; Noah's trousers follow articulated legs and his cap/shorter hair is visually distinct. The player retains appearance customization. Sitting, standing and picnic pose recovery are shared by both visitors; no production skeleton is required.

## Three complete optional stories

| Story | Actual ordered gameplay | Permanent physical memory |
|---|---|---|
| Mimi's Baking Surprise | Begin a plan → harvest a fresh strawberry (one is set aside) → plate Berry Cupcakes → share tea | Sugarbell cake cloche on the kitchen counter |
| Noah's Little Garden | Begin → plant lavender → water it → harvest it → help tend another dry crop | Lavender memory corner in the garden |
| Rosewater Housewarming | Meet both friends and finish a personal story → begin → plate a meal → share a picnic with both friends → ring the gathering bell and keep the toast | Supported lantern gathering arch |

Each arc has a beginning, authored relationship-sensitive dialogue, multiple real world steps, a conclusion, an eight-coin one-time reward and a lasting memory. Steps are observed from existing planting, care, harvest and plating transactions; opening a panel cannot complete a chapter. The stories have no deadlines, offline timers or missable introductions. Completed stories do not restart. Subsequent gatherings acknowledge the existing memory and cannot replay chapter rewards.

The full rendered journey completed **all three arcs**, not just their introductions. A following real-input review returned on Day 3, earned Mimi's Friend level through another legitimate shared activity, and replayed a group gathering with the same ten chapter receipts. Both separate-process Continue checks preserved the correct progress. The original full journey ended with 55 coins; the later earned Friend keepsake added two, producing the independently verified **57-coin** review save.

## Visual, camera and interface changes

The garden replaces repeated egg-shaped trees with branching trunks and layered, varied foliage clusters. Flowers have varied heights/shapes; stepping stones vary in shape and rotation. Ground/self-shadow handling and restrained lighting contrast reduce harsh bands without adding expensive GI or additional dynamic lights. Interiors retain recognizable furniture and customization while adding cabinet/backsplash detail, ceramics, quilt stitching, household books and small supported arrangements. Seating and earned memories have actual supporting geometry.

The avatar retains the existing doll style with a cleaner hair outline, blinking, stronger mouth expressions and distinct visitor clothing/accessories. This is a procedural art refresh, not a wholesale anatomy or production-character replacement.

Automatic camera turns interpolate rather than snap. Conversation framing uses the actual player/visitor line and offsets the pair into the visible world beside the panel. Near-head visibility guards remain; cooking tools and food remain visible. Manual orbit, zoom and spring-arm wall collision remain available.

The journal uses separate Friends, Stories, Keepsakes and Discoveries pages. Complete cards are paged rather than sliced by a moving scroll boundary, and compact pages remove unnecessary blank height. Story pages show the current real objective and permanent reward. Daily goals retain three objective cards and a separate milestone area. Conversation actions have clearer primary/secondary styling; activity controls occupy a smaller panel while the physical action stays visible.

The daily-pacing audit retained the existing readiness checks, recent-goal avoidance and three-goal workload. Shared activities now supply alternative legitimate friendship/garden conditions, while story chapters give optional multi-day direction instead of adding another daily checklist. Basic cooking, requests and the six-event pool remain available.

A compact, skippable end-of-day summary shows earned coins, a few meaningful moments, friendship changes, planted beds, story memories and tomorrow's three goals. It appears after sleeping once the player engages with the new social/story content; existing earlier-phase sleep flows remain compatible.

The full keyboard legend moves to **F1/Help**. Contextual guidance has a visible **Hide tips** action and the existing T shortcut. The legacy hidden dismissal action was removed from automatic guidance, fixing a timing-dependent onboarding failure without weakening its assertions. Explicit H cozy-corner guidance remains available.

Eight original local PCM cues add sitting, standing, social/shared moments, story/day-end feedback and restrained interior/evening ambience. All **30** local cues use the existing volume/mute controls. There is no background music track or external audio service. Resource loading and Dummy-driver behavior were checked; **audible playback is UNVERIFIED**.

## Save compatibility and transactions

Schema **6** extends the settled home state. Migrations from **1, 2, 3, 4 and 5** preserve exact version-specific backups, currency, garden inventory, friendship/shared days, existing goals/receipts and unknown configuration fields. Atomic writes, last-good recovery, corrupt-file protection and future-schema write blocking remain intact.

Persistent story fields contain current chapters, completed step receipts, earned memories, bounded activity-day benefits, the two presentation choices and the compact previous-day summary. Malformed chapter/summary values are bounded or defaulted. NPC positions, seat reservations, animation frames, pose offsets, particles and activity ownership are not serialized.

The tests induce actual temporary-write failures on isolated fixtures. Harvesting/reserving Mimi's berry and the final story/shared-activity claim roll back together with inventory, friendship and coins. Retry awards the final story reward exactly once. No real player save was used or removed.

## Verification

**1149/1149 checks passed across 36 suites: 762 prior regression checks and 387 new checks.** All recorded processes exited successfully. The new rule/session suites passed 70/70 and 76/76; the final fresh story journey passed 173/173, its process-restart Continue 9/9, the earned-save review 52/52, and its second Continue 7/7. Counts include movement checks conditional on the actual visitor route. [Machine-readable totals](logs/checks.json).

Final per-suite counts, exit codes and complete logs are retained in `logs/`. Expected save-write warnings and the corrupt-file parse error come from deliberately failing isolated fixtures; they are followed by successful recovery assertions. The X11 driver also reports that changing VSync is unsupported. No script error or failed assertion remains. Existing assertions were retained; four older Phase 2B capture output paths now target `/tmp/dream-phase2b-review/` to preserve historical screenshots.

The new rendered journey uses real W movement, mouse orbit, E resolver, GUI choices, ingredient keys and cooking timing. It explores the house, enters the garden, talks to both visitors, completes tea/help/picnic, plants/waters/harvests, plates meals, completes all stories, claims actual rewards, sleeps, reads summaries, uses the real Quit menu and Continues in a new process. It does not inject success flags, currency, crops or friendship. Camera-only inspection framing is separate from gameplay progression. Controlled model/transaction fixtures are confined to contract tests.

The follow-up rendered review verifies both activity choices, visible palette consequences, safe stand-up recovery, unobstructed dialogue faces, Help/T input, repeat gatherings with no repeated story receipts, both journal resolutions and another real process restart. It starts from the genuine earned journey save.

### Reproduce

Use Godot 4.6.3, a working DISPLAY=:99, and the writable XDG paths described in README. The runner creates isolated fixture paths and serializes rendered processes with a display lock.

```sh
python3 tools/verify_phase2c.py --headless --include-new
python3 tools/verify_phase2c.py
python3 tools/verify_phase2c.py --stories
```

Fresh/Continue pairs must use the same isolated XDG root and fixture pointer. Do not run two captured-mouse Godot processes concurrently. An individual script can also be run using `godot --headless --path . --script res://tests/<contract>.gd`, or `godot --audio-driver Dummy --path . --script res://tests/phase2c_flow.gd` followed by the same command with `-- --resume`.

## Software-renderer comparison

Matched baseline/current measurements use the same Godot version, X11 display, 1280×720 viewport, Compatibility renderer, Mesa llvmpipe, uncapped/vsync-disabled setting, fresh isolated data, inactive visitors, four fixed camera views and time-of-day. Each view warms for 40 frames and records 120 frame intervals; median and p95 wall times plus draw calls/primitives are retained. This measures steady rendered frames rather than startup time. No other Godot test runs during the accepted final benchmark.

The baseline was rendered from a `git archive` copy outside the checkout; no Git worktree was created. `tools/benchmark_phase2c.gd` can run against either project path. Set `DREAM_REVIEW` to an output directory and `DREAM_VERSION=before` or `after` to reproduce the separate genuine captures. These are **software-renderer frame timings, not hardware FPS claims**.

| Matched view | Before median / p95 ms | After median / p95 ms | Median reduction | Draw calls before → after | Primitives before → after |
|---|---:|---:|---:|---:|---:|
| Living Room | 492.04 / 555.28 | 327.69 / 396.76 | 33.40% | 2283 → 1337 | 1,324,590 → 516,310 |
| Kitchen | 302.07 / 360.46 | 219.79 / 263.90 | 27.24% | 672 → 497 | 420,804 → 138,732 |
| Bedroom | 288.20 / 336.83 | 196.90 / 232.17 | 31.68% | 520 → 427 | 331,134 → 95,130 |
| Garden | 320.57 / 370.20 | 251.60 / 300.55 | 21.52% | 2202 → 1057 | 1,253,388 → 598,424 |

[Raw comparison JSON](logs/performance_comparison.json) · [CSV](logs/performance_comparison.csv). These four software views improved by **21.52–33.40%** in median frame time. Results do not establish hardware frame rates or startup performance.

Primitive sharing, fewer redundant subdivisions, cached leaf materials and spatial batches reduce work. Customizable surfaces, blend-shape curtains, animated props, crops and visitor limbs remain independent. Settled repeated refreshes allocate no additional materials. Inactive visitors return before animation/navigation processing; celebration and water use reusable bounded pools.

## Windows playtest readiness

A Windows Desktop **x86_64 release** is prepared with the matching official Godot 4.6.3 templates, whose archive matched the published SHA-512 checksum. The output is structurally checked for a PE x86_64 executable and Godot PCK header. Artifacts and source fingerprints are recorded in `logs/windows_artifacts.json`; binaries remain ignored under `builds/`.

Distribution: `builds/DreamWorld3D-Phase2C-Windows.zip`, containing the EXE/PCK, Godot license and playtest guide. Reproduction and the human first-ten-minutes/multi-day checklist are in [`docs/WINDOWS_PLAYTEST.md`](../../WINDOWS_PLAYTEST.md). Native Windows execution, hardware performance, audio listening and human enjoyment remain **UNVERIFIED**.

## Genuine evidence and review

All PNGs below come from running Godot. The four environment comparisons use separate matched before/after captures because combining them would require editing the evidence. No image edits, concept art, synthetic rewards or editor mockups were used. Images were opened and inspected; review corrected a clipped activity panel, a retained crossed-leg pose, bell/face overlap, unsupported lantern suspension, journal clipping/blank space, camera face placement and blocked bench return routes.

The silent activity video is a genuine 1280×720 X11 capture of the game client. It is not audible-playback evidence. `images.json` records image dimensions and hashes; raw logs retain the checks supporting the earned states.

| Running-game evidence | Repository-relative file |
|---|---|
| [01 living room after](01_living_room_after.png) | `docs/review/phase2c/01_living_room_after.png` |
| [01 living room before](01_living_room_before.png) | `docs/review/phase2c/01_living_room_before.png` |
| [02 kitchen after](02_kitchen_after.png) | `docs/review/phase2c/02_kitchen_after.png` |
| [02 kitchen before](02_kitchen_before.png) | `docs/review/phase2c/02_kitchen_before.png` |
| [03 bedroom after](03_bedroom_after.png) | `docs/review/phase2c/03_bedroom_after.png` |
| [03 bedroom before](03_bedroom_before.png) | `docs/review/phase2c/03_bedroom_before.png` |
| [04 garden after](04_garden_after.png) | `docs/review/phase2c/04_garden_after.png` |
| [04 garden before](04_garden_before.png) | `docs/review/phase2c/04_garden_before.png` |
| [05 avatar closeup](05_avatar_closeup.png) | `docs/review/phase2c/05_avatar_closeup.png` |
| [06 mimi expressions](06_mimi_expressions.png) | `docs/review/phase2c/06_mimi_expressions.png` |
| [07 noah expressions](07_noah_expressions.png) | `docs/review/phase2c/07_noah_expressions.png` |
| [08 actual seated npc](08_actual_seated_npc.png) | `docs/review/phase2c/08_actual_seated_npc.png` |
| [09 shared tea time](09_shared_tea_time.png) | `docs/review/phase2c/09_shared_tea_time.png` |
| [10 garden picnic](10_garden_picnic.png) | `docs/review/phase2c/10_garden_picnic.png` |
| [11 story event](11_story_event.png) | `docs/review/phase2c/11_story_event.png` |
| [12 housewarming gathering](12_housewarming_gathering.png) | `docs/review/phase2c/12_housewarming_gathering.png` |
| [13 improved daily ui](13_improved_daily_ui.png) | `docs/review/phase2c/13_improved_daily_ui.png` |
| [14 improved journal](14_improved_journal.png) | `docs/review/phase2c/14_improved_journal.png` |
| [15 end of day summary](15_end_of_day_summary.png) | `docs/review/phase2c/15_end_of_day_summary.png` |
| [16 camera comparison](16_camera_comparison.png) | `docs/review/phase2c/16_camera_comparison.png` |
| [17 quit continue](17_quit_continue.png) | `docs/review/phase2c/17_quit_continue.png` |
| [18 noah garden memory](18_noah_garden_memory.png) | `docs/review/phase2c/18_noah_garden_memory.png` |
| [19 controls help](19_controls_help.png) | `docs/review/phase2c/19_controls_help.png` |
| [20 future keepsakes](20_future_keepsakes.png) | `docs/review/phase2c/20_future_keepsakes.png` |
| [21 journal 1920x1080](21_journal_1920x1080.png) | `docs/review/phase2c/21_journal_1920x1080.png` |
| [12-second shared tea video](22_shared_activity.mp4) | `docs/review/phase2c/22_shared_activity.mp4` |

## Remaining limits

- Art remains simple and procedural; no premium character rig, full finger articulation, baked GI or real-time mirror reflection. Much of the existing eye/hand/furniture anatomy remains recognizable rather than being replaced wholesale.
- Visitors use authored collision-aware garden routes. They politely wait when a player blocks their direction; this is not autonomous town-wide pathfinding. Contextual pose transitions are procedural rather than motion capture.
- Three completed stories and repeatable shared moments provide bounded content. No pet, career, city, romance, multiplayer or unrelated major system was added.
- Small world-space text on the cake-cloche plaque remains partly occluded from oblique views. The Help overlay retains the current gameplay camera, which can leave a close avatar behind the modal. These are remaining visual gaps.
- Background music was omitted; local ambience is restrained and intermittent.
- **Windows native execution, hardware benchmarking, audible playback and human enjoyment are unverified.** The prepared export is not a substitute for the documented human checklist.
- Core seating, all three shared activities and all three complete story arcs are implemented. No placeholder story chapter or fabricated completion is presented as finished.
