# Dream World 3D — Phase 2C Windows playtest

## Build and verification status

Godot **4.6.3-stable**, Windows Desktop **x86_64**, Compatibility renderer.
The Windows release export is prepared from the checked-in `export_presets.cfg`.
The executable and separate PCK must stay together. Large build artifacts are ignored by Git.

**Native Windows execution, audible playback, hardware FPS and human enjoyment are UNVERIFIED.**
Linux software-rendered journeys and save tests are separate evidence; producing a PE executable does not establish Windows playability.

## Reproduce the export

1. Open `project.godot` in Godot 4.6.3.
2. Install the matching official 4.6.3 export templates through Editor → Manage Export Templates. The cloud build verified the official template archive against its published SHA-512 checksum.
3. Project → Export → Windows Desktop → Export Project, release mode. Keep the default `builds/windows/DreamWorld3D.exe` path, or choose an empty output directory.
4. Alternatively, run `godot --headless --path . --export-release "Windows Desktop" builds/windows/DreamWorld3D.exe` with matching templates installed.
5. Distribute `DreamWorld3D.exe`, `DreamWorld3D.pck`, the playtest guide and the Godot license together. This release is unsigned; no signing identity is configured.

Cloud artifacts: `builds/windows/` and `builds/DreamWorld3D-Phase2C-Windows.zip`.
The retained export log and artifact manifest are in `docs/review/phase2c/logs/`.
The output is checked for a Windows x86_64 PE header and a valid Godot PCK magic header. Those are structural checks, not execution tests.

## Controls

WASD moves relative to the camera; Shift runs. Mouse orbits; wheel zooms.
E interacts. Esc closes the current panel or pauses. C personalizes, B decorates,
Q opens goals, J catalog, L Cozy Connections, T hints, H cozy corner, F1 controls.
Esc cancels an unfinished shared activity safely; finish with **Keep this memory** to save its result.

## First ten minutes

- Use a separate OS user or back up the existing save before a human test. Do not delete a real player's save.
- Walk around the living room, kitchen and bedroom. Orbit near walls and pass through each doorway.
- Find the east-side garden entrance. Approach Mimi and use E; choose a conversation response.
- Ask about **Our stories** and begin Mimi's baking surprise. Choose **Shared activities → Cozy tea time**, then a blend.
- Watch both characters walk to their places and sit. Confirm cups are visible; finish the memory.
- Ask Noah to rest on the garden bench, then step out of his path. Watch him sit and stand again when approached.
- Plant strawberries and lavender. Water them, cook or rest, then sleep. No real-world waiting is required.

## Multi-day stories

Mimi: begin her story → harvest a fresh strawberry (one is set aside) → plate Berry Cupcakes → share tea. The cake cloche stays in the kitchen.

Noah: begin his story → plant lavender → water it → sleep/harvest it → replant a dry crop → choose Garden help. His garden corner becomes permanent.

Housewarming: meet both friends and finish one personal story → begin the gathering in Stories → plate a meal → share a garden picnic with both visitors → ring the gathering bell → keep the group toast. The lantern memory stays outside. All chapters are optional and have no deadline.

## Human test checklist

- [ ] First ten minutes are understandable without this guide; record where guidance was missing.
- [ ] All three recipes accept real inputs; free supplies remain available and optional produce never blocks a recipe.
- [ ] Plant, water, grow, harvest and replant each crop. Repeated watering/harvest cannot create duplicate rewards.
- [ ] Mimi and Noah remain distinct, stop at collisions and can be invited back. Clear their path if they politely wait.
- [ ] Bench/table/picnic poses look grounded; no overlapping seats, stuck legs or unrecovered interrupted activities.
- [ ] Both tea blends and picnic choices have their own feedback. Activity friendship benefits stop after the daily limit.
- [ ] Complete each story, sleep, Quit, relaunch and Continue. Confirm currencies, crops, friendships and physical memories.
- [ ] Check goals, story pages, journal pages, long text and Help at 1280×720 and 1920×1080.
- [ ] Check volume/mute, quiet ambience, sitting/standing, shared activity and story feedback on real speakers/headphones.
- [ ] Record actual hardware/OS, resolution, renderer, frame timing and any stutter. Do not generalize cloud software-renderer timings to hardware FPS.
- [ ] Cancel an activity before claiming; restart it. Confirm no lost ingredient, friendship or one-time story reward.

Record observations, build commit and reproduction steps. Unchecked items are not a verified human playtest.
