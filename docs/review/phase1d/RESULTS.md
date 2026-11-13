# Phase 1D — A home that responds

The existing lamp, curtains and left houseplant now respond to E through the shared range/facing/visibility resolver. Unknown IDs do nothing; seated E still stands. Every modal blocks world actions. Lamp and curtain transitions reverse from their current state without accumulating light. Watering has a short cooldown, leaf movement and nine reusable drops.

The optional H checklist recognizes actions performed before discovering it. A settled lamp-on/curtains-closed/watered-once arrangement earns one original miniature house on the existing shelf. Later room changes do not revoke it. Existing onboarding flags remain intact.

Reward saves now show Retry only on failure, move focus after recovery, and never duplicate progression. Action icons distinguish Apply/Cancel/Restart/Play/Settings. Decor shows a persistent selected check/border, separate gold focus, lock icons, and an honest Mixed whole-room selection.

Schema 3 adds stable room-state booleans, permanent completion and optional hint dismissal. Exact schema 1/2 backups, atomic replacement, last-good recovery, unknown fields, future-schema protection and all Phase 1C data remain supported. Animations and transient watering never serialize.

## Verification

Godot 4.6.3, cloud Linux, Compatibility/llvmpipe, isolated XDG data roots. Rendered tests use actual keyboard/mouse events and GUI callbacks. Reward screenshots follow a genuine six-pair win; cozy completion follows actual walks and E interactions. The failure/retry test temporarily creates a directory at the isolated fixture's `.tmp` path, verifies the old file survives, removes that empty test directory, and retries through the UI.

Commands use `XDG_DATA_HOME=/workspace/.runtime/<suite>` plus writable config/cache roots; rendered commands additionally use `DISPLAY=:99 --audio-driver Dummy`. No personal saves are read or modified.

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/<contract>.gd
godot --audio-driver Dummy --path . --script res://tests/phase_one.gd
godot --audio-driver Dummy --path . --script res://tests/phase1c_flow.gd
godot --audio-driver Dummy --path . --script res://tests/phase1c_flow.gd -- --legacy
godot --audio-driver Dummy --path . --script res://tests/ui_focus.gd
godot --audio-driver Dummy --path . --script res://tests/phase1d_flow.gd
godot --audio-driver Dummy --path . --script res://tests/phase1d_flow.gd -- --resume
```

The final resume command launches a separate process after the actual Quit button closes the first process, using its isolated saved session. Phase 1C regression images go to `/tmp`, leaving historical review images unchanged.

All **263/263 checks passed**; each process exited 0. Editor import completed without script/resource errors. Full output is retained in [logs/](logs/).

| Suite | Result |
|---|---:|
| Original rendered Phase 1 | 22/22 |
| Save / style / pairs / session contracts | 12/12 · 17/17 · 16/16 · 17/17 |
| Phase 1C rendered fresh / legacy | 33/33 · 31/31 |
| Rendered keyboard focus | 7/7 |
| Phase 1D UI / room / migration contracts | 13/13 · 34/34 · 10/10 |
| Phase 1D rendered interactions / separate-process Continue | 46/46 · 5/5 |

Negative tests intentionally report blocked writes and a corrupt ConfigFile parse error. Normal rendered runs have no script/resource errors. The software driver warns that V-Sync is unavailable.

## Genuine runtime images

All primary captures are 1280×720; Decor also checked at 1920×1080. Images were inspected for clipping, readable selection/focus/locks, visible prop differences and the physical shelf reward. Lamp and curtain comparison pairs retain identical camera settings and player position. The closed-curtain review caught an additive morph error; absolute normalized blending fixes it, with a regression assertion.

| Image | Evidence |
|---|---|
| [before_room.png](before_room.png) | Running baseline before Phase 1D edits |
| [lamp_off.png](lamp_off.png) / [lamp_on.png](lamp_on.png) | Warm shade and restrained local light |
| [curtains_open.png](curtains_open.png) / [curtains_closed.png](curtains_closed.png) | Fabric opens/closes; rod/window stay fixed; ties retract |
| [watering.png](watering.png) | Watering effect in progress |
| [cozy_corner.png](cozy_corner.png) | Completed arrangement and shelf keepsake |
| [keepsake_detail.png](keepsake_detail.png) | Physical miniature house close view |
| [puzzle_reward_saved.png](puzzle_reward_saved.png) | Successful save after real failure/retry; Retry hidden |
| [decor_selected_locked.png](decor_selected_locked.png) | Mixed selection, persistent checks, separate focus and locks |
| [continued_room.png](continued_room.png) | Actual Quit → new process → Continue, restored settled room |

## Limits

Procedural art and lighting remain lightweight. Curtains reduce the existing window fill; they do not simulate global illumination. Watering is a brief response, not a plant-growth system. The tiny keepsake plaque is decorative at normal camera distance. Six PCM cues decode successfully, but audible playback remains unverified with the dummy driver. Windows export, performance and audible Windows playback remain untested. Optional video was not recorded.
