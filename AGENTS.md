# Dream World 3D standing instructions

Preserve functioning gameplay, tests and saves; avoid unrelated changes and scope expansion.
Use Godot 4.6.x and the existing isolated checkout. Do not create a Git worktree unless requested.

At the end of EVERY future Dream World 3D task, whenever rendering is available, capture and provide at least one **genuine screenshot from the running Godot game** demonstrating the current result. For visual/UI/gameplay changes, provide relevant multi-angle screenshots (typically main menu, avatar, room, affected feature). Store review screenshots under `docs/review/<task-name>/`, commit them, and link each image in the final response using clickable GitHub URLs targeting that branch/commit, plus repository-relative paths. Never use generated concept art or an editor-only mockup as proof of gameplay. If screenshot capture fails, state exactly why. Include concise verification status and known visual gaps. Preserve functioning features and avoid unrelated changes.

Run the existing rendered integration suite after relevant changes. Use separate test save data; never delete real saves to make tests pass. The README documents the cloud display/XDG setup.

See `docs/PROJECT_STATUS.md` for implemented features, extension points, save version and latest evidence.
