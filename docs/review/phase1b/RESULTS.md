# Phase 1B — visual overhaul

Built and reviewed in Godot **4.6.3** using the actual OpenGL Compatibility game on the cloud X11 display.
All review PNGs are unedited **1280×720 game-viewport captures**. No concept/generated images are used.
The original Phase 1 source was present as uncommitted files on an unborn `work` branch; the branch was
anchored to the remote's existing README commit before committing the complete playable project and this pass.

## Five visible gaps addressed

1. **Harsh yellow light and jagged silhouettes:** cooler ambient fill, restrained warm sunlight/exposure,
   4× MSAA, higher-resolution filtered shadows. No bloom or expensive custom shaders.
2. **Flat, primitive furniture/materials:** finer rounded bevels, sofa piping/tufts/throw, a two-tier wood-grain table,
   glazed vases, cup handle, pleated lampshade, shaped leaves and a pale blue bookcase with basket.
3. **Sparse composition and obstructed window:** original botanical rug and print, mint wainscot, draped fabric curtains,
   drawer handles, one coordinated side-table flower arrangement; the print is moved off the window.
   Existing collision envelopes and walking routes are retained.
4. **Stiff doll styling:** tapered chestnut hair locks, hazel eyes/glints/brows/smile, lavender bow,
   layered periwinkle pinafore, collar, daisy pocket, cuffs, socks and shoe straps. Knees bend, gait blends
   and timing follow actual speed, the skirt tips into the seated pose, and standing has a short visual ease.
5. **Oversized/low-contrast UI:** smaller cream/lavender cards, original house/settings/leaf icons,
   hover/focus states, subtle page fades, readable HUD plates and mint/lavender settings toggles.

`AGENTS.md` now requires committed genuine gameplay screenshots and commit-specific GitHub links in every future task.
Player position/settings schema and the existing 22 integration assertions are preserved.

## Genuine review images

| View | Before | After |
| --- | --- | --- |
| Matching room camera | [room_gameplay.png](before/room_gameplay.png) | [room_comparison.png](after/room_comparison.png) |
| Main menu / avatar | [avatar_menu.png](before/avatar_menu.png) | [main_menu.png](after/main_menu.png) |
| Room wide | — | [room_wide.png](after/room_wide.png) |
| Avatar close-up | — | [avatar_closeup.png](after/avatar_closeup.png) |
| Sofa interaction | — | [sofa_interaction.png](after/sofa_interaction.png) |
| Settings | — | [settings.png](after/settings.png) |
| Pause | — | [pause.png](after/pause.png) |

The matching room pair uses the same player position `(0,0,1.8)`, yaw `0.24`, pitch `0.34`, distance `5.2`, FOV `62`.
Other after views use the working camera rig and alternate gameplay positions/zoom; the avatar close-up uses the actual 2 m zoom limit.

## Verification and reproduction

From `/workspace/DREAM-WORLD-3D`, with the existing Xorg display `:99`:

```sh
export DISPLAY=:99
export XDG_CONFIG_HOME=/workspace/.runtime/config
export XDG_CACHE_HOME=/workspace/.runtime/cache
XDG_DATA_HOME=/workspace/.runtime/data godot --headless --path . --editor --import --quit
XDG_DATA_HOME=/workspace/.runtime/phase1b-test-data godot --audio-driver Dummy --path . --script res://tests/phase_one.gd
XDG_DATA_HOME=/workspace/.runtime/phase1b-review godot --audio-driver Dummy --path . --script res://tests/capture_review.gd
```

The rendered suite passed **22/22**, then the GUI Quit button produced **exit code 0**.
It exercises real input events for WASD/run, wall/sofa collision, proximity/sitting/standing,
orbit/pitch/zoom, spring-arm collision, main/settings/pause/resume, save reload and quit.
Tests and captures use separate user-data directories and leave real saves intact.
The capture script also operates E-to-sit/stand and Escape in the running game.
Current import, integration and capture output is retained alongside this report.

F5 was sent to the actual Godot editor through native X11 input; the configured `scenes/main.tscn`
opened as a playable game. Native mouse input opened Settings and switched sunlight shadows off;
the saved setting changed to `shadows=false`. Native Done/Quit clicks returned to the menu and closed the game.
The Compatibility game renders despite a nonblocking
editor Vulkan capability probe reporting missing `VK_KHR_surface` on this machine. The software
display also reports unsupported V-Sync, and the F5 child falls back to dummy audio because this host has no sound device.
These capability probes do not block play; there were no missing script/class/resource errors.

## Remaining visual gaps and platform limits

Still **below the premium concept-art target**: the character is a procedural doll rather than a production sculpt/rig,
hair clumps and facial shadows remain somewhat geometric, and real-time Compatibility lighting lacks baked bounce/AO
and high quality contact penumbrae. The room is deliberately open above, with a static stylized garden.
There is no audio. Windows executable export and hardware performance have not been verified; cloud llvmpipe timing
is not a Windows GPU benchmark. No Phase 2 gameplay was added.

Original SVG/material provenance is in [`assets/README.md`](../../../assets/README.md).
Open `project.godot` in Godot 4.6.x and press F5; controls remain WASD, Shift, mouse/wheel, E and Escape.
