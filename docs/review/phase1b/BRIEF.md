# DREAM WORLD 3D — PHASE 1B: VISUAL OVERHAUL + PERMANENT SCREENSHOT RULE

You are continuing the EXISTING Godot 4.6.3 project in `fahim23022003-ai/DREAM-WORLD-3D`. Phase 1 reportedly passes 22/22 rendered integration checks. **Preserve all working gameplay and saves.** This is a focused *art-quality and presentation pass*, NOT a new project or Phase 2 gameplay expansion.

## Objective

Raise the existing playable scene toward a **premium, cohesive Cute Pastel 3D life-sim look**. Target beautiful, believable stylized 3D like high-quality cozy dollhouse concept images: pink, baby blue, lavender, cream and mint, soft warm light, rounded but detailed geometry, attractive textures/materials, expressive avatar and polished UI.

The images in the user's reference conversation are a **visual target**, not already available game assets. If reference images are attached to this task, use them directly. Do not claim the target was fully achieved unless actual Godot screenshots support it.

## Workflow (do this in order)

1. Inspect the current relevant scenes, scripts, materials, assets, screenshots and tests once. Do not blindly rebuild working systems. Run the existing app and capture **two genuine BEFORE screenshots** (room/gameplay and avatar/menu) to `docs/review/phase1b/before/`.
2. Identify the **five biggest visible quality gaps** and fix the high-impact ones first. Spend effort where an ordinary player will actually notice. Avoid cosmetic micro-edits that are invisible at the normal camera distance.
3. Implement the improvements below, preserving Godot 4.6.3 compatibility and smooth Windows PC playability.
4. Run the existing integration suite and a focused manual/rendered smoke test. Fix new regressions. Capture **AFTER screenshots** from the real running game, commit the image files, and include clickable relative Markdown links to them in the final report. If rendering is impossible, explain why; never substitute mockups or AI-generated concepts for actual gameplay captures.

## Visual improvements — priorities

### P0: 3D room, furnishings and composition

- Make the living room feel intentionally art-directed and lived-in: coherent scale, warm accent lighting, attractive focal point, breathing room, balanced prop placement and clear walking routes.
- Replace *visibly crude* boxes/cylinders where practical with rounded/beveled silhouettes and recognisable layered furniture forms: cushions, sofa arms/legs, table edges, drawers/handles, lampshades, curtain folds, window frames, skirting/baseboards, rug depth and plants. Prefer well-made detailed props over adding dozens of low-quality ones.
- Improve materials using appropriate roughness, softness, fabric/wood/glass/ceramic distinctions, small details and consistent texture scale. Avoid a flat monochrome plastic look, noisy textures, random mismatched asset styles and over-saturation.
- Improve window daylight, soft contact shadows, subtle ambient shading, exposure/tone mapping and anti-aliasing while keeping performance sensible. No blown highlights, muddy dark corners or excessive bloom. Use the engine's supported 3D settings rather than expensive gimmick shaders.

### P0: Avatar appearance and movement

- Upgrade the *actual 3D avatar* to a charming, recognisable character rather than a placeholder: cohesive chibi/stylized proportions; readable face with eyes, brows and expressive details; attractive volumetric hair masses/clumps; layered outfit with cuffs/seams/accessories and distinct materials.
- Keep hair and clothing modular for future Avatar Creator/color wheel. Ensure no mesh intersections, detached hair, floating hands or awkward proportions.
- Improve idle/walk/run transitions, turning and sitting/standing alignment, grounded feet and animation timing. Avoid visible foot sliding, abrupt snapping and awkward sofa penetration. Do not break movement or camera collision.

### P1: Camera, interface and first impression

- Improve default gameplay camera framing so avatar and room look attractive together; preserve mouse orbit, pitch limits, scroll zoom and collision, including near walls and furniture.
- Give Main Menu, Settings, Pause and the E-to-sit prompt a cohesive pastel visual language: clear hierarchy, readable text, intentional spacing, rounded or slightly dimensional controls, meaningful icons, hover/focus states and subtle transitions. Avoid generic flat grey rectangles and giant text overlays that hide the scene.
- Use restrained feedback (UI click/hover sounds or subtle room ambience only if copyright-safe, easy and already supported); do not turn this into a music-production task.

## Do NOT do in this task

- No full Avatar Creator, second floor, furniture placement editor, mini-games, economy, multiplayer or broad new systems.
- No unrelated architectural rewrite, asset-download spree, external paid services or copyrighted game assets.
- No deletion of working tests or saves to make failures disappear.
- No fabricated screenshots, concept art presented as gameplay or claims of pixel-identical quality.

## PERMANENT RULE FOR EVERY FUTURE CODEX TASK

Add/update a short root-level `AGENTS.md` (preserve existing instructions) with this standing requirement:

> At the end of EVERY future Dream World 3D task, whenever rendering is available, capture and provide at least one **genuine screenshot from the running Godot game** that demonstrates the current result. For visual/UI/gameplay changes, provide relevant multi-angle screenshots (typically main menu, avatar, room, affected feature). Store review screenshots under `docs/review/<task-name>/`, commit them, and link each image in the final response using clickable GitHub URLs targeting that branch/commit, plus repository-relative paths. Never use generated concept art or an editor-only mockup as proof of gameplay. If screenshot capture fails, state exactly why. Include concise verification status and known visual gaps. Preserve functioning features and avoid unrelated changes.

Make this instruction apply automatically to later tasks so the user can evaluate changes without having to run the game on an office PC.

## Final deliverables and acceptance

- Preserve or improve the reported 22/22 checks; run tests with actual commands and report their real result. Verify F5 entry scene and quit. If new screenshots require a display server, use the existing project screenshot/test workflow.
- Provide at least these **AFTER** PNGs at 1280x720 or higher: `main_menu.png`, `room_wide.png`, `avatar_closeup.png`, `sofa_interaction.png`. They must be authentic captures of the playable build, not promotional concept imagery. Also provide a before/after room comparison if convenient.
- Commit all code/assets, `AGENTS.md`, screenshots and a short `docs/review/phase1b/RESULTS.md` noting actual improvements and any remaining gaps. Push to the active task branch; report branch and commit. Do not assume `main` if the task uses a work branch.
- Keep the final response concise: tests; 5 most visible improvements; direct screenshot links; what remains below the visual target; branch/commit. **The screenshots are mandatory deliverables.**
- Stop after Phase 1B. Do not automatically start Phase 2.