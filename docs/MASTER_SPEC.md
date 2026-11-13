# DREAM WORLD 3D — MASTER SPEC + PHASE 1 BUILD

You are a senior Godot 4 3D game developer, gameplay programmer, and stylized technical artist. Work efficiently and deliver a runnable, visually convincing project. Do not expand scope on your own.

## Operating constraints (IMPORTANT: save Codex usage)

- Use **Godot 4.6.x**, **GDScript**, and **Windows PC** as the target. No network, multiplayer, mobile, or paid integrations.
- Inspect the workspace/project once before editing. If it is empty, create a new `project.godot`. If a project exists, preserve it and avoid unrelated refactors. Follow any repository instructions.
- **Implement PHASE 1 ONLY during this run.** The full vision below is context for future-proofing, NOT a request to implement every feature now.
- Make reasonable small decisions without asking questions. Do not recruit agents, run broad exploratory research, rewrite working systems, or repeatedly polish unrelated details.
- Prefer compact, modular, reusable scenes and data-driven content over long monolithic scripts. Use original or clearly permitted assets only. Never copy proprietary Roblox, Sims, Candy Crush, or other game assets.
- Run one focused verification pass and fix genuine failures. If an issue remains after two targeted attempts, report the blocker rather than endlessly retrying. Stop once Phase 1 acceptance criteria pass.
- Final response: maximum 200 words. Only report delivered features, files/entry scene, how to test, verification, known gaps, and one recommended next phase. No lengthy narratives or pasted code.

## Product vision — keep as design specification for future phases

**Title:** Dream World 3D (working title)

**Genre:** Premium-looking, cozy, pastel, third-person 3D life simulator with avatar creation, individually decorated homes, and a large collection of optional mini-games.

**Art direction is the highest priority.** Target the quality of polished, cute, pastel 3D dollhouse/life-sim concept art: soft pink, baby blue, lavender, cream, mint; rounded silhouettes; coherent attractive models; carefully selected materials; warm sunlight, soft shadows, ambient occlusion where practical; inviting furnished interiors; polished rounded UI with illustrative icons and subtle hover feedback.

**This must be an actual 3D world, not a flat 2D interface or fake isometric drawing.** Do not describe primitive block/capsule prototypes as finished visual quality.

If reference images are attached, treat them as the PRIMARY art-quality benchmark. They are concept references, not existing Godot assets. Aim for similar artistic quality, not pixel-identical replication. If no images are attached, use the art-direction text above. Be candid about visual gaps; do not claim reference quality is achieved without evidence.

### Full feature vision (later phases, NOT Phase 1)

1. **Avatar Creator:** multiple saved characters; custom names; many hairstyles (target at least 20), hair colour through an HSV colour wheel and live material preview; skin tones, face features, clothing tops, trousers, skirts, dresses, shoes and accessories; independent colour selections; rotating/zoomable 3D character preview. Target initial wardrobe: 15 tops, 15 bottoms, 10 dresses, 10 shoes; expand later.
2. **Personal 3D houses:** each saved character can have their own house and progress. Two walkable floors with multiple rooms, working staircase, living room, kitchen, bathroom, bedrooms and study. Third-person free movement and rotating/zooming camera.
3. **Furniture decoration mode:** choose items from a visual catalogue; preview ghost object; move, rotate and place on suitable floor/wall/ceiling surfaces; sofa, bed, desk, chairs, shelves, lamps, curtains, wall art and more; avoid invalid overlaps; undo/cancel; recolour and reposition; saved layouts. Curtains must anchor to windows/walls instead of floating in space.
4. **Character activities:** interaction with furniture, sitting, sleeping, cooking and other readable animations as those systems arrive.
5. **Save system:** autosave plus manual save; multiple characters with separate names, looks, homes, object positions/colours, mini-game progress; robust local persistence under `user://`.
6. **Mini-games:** modular selection hub and expandable collection. Prioritise Cake Maker, Cooking, Fashion Runway and Match-3, then jigsaw, fishing, gardening, pet care and many more. They must be actual interactive games, not progress-bar-only simulations. Optional earned Stars can unlock cosmetics, with a Creative Mode for unrestricted decorating (design proposal).
7. **Windows UX:** 16:9 layout, mouse and keyboard, readable UI, adjustable graphics/audio, 1080p baseline and scalable window size. Smooth performance on an ordinary Windows desktop.

## THIS RUN: PHASE 1 — VISUAL-QUALITY PLAYABLE SLICE

Build a small, polished, functional 3D scene proving that the project can achieve the desired art direction.

Quality and feel matter more than quantity. Do not build Avatar Creator, the entire two-floor house, decoration editor, character slots, or mini-games yet.

Deliver these:

1. A valid Godot project with a **beautiful, fully 3D pastel living room**: finished floor/walls/windows, attractive sofa, coffee table, rug, shelves, curtains, lamps, plants and decor. Compose it like a premium cozy game, with depth, meaningful silhouettes, warm lighting, material variation and no obvious empty-grey prototype appearance. You may use procedural/original geometry where appropriate, but visible furniture should not look like unstyled boxes. A staircase or doorway can hint at future house expansion.

2. **One appealing cute 3D player avatar** with distinct head, face, hair and outfit, suitable proportions and non-placeholder styling. At minimum, provide convincing idle, walking and running feedback. Keep assets modular enough to swap hairstyles/clothes later; do not overbuild the customization UI yet.

3. Smooth **third-person controls**: WASD movement relative to camera, Shift run, mouse-controlled orbit with sensible pitch bounds, scroll zoom, camera collision handling, smooth transitions. Use `CharacterBody3D` and an appropriate camera rig such as `SpringArm3D`. The avatar must navigate the room without getting trapped in furniture.

4. At least one **real interaction**: approach the sofa, see a tasteful contextual prompt, press E to sit, and press E/another obvious key to stand. A simple tasteful animation is acceptable; it must visibly work.

5. A polished but compact **Main Menu** with Start/Continue, a meaningful Settings button or settings panel, and Quit. A clean in-game pause menu with Resume and Main Menu. Avoid generic flat grey buttons.

6. A lightweight persistent save of player position/settings if practical; build the underlying project structure so character and room data can be added in future phases. Do not spend time on full profile/save architecture yet.

7. A brief in-project README with controls, run instructions and known limitations.

### Scope/asset decisions

- Spend effort on **one finished-looking room and avatar**, not many low-quality rooms or hundreds of placeholders.
- If suitable licensed 3D assets already exist in the project, reuse them. Otherwise create original coherent stylized assets within the available tooling. Avoid downloading random assets or making the build dependent on unavailable external services.
- Use reusable independent scenes for player, camera, room props, menus and interaction components. Keep an obvious place for future Avatar Creator, furniture catalog, house floors and mini-games.
- Use simple optimizations (sensible lights, shadows, draw calls and collision). Avoid unnecessary complex shaders.

### Acceptance checks (must verify, not merely claim)

- [ ] Project opens in Godot 4.6.x and main scene runs with F5 without blocking errors.
- [ ] Room and avatar are real visible 3D objects, composed and lit in a coherent pastel style.
- [ ] WASD/Shift/mouse orbit/zoom work; camera behaves around walls; movement collision works.
- [ ] E-to-sit and stand are functional.
- [ ] Main menu, pause, resume and quit work.
- [ ] UI does not obscure the scene; no missing script/class/resource errors.
- [ ] The scene is polished enough to serve as a **visual benchmark** for later phases. If not, explicitly mark it *below target*, specify why, and do not pretend it meets reference-image quality.

When done, stop. Do not begin Phase 2 automatically. Leave the project in an easy-to-test state and provide concise factual results.