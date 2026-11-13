# Phase 1C — Make It Mine, Play & Unlock

Extended the existing clean `work` baseline `dcb9b26`; no reset, new worktree, renderer change or Phase 2 expansion.
Current scope, extension points, schema and deferred roadmap live in [PROJECT_STATUS.md](../../PROJECT_STATUS.md).

## Delivered

- Live avatar name/hair/outfit personalization with six swatches, built-in HSV wheel, Apply/Cancel and full camera restoration.
- Independent rug/cushion/curtain palettes and whole-theme preview; locked Lavender Dream explains its unlock condition.
- Reachable 3D coffee-table card box, one visibility/facing/range interaction target, and preserved sofa seating.
- Shuffled 4×3 Cozy Pairs with original icon art, flips, counters, matched states and safe Restart/Exit.
- One first-win theme unlock, real-room application or deferral, and saved personal-best replays.
- Exclusive UI/input ownership, skippable persisted guidance, short notices and four original local UI sound cues with volume/mute.
- Additive schema 2 migration, exact legacy backup, retained last-good save and confirmed-only persistence. No personal saves were fixtures.

## Actual verification

Godot **4.6.3**, OpenGL Compatibility, cloud Linux/X11 with software rendering. Every final command exited **0**.

| Check | Passed |
| --- | ---: |
| Editor import | passed; no script/resource errors |
| Original rendered integration (unchanged assertions) | 22/22 |
| Save migration/malformed data/real temporary-write failure | 12/12 |
| Appearance/decor isolation, Apply/Cancel, preview exclusion | 17/17 |
| Pair rules, shuffle, rapid guards, resolution, abort, completion once | 16/16 |
| Interaction visibility, seating/panels, progression/replay/reload, audio data | 17/17 |
| Full rendered fresh-save first session + Continue | 33/33 |
| Full rendered legacy-save first session + Continue/deferral | 31/31 |
| Rendered keyboard Tab/Enter/Esc/focus smoke | 7/7 |

The 155 checks include capture/layout assertions. Rule/controller fixtures and actual rendered GUI/input flows are separate checks.
The win shown below was reached by clicking all six shuffled pairs through the real card UI; completion was not fabricated for images.
Both flows tested 1280×720 and a rendered 1920×1080 personalization layout. Images were manually inspected for clipping,
legibility, color differences, overlap and avatar/room visibility. Tests prove behavior, not that players will find it fun.

**Expected fault output:** save/style contracts deliberately provoke an unwritable temporary path, malformed config and blocked Apply.
Their error/warning messages are expected; they assert that existing/last-good data survives. Normal rendered runs had no script/resource errors.
Unsupported V-Sync on the cloud display is nonblocking. Audio: four non-silent 22,050 Hz PCM WAVs decode; rendered cues use the dummy driver.
Audible output is **not verified**. Windows export, Windows testing and GPU benchmarking were **not performed**.

## Genuine, unedited runtime review PNGs

All nine are 1280×720. Relative paths and SHA-256 hashes are recorded in [captures.json](captures.json).
Before views use the Phase 1B entry scene; after views follow real first-session UI/actions and saved positions.

| View | Repository-relative path |
| --- | --- |
| Before avatar/menu | [docs/review/phase1c/before/avatar_menu.png](before/avatar_menu.png) |
| Before room | [docs/review/phase1c/before/room_gameplay.png](before/room_gameplay.png) |
| Personalization | [docs/review/phase1c/after/personalization.png](after/personalization.png) |
| Decor preview | [docs/review/phase1c/after/decor_preview.png](after/decor_preview.png) |
| Puzzle in progress | [docs/review/phase1c/after/puzzle_in_progress.png](after/puzzle_in_progress.png) |
| Earned result | [docs/review/phase1c/after/earned_reward.png](after/earned_reward.png) |
| Applied real room | [docs/review/phase1c/after/applied_room.png](after/applied_room.png) |
| Saved room after Continue | [docs/review/phase1c/after/continued_room.png](after/continued_room.png) |
| Legacy migration + Continue | [docs/review/phase1c/after/continued_legacy.png](after/continued_legacy.png) |

## Reproduce

From `/workspace/DREAM-WORLD-3D`, with the existing display `:99` (see README/cloud start instructions):

```sh
export DISPLAY=:99 XDG_CONFIG_HOME=/workspace/.runtime/config XDG_CACHE_HOME=/workspace/.runtime/cache
XDG_DATA_HOME=/workspace/.runtime/phase1c-tests godot --headless --path . --editor --import --quit
for suite in save_contract style_contract pairs_contract session_contract; do
  XDG_DATA_HOME=/workspace/.runtime/phase1c-tests timeout 30 godot --headless --path . --script res://tests/$suite.gd || exit $?
done
XDG_DATA_HOME=/workspace/.runtime/phase1c-regression godot --audio-driver Dummy --path . --script res://tests/phase_one.gd
XDG_DATA_HOME=/workspace/.runtime/phase1c-flow timeout 600 godot --audio-driver Dummy --path . --script res://tests/phase1c_flow.gd
XDG_DATA_HOME=/workspace/.runtime/phase1c-flow timeout 600 godot --audio-driver Dummy --path . --script res://tests/phase1c_flow.gd -- --legacy
XDG_DATA_HOME=/workspace/.runtime/phase1c-focus timeout 120 godot --audio-driver Dummy --path . --script res://tests/ui_focus.gd
```

Final output is retained under [logs/](logs/). Each fixture has an isolated path; unfinished puzzle rounds are intentionally not persisted.
Remaining limits: procedural art/rig and contact shading remain below the premium target; one short puzzle is not hours of content.
No profiles, furniture placement, additional rooms, shops, currencies, daily systems or extra mini-games were added.
