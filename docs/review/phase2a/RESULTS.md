# Phase 2A — A living, playable cozy home

Starting commit: `57d8a678e751893836c082385a494e93e0891adb`, branch `work`, Godot **4.6.3**.

## Implemented journey

The recognizable living room now connects through two genuine doorways to a furnished kitchen and bedroom. The existing character, physics movement, spring-arm camera and range/facing/visibility interaction resolver handle all traversal and station actions. No room-selection teleport buttons were added.

The kitchen has handled cabinets, hinged pantry refrigerator, preparation board, hob and oven, sink/faucet, shelves and pastel jars, breakfast nook, dishes, herb pot and warm pendant lighting. The bedroom has a framed bed, layered quilt and pillows, rug, bedside cabinet and switchable lamp, wardrobe, stylized mirror, window treatment, art, journal, slippers and a rest bench. Furniture and walls have collision; circulation remains clear.

Cooking is anchored to fridge → board → stove → board. Supplies are free. Ingredients, prepared portions, cookware and finished food change visibly. Reaching/preparing/cooking/presenting use the existing procedural avatar; steam is pooled, small and translucent. Screen-space station panels pause world movement and support keyboard and mouse; Esc closes without losing a retryable cooking step. Cooking is transient and never resumes half-animated after loading.

| Recipe | Preparation | Cooking | Finished 3D dish |
|---|---|---|---|
| Cloud Pancakes | Three timed whisk folds | Flip both sides | Pancake stack, butter and berries |
| Berry Cupcakes | Butter → flour → berries, ingredient choices and timing | Rotate tray, lift baked cups | Three frosted berry cupcakes |
| Starry Vegetable Soup | Carrot → greens → star pasta, ingredient choices and timing | Stir, season, finish | Ceramic bowl, vegetables and star pasta |

Timing/ingredient error determines **Perfect / Good / Cozy**. Every completed attempt yields food; there is no ingredient loss or forced failure. Different recipes, cookware and input orders provide variation within one shared forgiving timing foundation.

## Days, goals and progression

Q opens a compact daily panel; J opens the finish catalog (also reachable from existing Decor). Contextual first-day guidance points toward the fridge, next cooking station, objectives, finishes and bedroom. It respects dismissed hints; migrated saves skip the new-player recipe introduction. Existing personalization, Decor drafts, Cozy Pairs, Lavender Dream and First Cozy Corner remain intact.

Meals, Cozy Pairs and the bedroom rest bench advance Morning → Afternoon → Evening → Night. Ambient/window colors, window fill, sunlight and indoor lamp balance transition without expensive GI. Rest lets players reach a later period without real-time waiting. The bed offers a short breathing/fade transition, saves the next day and refreshes goals. No survival meters or offline penalties.

Thirteen objective definitions form seven rotating daily combinations. Day 1 asks for a meal, watering and making the bed. Objectives use actual gameplay events: three recipe variants, any meal, quality, watering, lamp, curtains, card game, rest, making the bed, after-sunset meal and visiting the fridge. The after-sunset goal remains achievable at Night. Current lamp/curtain states never make an objective impossible.

| Reward | Cozy Coins |
|---|---:|
| First plated meal of each recipe/day | 6 |
| Second meal of that recipe/day | 2 |
| Further same-recipe practice | 0 meal coins |
| Each daily objective | 3, once |
| Complete daily set | 6, once |
| Three completed cozy days | Amber bedside keepsake +10 |
| Seven completed cozy days | Seven-star bedroom frame +20 |

“My First Cozy Week” records completed days and permanent milestones. Sleeping alone cannot earn the keepsakes: three/seven completed daily sets are required. Skipped days delay those milestones. After Day 7, the seven goal combinations rotate, recipes remain playable and unpurchased finishes remain available. This is a bounded repeatable foundation, not an endless-content claim.

## Meaningful purchases

| Stable ID | Visible finish | Cost |
|---|---|---:|
| `bed.strawberry` | Strawberry quilt and accent pillows | 12 |
| `bed.lavender` | Lavender quilt and accent pillows | 16 |
| `lamp.moon` | Moonlight bedside shade | 14 |
| `kitchen.mint` | Mint cabinet fronts | 12 |
| `kitchen.rosewood` | Rosewood cabinet fronts | 18 |
| `ceramics.berry` | Berry shelf ceramics | 10 |

All six start locked. Free preview frames the actual furnishing; Close/Esc restores confirmed finishes. Buy & equip persists cost, ownership and equipment together. Owned items equip free and never require repurchase. Rows distinguish Equipped, Owned, Affordable and Locked with visible prices.

## Persistence and architecture

Schema **4** preserves schema 1/2/3 saves with an exact version-specific backup. Original appearance, decor, puzzle unlock/best, First Cozy Corner, lamp/curtain/plant states, settings and guidance remain. Existing atomic replacement, `.last_good`, corrupt-file write protection, future-schema protection and unknown config fields remain supported; additive unknown home fields also survive.

New persistent state includes day/period, coins, owned/equipped finishes, daily completion/claim receipts, completed-day/milestone records, bed and bedside-lamp state. Temporary cooking/steam/animations never serialize. Failed purchases restore both balance and ownership; failed plated rewards can retry; failed sleep keeps the previous day. Pending puzzle completion and its daily goal share the existing reward save/retry, so retry cannot lose the daily receipt or pay it twice.

`home_rules.gd` owns definitions and persistent rules; `cooking_rules.gd` owns transient input scoring; `home_controller.gd` owns station/modal flow and economic commits; `home_panel.gd` presents UI; `home_rooms.gd` owns new geometry and visual feedback. Main retains session ownership and explicit interaction dispatch. No unused frameworks for future NPCs, pets or careers were added.

## Verification

Cloud Linux, Godot 4.6.3, Compatibility renderer/llvmpipe, Dummy audio. Every test uses an isolated XDG directory and injected fixture paths; no personal saves were modified. Rendered tests run sequentially to avoid competing captured input.

Commands use writable `XDG_DATA_HOME`, `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`; rendered commands add `DISPLAY=:99` and `--audio-driver Dummy`:

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/<contract>.gd
godot --audio-driver Dummy --path . --script res://tests/phase2a_flow.gd
godot --audio-driver Dummy --path . --script res://tests/phase2a_flow.gd -- --resume
godot --audio-driver Dummy --path . --script res://tests/phase2a_recipes.gd
godot --audio-driver Dummy --path . --script res://tests/phase2a_effects.gd
```

**482/482 checks passed across 21 suites**, retaining the original **263/263** regression baseline. Editor import completed without script/resource errors. Final logs contain no failed checks, script errors or shutdown leaks. [Per-suite counts](logs/checks.json), [rendered process exit codes](logs/rendered_exits.json) and full [logs](logs/) are retained.

| Suite | Result |
|---|---:|
| Original save / style / pairs / session contracts | 12/12 · 17/17 · 16/16 · 17/17 |
| Original rendered Phase 1 | 22/22 |
| Phase 1C rendered fresh / legacy | 33/33 · 31/31 |
| Original rendered keyboard focus | 7/7 |
| Phase 1D UI / room / migration contracts | 13/13 · 34/34 · 10/10 |
| Phase 1D rendered flow / separate-process Continue | 46/46 · 5/5 |
| Home rules: nine quality combinations, eight-day rules, rewards and malformed state | 45/45 |
| Home session: schemas 1–3, transactions, retry, lamp, paused catalog, modal safety | 32/32 |
| Room navigation, collision, resolver, camera and night atmosphere | 18/18 |
| Modal bounds, old Decor and long HUD names at both resolutions | 24/24 |
| Phase 2A first-day rendered journey, including actual purchase fault/retry | 51/51 |
| Phase 2A separate-process Continue and fresh Day 2 objectives | 6/6 |
| Actual cupcake / soup ingredient, timing and plating flows | 29/29 |
| Corrected steam and genuine pancake plating recapture | 14/14 |

The first-day rendered flow physically walks between rooms and uses real E, timing/ingredient keys, mouse buttons, catalog preview/purchase, Q/J panels and the sleep confirmation. Its purchase-save fault is a real directory at the isolated fixture's `.tmp` path: the old file and balance survive; removing that empty test directory allows one successful retry. Actual Quit ends that process. A new process uses Continue to verify Day 2, balance, ownership/equipment and absence of temporary cooking. The second rendered recipe run prepares, cooks and plates cupcakes and soup through ordinary inputs.

Historical Phase 1C/1D screenshot outputs now go to `/tmp` during regression tests; committed prior review images are untouched. Expected corruption/blocked-write diagnostics belong to negative tests. The software renderer's unsupported V-Sync warning is not a script failure.

## Genuine runtime evidence

Every image is from the running Godot game. Finished meals follow actual completed station/input sequences; the purchase follows genuinely earned first-day coins. All primary images are 1280×720; the additional catalog layout image is 1920×1080. Catalog and personalization are also rendered at 1920×1080; modal bounds are tested at both resolutions. Images were individually inspected. Review corrected a fridge-obstructed wide view, overlapping station approach, UI cleanup leak, existing Decor height overflow and oversized steam before final captures.

| Repository-relative path | Evidence |
|---|---|
| [docs/review/phase2a/01_living_room_preserved.png](01_living_room_preserved.png) | Preserved living room and new day/coin HUD |
| [docs/review/phase2a/02_kitchen_wide.png](02_kitchen_wide.png) | Furnished, walkable kitchen |
| [docs/review/phase2a/03_kitchen_interaction.png](03_kitchen_interaction.png) | Physical fridge recipe selection |
| [docs/review/phase2a/04_cooking_preparation.png](04_cooking_preparation.png) | Ingredients, board, preparation input |
| [docs/review/phase2a/05_cooking_active.png](05_cooking_active.png) | Stove timing, cookware and restrained steam |
| [docs/review/phase2a/06_finished_food.png](06_finished_food.png) | Real plated pancake result and earned coins |
| [docs/review/phase2a/07_bedroom_wide.png](07_bedroom_wide.png) | Complete furnished bedroom |
| [docs/review/phase2a/08_bedroom_sleep.png](08_bedroom_sleep.png) | Bed interaction and next-day confirmation |
| [docs/review/phase2a/09_daily_goals.png](09_daily_goals.png) | Legitimately completed first daily set |
| [docs/review/phase2a/10_decor_unlock.png](10_decor_unlock.png) | Purchased/equipped quilt, exact remaining balance |
| [docs/review/phase2a/11_day_progression.png](11_day_progression.png) | Day 2 fresh objectives |
| [docs/review/phase2a/12_quit_continue_restored.png](12_quit_continue_restored.png) | New-process Continue restores the purchased room |
| [docs/review/phase2a/13_decor_preview.png](13_decor_preview.png) | Free actual 3D furnishing preview before purchase |
| [docs/review/phase2a/14_berry_cupcakes.png](14_berry_cupcakes.png) | Real completed cupcake recipe |
| [docs/review/phase2a/15_starry_soup.png](15_starry_soup.png) | Real completed soup recipe and evening atmosphere |
| [docs/review/phase2a/16_catalog_1920x1080.png](16_catalog_1920x1080.png) | Genuine high-resolution catalog layout |

## Limits and scope

All core Phase 2A systems are implemented. Procedural art remains lightweight; this is not a production character rig or a premium-quality claim. The mirror uses a stylized reflective material, not a reflection viewport. Context actions are procedural reaches/poses; sleep uses a short fade rather than a fully animated lie-down. Recipes share one timing foundation with distinct inputs and models; goal combinations repeat weekly. Supplies are free bundles, not a general inventory economy. Geometry remains open-ceiling and lighting uses controlled ambient/local lights rather than baked/global illumination.

Fourteen original local PCM cues decode and use existing volume/mute controls; absent optional audio is safe. Audible playback remains **unverified** with the dummy driver. Windows export, Windows performance and audible Windows playback remain **untested**. No optional video was recorded. No additional rooms, NPCs, relationships, pets, furniture placement, multiplayer, careers or music were introduced beyond the requested implemented foundation.
