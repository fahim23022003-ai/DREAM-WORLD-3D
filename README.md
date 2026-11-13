# Dream World 3D — Rosewater House

Phase 1 playable slice with **Phase 2C The Cozy Life Experience**. Godot **4.6.x**, GDScript, Windows PC target.
Entry point: `scenes/main.tscn`. Open `project.godot` in Godot 4.6.x and press **F5**.
No downloads, asset packs, services, accounts or application network access required.

## Play

- Choose **Come on in** / **Continue home**. WASD moves relative to the camera; Shift runs.
- Move the mouse to orbit; scroll to zoom. The spring arm retracts against room geometry.
- Approach the front of the sofa from either side of the coffee table. Press **E** at the prompt to sit; E stands.
- Approach the floor lamp, curtain pull by the right window edge, or left houseplant and press **E** at its prompt. Toggle the lamp, open/close the curtains, or water the plant.
- **H** toggles the optional cozy-corner checklist. Lamp on + curtains closed + a watered plant earns a permanent bookshelf keepsake; there is no timer.
- Walk through the **left rear arch** into the kitchen or **right rear arch** into the bedroom. Both rooms connect physically; no teleport buttons.
- Kitchen: **E at the blue fridge** chooses free recipe ingredients → E at the wooden board prepares → E at the stove cooks → E at the board plates. Space/click times actions; cupcakes and soup also use ingredient choices **1/2/3**. Every attempt produces Cozy, Good or Perfect food; supplies are never lost.
- Walk through the **right-side living-room doorway** into the garden. **E** at any of three planters selects free strawberry, carrot or lavender seeds. Water once; cooking/rest shows growth, then sleep readies the crop. Harvest and replant; plants never die offline. The basket holds 9 of each crop.
- Meet **Mimi** and **Noah** on the garden paths and press **E**. Choose a conversation, accept a small request, or share freshly cooked food. Requests have no deadline and survive sleep/Continue. **L** opens Cozy Connections: relationships, invitations, optional events, produce discoveries and permanent keepsakes.
- Friend: 4 XP. Close Friend: 10 XP **and seven distinct shared in-game days**. Daily chats, shared food and requests have reward limits; repeated clicks cannot farm friendship. There are no real-world login timers.
- One optional event varies each day: a surprise visit, garden bloom, baking day, lost ribbon, friendship afternoon or moonlit patio. Event details in L point to the real activity. The garden bench advances the light.
- The recipe pantry offers an **optional harvest topping** (+2 coins, consumes one matching produce if available). Existing free supplies and all three recipes still work without gardening.
- **T** hides/restores hints. Cooking, visitor promises and garden discoveries share one priority hint instead of competing boxes.
- **Q** opens Daily Cozy Goals and **J** opens kitchen/bedroom finishes. Catalog previews cost nothing. Buy & equip confirms cost and permanent ownership together; owned finishes equip free.
- Meals, the card game and the bedroom rest bench advance Morning → Afternoon → Evening → Night. At the bed, **E near its foot makes it**, and **E by the left pillow offers sleep**. Sleeping saves a new morning and fresh goals; there is no hunger, energy or offline penalty.
- Three daily goals pay 3 coins each; completing the set pays 6. First meal per recipe/day pays 6, second pays 2, further practice pays no meal coins. Goals and milestones never pay twice. Complete three cozy days for a bedside keepsake and seven for a commemorative frame; daily play continues afterward.
- **C** opens Personalize; name, hair and outfit colors preview on the actual avatar. Apply saves; Cancel/Esc restores.
- **B** opens Decor: choose rug/cushion/curtain palettes independently or preview a whole theme. Apply confirms.
- Approach the little card box on the coffee table, face it and press **E** for Cozy Pairs. Find six pairs; no timer or failure penalty.
- The first completed round unlocks Lavender Dream. Apply it immediately or keep your style and select it later in Decor. Replays improve your own best.
- **Esc** closes the topmost UI or pauses. Panels release the mouse and block world input; opening one while seated keeps you seated.
- Small hints can be hidden; completion/dismissal survives Continue.
- Settings changes mouse sensitivity, fullscreen, sunlight shadows and UI sound volume/mute. Menus also accept keyboard focus/Enter.
- Position and settings save every 20 seconds, on pause, on menu return and on quit.
  A seated player reloads at the clear standing point, rather than inside the sofa.
- Local save: `user://rosewater.cfg` (Windows: `%APPDATA%/Godot/app_userdata/Dream World 3D/`).
  Schema 6 migration preserves prior data and makes a `.v1.bak`, `.v2.bak`, `.v3.bak` `.v4.bak` or `.v5.bak`; atomic writes retain `.last_good`.
  Failed writes retain the previous save. Previews and unfinished puzzle rounds are never saved.

## Structure

`scenes/` contains independent room, prop, avatar, player, camera, interaction and menu scenes.
`scripts/forms.gd` shares rounded original geometry and cached materials; `prop.gd` is a small reusable furniture catalogue.
The avatar separates hair, face, blouse, pinafore and pivoted limbs. `save_data.gd` keeps persistence separate from gameplay.
`docs/MASTER_SPEC.md` retains the supplied future vision; only the bounded Phase 1/1B/1C/1D/2A/2B/2C features are implemented.
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

Original Phase 1 verification in Godot **4.6.3** on the cloud Linux desktop: **22/22 integration checks passed**,
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
Phase 2A adds two rooms, three station-based recipes, day/goal progression and six purchasable room finishes. After neighborhood discovery, three daily goals vary with garden readiness and recent activities. Phase 2B adds a garden, two recurring visitors, friendships, requests, six optional events and six further catalog upgrades. Visitors use collision-safe garden/patio waypoints; there is no town-wide simulation, furniture placement editor, second floor or profiles.
Thirty short original UI/interaction sounds are bundled; cloud audible playback remains unverified.
Linux Godot 4.6.3 was used for verification; Windows executable export and desktop performance remain unverified.
For Windows distribution, install matching Godot export templates and create a Windows Desktop export in the editor.
The project uses the Compatibility renderer for broad desktop support. Geometry and materials are original;
there are no third-party art assets.

Current scope, save schema and actual extension points: [PROJECT_STATUS.md](docs/PROJECT_STATUS.md).
Phase 2C retains the **762-check Phase 1–2B regression baseline** and adds story, shared-activity, seating, migration and rendered restart verification. The final run passed **1149/1149 checks** across 36 suites (387 new checks). Matched software-renderer timings improved 21.52–33.40%; details are in the current report. Windows native execution, hardware performance and audible playback remain unverified.
Latest commands, results and genuine review images: [Phase 2C report](docs/review/phase2c/RESULTS.md).

## Cozy Life stories and shared moments

Approach a friend with E → **Shared activities** for tea, picnic or garden help, or **Our stories** to begin a personal chapter. L separates friends, stories, keepsakes and discoveries. F1 opens the full controls; the HUD keeps only contextual guidance.

Mimi's story uses a freshly harvested strawberry (one is set aside), Berry Cupcakes and shared tea. Noah's story uses lavender planting/watering/harvesting and help with a dry crop. Meet both friends and finish a personal story to begin the housewarming; prepare a meal, picnic together and ring the garden bell. Each completed arc creates a permanent physical memory. No chapter has a deadline, and shared activity benefits are bounded per friend/day.

Sleep after discovering these moments to see a compact, skippable day summary. Existing free recipes, requests, daily goals, currency and customization remain playable.

Verification: `python3 tools/verify_phase2c.py --headless --include-new`, then `python3 tools/verify_phase2c.py`, then `python3 tools/verify_phase2c.py --stories`. Rendered tests run sequentially on DISPLAY=:99 and use isolated XDG roots. See the report for the matched baseline benchmark procedure and genuine images.

Windows export and human checklist: [Windows playtest guide](docs/WINDOWS_PLAYTEST.md). Release artifacts remain outside source control in `builds/`.
