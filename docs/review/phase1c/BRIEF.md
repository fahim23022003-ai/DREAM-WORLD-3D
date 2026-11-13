DREAM WORLD 3D — PHASE 1C: MAKE IT MINE, PLAY & UNLOCK

Implement this bounded phase in the EXISTING project. Deliver working code, tests and genuine in-game screenshots, not another proposal.

1. BASELINE AND SCOPE

Repository: fahim23022003-ai/DREAM-WORLD-3D

Known baseline: branch work, commit dcb9b26d61da23e7bbea03b8821e0d6095ccdaa2.

Use the latest relevant task branch containing Phase 1B; preserve newer work. Verify checkout, branch and dirty state first.

Do not reset, recreate the project, create another worktree, overwrite unrelated changes, or start from a README-only main branch. Resolve the correct existing checkout safely; stop only for a genuine conflict or access blocker.

Keep Godot 4.6.x, GDScript and the existing Compatibility renderer.

Read AGENTS.md and relevant README/setup instructions fully, then inspect only relevant source/tests. Preserve existing screenshot requirements.

This request authorizes the Phase 1C features below; it does NOT authorize implementing the entire long-term MASTER_SPEC.

GOAL:
Make the first session feel personal and interactive:

Customize avatar → Decorate → Play a short puzzle → Unlock a visible room theme → Save and return.

Aim for meaningful activity during the first 5–10 minutes, without artificial waiting. Do not claim this guarantees retention or hours of content.


2. REUSE WHAT EXISTS — AVOID REWORK

Inspect and extend the existing boundaries:

- scripts/main.gd: session, pause/input ownership and persistence.
- scripts/save_data.gd: existing user://rosewater.cfg and atomic-save flow.
- scripts/avatar.gd: existing modular avatar and animation.
- scripts/forms.gd: mesh/material helpers and SHARED material cache.
- scripts/menus.gd: established pastel UI/theme.
- scripts/player.gd, scripts/camera.gd, scripts/sofa_interaction.gd: movement, orbit and seating.
- Existing integration suite and tests/capture_review.gd.

IMPORTANT:
The material cache is shared. Never recolor cached material resources globally.

Give customizable surfaces instance-local material copies, retaining textures and roughness. Use explicit appearance/decor channels, not fragile searches for old RGB values.

Create only small boundaries actually needed now:

- Appearance data → avatar.apply_appearance(data).
- Stable decor preset IDs → existing room surfaces.
- Puzzle completion signal/result → progression/save controller.

The puzzle must not write saves or manipulate room nodes directly.

Keep existing movement and animation APIs. Do not build a generic plugin architecture, service locator or speculative framework.


3. AVATAR PERSONALIZATION — EXISTING MODEL ONLY

Add an optional display name, hair color and outfit accent color.

Requirements:

- Keep the current hairstyle, body, face, clothing meshes and animation.
- Provide six tasteful swatches plus Godot's built-in color picker.
- Use its wheel mode where supported, not a custom color-wheel implementation.
- Show live changes on the actual 3D avatar.
- Use the existing camera for a useful view rather than creating a second avatar/render pipeline.
- Apply saves the choice.
- Cancel/Esc restores the entire previous appearance and camera state.
- Preview changes must not be autosaved.
- Trim the name, limit it to 24 characters, use a friendly default when blank, and treat it as plain text.
- Recolor only intended hair/outfit surfaces.
- Preserve skin, eyes, buttons, furniture and other shared materials.
- Provide C to open Personalize when gameplay allows, and a labelled pause-menu button.
- Do not process gameplay shortcuts while typing.

No new hairstyle catalogue, character rig, facial system or multiple save profiles in this phase.


4. DECOR PRESETS — VISIBLE OWNERSHIP WITHOUT A FULL EDITOR

Let players preview and choose coordinated presets for THREE existing surfaces:

- Rug.
- Sofa cushions.
- Curtains.

Requirements:

- Two starter palettes: current Rosewater and a complementary Mint palette.
- One unlockable palette: Lavender Dream, stable ID lavender_dream.
- Keep each surface selectable, using compact labelled preview swatches.
- Provide Apply and Cancel.
- Preserve existing texture/pattern details.
- Locked options explain how to unlock them; they must not pretend to be usable.
- A theme-level Apply action can update all three surfaces together.
- Preview cancellation restores the previous room.
- Saving occurs only on confirmation.
- B opens Decor when gameplay allows; also provide a labelled pause-menu button.

This is an in-place palette system, NOT furniture dragging, buying, inventory, mesh replacement, collision rebuilding or a new room.

Future placement tools must be able to reuse these stable object/preset IDs.


5. ONE COMPLETE ACTIVITY: COZY PAIRS

Create a small, attractive card box on a reachable area of the existing coffee table. It launches a six-pair memory game via E.

Interaction requirements:

- Resolve ONE interaction target based on valid range/facing/visibility.
- The HUD prompt and E action must agree.
- Do not activate the sofa and card game together.
- While seated, E must continue to mean Stand.
- Preserve existing seating behavior.
- The puzzle may use a polished 2D overlay; the surrounding game remains genuinely 3D.

Puzzle specification:

- 12 cards, six pairs, in a readable 4×3 grid.
- Shuffle each round.
- Six consistent original/local icons, e.g. teacup, flower, ribbon, cloud, cake and star.
- Avoid emoji-only artwork or numbered placeholder cards.
- Brief card flips.
- Clear matched states.
- A move counter and pairs-found counter.
- One move = two valid different card selections.
- Ignore same-card clicks, matched cards and extra clicks while resolving a pair.
- Mismatches stay visible briefly before closing.
- No mandatory timer or failure penalty.
- Show a short instruction, Restart and Exit.
- Restart/Exit/scene changes cleanly cancel delayed callbacks and reset input locks.
- Unfinished rounds award nothing.
- Send one completion result containing puzzle ID and move count.
- Keep puzzle rules separate from presentation where practical.


6. REWARD AND REPLAY — CONNECT THE GAME TO THE ROOM

First legitimate win permanently unlocks Lavender Dream.

Requirements:

- Show a concise result with moves, personal best and an attractive theme preview.
- Offer Apply to My Room and Keep My Current Style.
- Applying returns to the room and changes the real rug/cushion/curtain materials immediately.
- Deferring keeps the unlock available in Decor; it does not lose the reward.
- Later wins update the best move count when improved.
- Never duplicate the first-win reward.
- Replays are optional attempts to improve the player's own record, not currency farming.

No coins, shop, daily streak, loot boxes, grind, simulated online leaderboard or new quest framework.


7. SMALL POLISH THAT SUPPORTS THE FIRST SESSION

Reuse Phase 1B's visual style rather than redesigning every screen.

Requirements:

- Offer lightweight contextual guidance:
  Personalize → Decorate → Try Cozy Pairs → Apply a reward.
- Guidance is skippable/collapsible and never blocks free play or rewards.
- Detect actions completed before a hint appears.
- Persist dismissal/completion so Continue does not repeat introductory popups.
- Show a clear Start/Continue action and controls.
- Do not add a destructive New Game reset.
- Use one small objective hint at a time.
- Avoid covering the room with tutorial panels.
- Add restrained hover/focus/pressed states, readable contrast and short notifications.
- Bundle a few subtle original/generated-local UI sounds:
  click, card flip, match and reward.
- Reuse an existing audio system if present; otherwise keep it small, with persisted UI volume/mute.
- No asset-hunting marathon or soundtrack project.
- Keep the main scene legible at 1280×720 and 1920×1080.
- Support mouse and ordinary keyboard focus for UI.
- No shader overhaul, extra bloom or forced camera shake.


8. INPUT AND SAVE SAFETY — DO THIS NOW, NOT AFTER CONTENT EXPANDS

Use one clear source of truth for gameplay versus active UI, extending existing code:

MENU / PLAY / PAUSE / PERSONALIZE / DECOR / PUZZLE

An equally small equivalent is acceptable.

Input requirements:

- Only one top-level feature owns input at a time.
- UI releases the cursor and blocks world movement, camera orbit/zoom and E interactions.
- Esc dismisses the topmost UI correctly.
- Never resume movement behind a color picker, confirmation or result panel.
- Restore correct cursor/camera state when returning to play.
- The room and UI must not become stuck after rapid open/close or pause/resume.
- Choose and test a consistent seated-to-panel behavior.

Save requirements:

Extend rosewater.cfg; do not replace the save format wholesale.

- Add a schema version, safe defaults and migration from Phase 1B saves.
- Preserve saved position and settings.
- Persist appearance, confirmed decor, unlocks, best moves and onboarding state.
- Use stable IDs.
- Do not serialize scene node paths as permanent identity.
- Preserve atomic writes and the last good save.
- Back up before migration.
- Handle malformed/missing new fields without wiping valid old data.
- Save applied changes, legitimate completion and normal exit.
- Never save temporary previews.
- Do not persist an unfinished puzzle unless already supported; state this clearly.
- Use isolated test save locations.
- Never delete or replace the user's real save.


9. DELIVERY ORDER AND EFFICIENCY

Work in small verified milestones:

A. Save migration and input ownership.
B. Personalization and decor with Apply/Cancel.
C. Cozy Pairs and its visible reward.
D. Feedback, regression tests and review evidence.

Use one implementation agent.

Do not:

- Spawn parallel agents.
- Switch models.
- Rewrite stable systems.
- Add dependencies unnecessarily.
- Repeatedly re-plan.
- Rebuild already completed features.

Run focused checks after each milestone; run the full relevant suite at the end.

Fix demonstrated failures. Stop after the acceptance criteria are met instead of an open-ended self-improvement loop.

If genuinely blocked:

- Preserve a runnable checkpoint.
- State the exact blocker and next action.
- Do not repeatedly restart the task.
- Do not substitute fake functionality.

Maintain ONE concise docs/PROJECT_STATUS.md containing:

- Implemented features.
- Actual extension points.
- Save version.
- Deferred roadmap.
- Known limitations.
- Latest evidence paths.

Update an existing equivalent rather than duplicating it.

Keep AGENTS.md's screenshot rule. Add only a short pointer to the status file if needed.

LONG-TERM COMPATIBILITY:

Future work remains:

- Authored avatar/rig improvements.
- More hairstyles.
- Multiple profiles/homes.
- Furniture placement.
- Additional rooms/floors.
- More mini-games.

Do not implement stubs or empty buttons for these now.

A future model/rig should consume the appearance data without forcing a save/UI rewrite. A future mini-game should report its result through the same small completion boundary rather than reimplementing rewards and persistence.


10. ACCEPTANCE AND HONEST EVIDENCE

Preserve the existing integration checks.

Adapt only assertions legitimately changed by the new UI, not by removing coverage.

Add focused checks for:

- Appearance/decor Apply, Cancel and persistence.
- No material changes leaking to unrelated objects.
- Legacy save migration.
- Malformed new fields.
- Save failure handling.
- Preview state not being saved.
- One interaction target.
- Movement/camera blocked during UI.
- Esc/cursor restoration.
- Shuffled valid pairs.
- Rapid-click guards.
- Mismatch resolution.
- Restart/abort cleanup.
- Completion emitted once.
- First-win unlock once.
- Best-score update.
- Reload persistence.
- Complete first-session flow and Continue using isolated fresh AND legacy saves.

Exercise actual controls/UI in rendered tests, not only direct variable assignments.

Manually inspect the rendered result when available.

Tests prove functionality, not that real players will find it fun.

Report actual checks and failures. Do not invent pass counts.

Distinguish:

- Editor import.
- Rendered run.
- Audio verification.
- Windows testing.

Cloud rendering/FPS is not proof of Windows performance.


11. MANDATORY SCREENSHOTS AND FINAL DELIVERY

SCREENSHOTS ARE MANDATORY WHEN RENDERING IS AVAILABLE.

Keep before/after evidence in:

docs/review/phase1c/

Capture genuine running-game images at least 1280×720 showing:

1. Personalization.
2. Decor preview.
3. A puzzle in progress.
4. The earned reward/applied room.
5. A saved room after Continue.

Also capture comparable room/character baseline views before changes, reusing existing capture helpers where practical.

Reach the reward through the real completion flow in testing. Do not fabricate completion solely for screenshots.

Inspect images for:

- Clipping.
- Readability.
- Visible differences.
- Correct colors.
- Overlapping UI.
- Character/room visibility.

Never use AI concept art, an editor-only view or a mockup as runtime evidence.

A short real recording is optional if existing tools make it easy. Do not delay delivery to build a recording pipeline.

If rendering fails:

- Report the exact cause.
- Mark visual verification blocked.
- Do not silently omit evidence or claim visual success.

Finish this phase only.

Commit relevant source, tests, concise documentation and review screenshots.

Exclude personal saves, caches and build clutter.

Push the authorized task branch without force-pushing or merging main. If publishing is unavailable, report local status honestly.

FINAL RESPONSE MUST INCLUDE:

- Concise feature summary.
- Exact verification status.
- Remaining limitations.
- Branch and commit.
- Clickable commit-specific GitHub links PLUS relative paths for EVERY review screenshot.
- Images inline where supported.

Windows export/benchmarking is a separate task unless already available and explicitly authorized. Never claim it passed from Linux tests.