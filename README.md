# Dream World 3D — Rosewater House

Phase 1 playable slice with the **Phase 1B visual overhaul**. Godot **4.6.x**, GDScript, Windows PC target.
Entry point: `scenes/main.tscn`. Open `project.godot` in Godot 4.6.x and press **F5**.
No downloads, asset packs, services, accounts or application network access required.

## Play

- Choose **Come on in** / **Continue home**. WASD moves relative to the camera; Shift runs.
- Move the mouse to orbit; scroll to zoom. The spring arm retracts against room geometry.
- Approach the front of the sofa from either side of the coffee table. Press **E** at the prompt to sit; E stands.
- **Esc** pauses and releases the mouse. Resume or return to the main menu.
- Settings changes mouse sensitivity, fullscreen and sunlight shadows. Menus also accept keyboard focus/Enter.
- Position and settings save every 20 seconds, on pause, on menu return and on quit.
  A seated player reloads at the clear standing point, rather than inside the sofa.
- Local save: `user://rosewater.cfg` (Windows: `%APPDATA%/Godot/app_userdata/Dream World 3D/`).
  Delete that file to reset. Failed writes show “Save unavailable”.

## Structure

`scenes/` contains independent room, prop, avatar, player, camera, interaction and menu scenes.
`scripts/forms.gd` shares rounded original geometry and cached materials; `prop.gd` is a small reusable furniture catalogue.
The avatar separates hair, face, blouse, pinafore and pivoted limbs. `save_data.gd` keeps persistence separate from gameplay.
`docs/MASTER_SPEC.md` retains the supplied future vision; only Phase 1 is implemented.
Future creator/catalogue/house/minigame systems can add content alongside these scenes without replacing movement or UI.
`assets/textures/` contains original vector linen, ash wood, botanical print and rug art; no downloaded assets are used.
The root `AGENTS.md` requires genuine committed gameplay screenshots at the end of future tasks.

## Verification

Run the focused integration pass in a desktop session:

```sh
godot --path . --script res://tests/phase_one.gd
```

Use a separate OS user-data directory for tests: they intentionally write a local position/settings save.
On Linux, prefix with `XDG_DATA_HOME=/tmp/dream-world-test`. Rendered tests exercise GUI buttons,
WASD/run, wall/sofa collision, seating, mouse orbit, pitch bounds, zoom, spring-arm collision,
pause/resume, main menu, save reload and quit. They write screenshots to `/tmp/dream-{menu,seated,play}.png`.
Headless import: `godot --headless --editor --path . --import --quit`.
The full integration pass requires a display for captured-mouse verification.

Verified in Godot **4.6.3** on the cloud Linux desktop: **22/22 integration checks passed**,
followed by a clean exit code 0 through the Quit button. Editor import completed without script/resource errors.
Rendered screenshots were inspected: [room](docs/screenshots/living-room.png),
[sitting](docs/screenshots/sofa-interaction.png), [main menu](docs/screenshots/main-menu.png).
Those are the original Phase 1 captures. Current Phase 1B review images and commands are in
[the Phase 1B report](docs/review/phase1b/RESULTS.md), including genuine before/after captures.
The software renderer reports an unsupported V-Sync warning; this does not block play.

Cloud sandbox: set `XDG_DATA_HOME`, `XDG_CONFIG_HOME`, `XDG_CACHE_HOME` to writable directories outside the checkout.
The environment startup instructions contain the verified paths and display startup command.

## Known limits

Visual quality remains **below the premium concept-art target**. Phase 1B adds original fabric/wood textures,
tailored furnishings, tapered hair, expressive facial detail, layered clothes, a botanical rug, cooler bounce fill,
4× MSAA and filtered sunlight shadows. It still lacks baked bounce lighting, ambient occlusion,
production character sculpting and high quality contact shadows.
Idle/walk/run and sitting use procedural part animation, not a production skeletal animation set.
The room has no ceiling to preserve the playable slice's open composition. Windows show a stylized static garden.
No audio, customization, decoration editor, second floor, profiles or minigames in Phase 1.
Linux Godot 4.6.3 was used for verification; Windows executable export and desktop performance remain unverified.
For Windows distribution, install matching Godot export templates and create a Windows Desktop export in the editor.
The project uses the Compatibility renderer for broad desktop support. Geometry and materials are original;
there are no third-party art assets.

Recommended next phase: art refinement of this one room/avatar before expanding gameplay scope.
