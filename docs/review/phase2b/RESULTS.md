# Phase 2B — A Living Neighborhood

Godot 4.6.3, Compatibility renderer, Linux/X11 with Mesa llvmpipe. Baseline: `a40406dd7d15575432a96cc4c1a3a91ceabde041`, branch `work`. All fixtures use isolated save paths and XDG data directories. No personal save was reset.

## Delivered gameplay

Rosewater House now opens physically onto a fenced garden/patio. The original player walks through the trimmed east-wall entrance; no teleport or garden menu substitutes for traversal. Three collidable raised beds, pastel stones, flowers/grass, pots, a wooden bench, patio table and watering can, butterflies, moving foliage, fairy lights and distant scenery extend the house's time-of-day lighting.

Strawberries, carrots and lavender have soil, seed, sprout, growing and harvest-ready visuals. Choose free seeds with E, water once per care day, cook/rest to observe growth, then sleep for a harvest. Harvesting empties the plot and supplies a bounded basket (9 of each). Replant freely; unattended plants never die. Optional matching produce adds a cooking bonus; all three existing recipes retain free supplies. Watering uses the avatar's reach, local audio and reusable drops.

Mimi wears pink with twin buns; Noah has a mint cap, short hair and trousers. They arrive from the garden gate, follow controlled collision-aware patio waypoints, wait/wander, look around/wave, hold conversation, relax and leave naturally. Away actors have no blocking collision. Players and visitors stop against each other. Invitations avoid occupied arrival points. These are two working finite-state visitors, not an unused AI framework.

Each has six authored base dialogue variations plus world/period/request/friendship reactions, preferred conversation choices, fresh-food sharing and quiet moments. Acquaintance → Friend requires 4 XP. Close Friend requires 10 XP **and seven distinct shared in-game days**; XP caps at 12. Talk, sharing and request receipts prevent repeated rewards. No real-time login requirement exists.

Six persistent optional requests connect these friendships to actual gameplay: Mimi's pancakes, cupcakes and Good-or-better meal; Noah's carrots, lavender and watering three different beds. Meal requests observe a completed plate after acceptance. Produce is consumed exactly once on claim. Requests have objective/reward/readiness cards, success dialogue and coin/friendship feedback. Declining or sleeping does not permanently remove content.

Six optional daily events use actual completion conditions: surprise request visit, blooming flower patch, cupcake baking bonus, a visible lost ribbon, friendship afternoon and an evening moonlit-garden interaction. One event per day, three-event recent-history avoidance, durable completion receipts and clear journal detail cards keep them manageable.

Cozy Connections (L) shows relationships, meaningful shared days, produce discoveries and six achievement keepsakes. Harvest, first conversation, first request, Friend, Close Friend and garden event unlock a wind chime, welcome picture, picnic tea set, portrait, companion figurine and moonstone physically by the flower fence. Five are earned in the rendered journey; the future Close Friend reward remains honestly locked there. Rule fixtures verify that later unlock without fabricating a screenshot.

The six new purchasable/equippable IDs are `garden.arch` (18), `garden.lantern` (14), `garden.planter` (12), `garden.bench` (16), `garden.picnic` (10), `social.frame` (12). Geometry or surface finishes visibly change; the existing preview/ownership/transaction path persists them. Original catalog entries and prices are retained.

After neighborhood discovery, the next sleep selects three reasonable home/garden/social daily objectives with readiness checks and recent-goal avoidance. Current-day legacy goals and their claim receipts remain unchanged. My First Cozy Week remains intact. The goals panel now uses three cards with progress/checkmarks/reward badges and a separate milestone section; requests/journal use the same visual language. One contextual instruction has priority, T dismisses hints, and H retains the explicit cozy hint. Manual orbit/zoom remains available. Station framing is wider/lower; social framing chooses a side with wall clearance; close-wall FOV and near-head visibility reduce hair obstruction.

Eight original locally synthesized PCM cues add planting, watering, harvesting, arrival, conversation, friendship, event and garden ambience through existing volume/mute controls. There are 22 local cues in total. No network services or third-party assets are used.

## Save safety

Schema **5** extends the nested home state. Schemas **1, 2, 3 and 4** retain migration with exact versioned backups. Original atomic temporary writes, last-good recovery, unknown-field preservation and future-schema protection remain. Crops/care cycles, bounded produce, independent friendships/shared-day records, requests/receipts, events/history, milestones/discoveries and new decor persist. Actor positions, routes, animation frames, temporary water and dialogue focus do not.

Actual failed writes were induced on isolated fixtures for watering, request claims and harvesting. Rollback and retry retain the correct inventory/currency/reward state. Existing corrupt-save/last-good/future-schema contracts remain passing. Separate rendered process restarts verify Continue, not an in-memory reload.

## Verification

The final run passes **762/762 checks across 30 suites**, including **all 482 original Phase 1–2A regression checks**. No old assertion was weakened. Three old review-output paths now target `/tmp/dream-phase2a-review/` so rerunning regressions cannot overwrite historical screenshots.

| Coverage | Checks |
|---|---:|
| Original save/style/pairs/session, Phase 1D UI/room/save, home rules/session/navigation/layout | 238 |
| Original rendered Phase 1, 1C fresh/legacy, focus, 1D flow/Continue, 2A flow/Continue/recipes/effects | 244 |
| Neighborhood rules: crops/inventory, all dialogue/request definitions, six events, receipts, caps, seven-day threshold, 30-day goal validity, malformed data | 87 |
| Neighborhood session: four migrations, write-failure rollback/retry, persistence, modal input, long text and both-resolution layout | 47 |
| Visitor arrival/state transitions, collision, paths, departure, clear arrival points and distinct silhouettes | 11 |
| Genuine rendered garden → Mimi → cooking/request/Friend → purchase → sleep → harvest/event → Quit | 89 |
| First separate-process Continue | 9 |
| Genuine Noah carrot request, consumption, independent friendship and second Quit | 14 |
| Second separate-process Continue, collection scrolling and 1920×1080 layout | 8 |
| Fresh-session arrival/first-water capture fixture | 9 |
| Final earned-save camera composition check | 6 |
| **Total** | **762** |

The main rendered journey uses actual W movement, mouse orbit, E resolver, GUI buttons and Space timing. It never sets garden stages, friendship, currency, ownership or completion flags to make the journey pass. It plants/waters all three crops, cooks Cloud Pancakes, fulfills Mimi's promise, reaches Friend, buys/equips the picnic cloth, sleeps, harvests each crop once, gathers the bloom bonus, rests until evening and uses the real Quit menu. Continue restores 26 coins and one of each crop. Noah's subsequent real carrot request consumes one carrot; its request reward plus the legitimate friendship daily goal leave **35 coins**, carrots **0**, and both visitors at Friend. Another process verifies those exact values and independent shared days.

Headless contracts deliberately inject model state for exhaustive boundary/migration/failure tests; those fixtures are separate from rendered acceptance. `logs/` contains each suite's full output and rendered exit codes. Expected corrupt-file parse diagnostics and intentionally denied temporary writes belong only to negative contracts. The final camera-only review follows the full journeys on their earned save; it verifies perpendicular player/visitor framing without changing reward state. Long HUD notices are bounded and wrap at both resolutions. Normal rendered journeys contain no script errors or failed checks. V-sync unsupported warnings are from the cloud driver.

### Reproduction

From the repository, use Godot 4.6.3. Set separate data directories, e.g.:

```bash
export DISPLAY=:99
export XDG_DATA_HOME=/workspace/.runtime/phase2b-review
export XDG_CONFIG_HOME=/workspace/.runtime/config
export XDG_CACHE_HOME=/workspace/.runtime/cache
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/neighborhood_rules_contract.gd
godot --headless --path . --script res://tests/neighborhood_session_contract.gd
godot --headless --path . --script res://tests/neighbor_navigation_contract.gd
godot --audio-driver Dummy --path . --script res://tests/phase2b_flow.gd
godot --audio-driver Dummy --path . --script res://tests/phase2b_flow.gd -- --resume
godot --audio-driver Dummy --path . --script res://tests/phase2b_social_flow.gd
godot --audio-driver Dummy --path . --script res://tests/phase2b_social_flow.gd -- --resume
godot --audio-driver Dummy --path . --script res://tests/phase2b_capture.gd
godot --audio-driver Dummy --path . --script res://tests/phase2b_camera.gd
```

Run rendered processes **sequentially** on the shared display. The flow writes an isolated fixture pointer in `/tmp`; its Continue/social scripts must follow it with the same XDG root. Each fresh run creates a unique fixture. Prior regression commands remain documented in the Phase 2A report and test scripts; execute their fresh/Continue pairs sequentially too.

## Genuine screenshot review

All 19 PNGs in this directory were captured from running Godot. `images.json` records dimensions and SHA-256 hashes. 01–16 satisfy the requested views; 17 adds 1920×1080, 18 shows the physical entrance and 19 exposes the earned/future collection cards using real mouse-wheel scrolling. No editor mockups, concept art, synthetic rewards or image edits were used.

The screenshots were opened and inspected for framing, targets, floor contact, light, clipping and panel bounds. Review prompted wider planting/arrival views, side-oriented social framing, supported keepsake bases, background ground, smaller name outlines and scrollable long text. The new cooking shot keeps the stove/food visible; daily cards replace the former document-like panel. The 720p and 1080p layouts are readable and within the viewport. Existing house/window/curtain regressions pass.

- [01_garden_wide.png](01_garden_wide.png)
- [02_garden_planting.png](02_garden_planting.png)
- [03_garden_growing.png](03_garden_growing.png)
- [04_garden_harvest.png](04_garden_harvest.png)
- [05_mimi_arrival.png](05_mimi_arrival.png)
- [06_noah_garden.png](06_noah_garden.png)
- [07_visitor_conversation.png](07_visitor_conversation.png)
- [08_visitor_request.png](08_visitor_request.png)
- [09_friendship_reward.png](09_friendship_reward.png)
- [10_dynamic_event.png](10_dynamic_event.png)
- [11_new_daily_goals.png](11_new_daily_goals.png)
- [12_progress_journal.png](12_progress_journal.png)
- [13_garden_decor.png](13_garden_decor.png)
- [14_evening_garden.png](14_evening_garden.png)
- [15_camera_improvement.png](15_camera_improvement.png)
- [16_quit_continue_restored.png](16_quit_continue_restored.png)
- [17_journal_1920x1080.png](17_journal_1920x1080.png)
- [18_house_garden_entrance.png](18_house_garden_entrance.png)
- [19_earned_and_future_keepsakes.png](19_earned_and_future_keepsakes.png)

## Limits and exact remaining verification

- Visitors use authored garden/patio routes, not autonomous whole-house/town navigation. Their relaxing pose is standing with reserved idle motion rather than a production seated animation. There is no romance, family or online system.
- Procedural characters and scenery remain stylized and simple. Free orbit can still produce unflattering close angles; the automatic views reduce obstruction but are not a cinematic camera director. Garden catalog items include both geometry and finishes, consistent with the original preview architecture.
- Six authored events and three crops provide bounded variety, not unlimited simulated content. Plants do not die, and basic cooking never requires harvested supplies.
- The complete short rendered loop and two restart journeys are verified. Close Friend's seven-shared-day unlock, all six event conditions and all six request variations are covered by rule/session contracts; a genuine seven-day GUI marathon for every variation is **not completed**. No screenshot claims that unplayed later relationship state.
- **Windows execution/export, hardware performance and audible playback are UNVERIFIED.** Linux software-rendered runtime and resource decode were tested; Dummy audio is not listening evidence.
- No core gardening → visitor → reward loop item is left incomplete. Full seated visitor animation and exhaustive multi-day rendered coverage are the explicit secondary omissions above.
