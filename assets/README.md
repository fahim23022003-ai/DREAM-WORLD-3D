# Original Phase 1B art

All geometry, vector artwork and short UI audio cues in this project were created for Dream World 3D.
No externally downloaded meshes, textures, audio, fonts or copyrighted game art are included.

- `textures/linen.svg`: explicit woven strokes, repeated in world space at consistent scale.
- `textures/ash_wood.svg`: subtle curved grain, used on planks, shelves and table surfaces.
- `textures/rug.svg`: original daisy medallion with layered mint/rose borders.
- `textures/meadow_print.svg`: original stylized meadow illustration.
- `ui/*.svg`: original house, leaf and settings symbols.
- `pairs/*.svg`: six original teacup/flower/ribbon/cloud/cake/star icons and a leaf card back.
- `audio/*.wav`: original locally synthesized short click, flip, match and reward tones (mono 16-bit PCM, 22,050 Hz); no sampled music or external recordings.

Material profiles in `scripts/forms.gd` distinguish matte fabric, satin wood, glazed ceramic,
soft skin, hair and brass. Mipmaps are enabled for repeating material textures.
Meshes are generated locally at startup and reused where suitable. Compatibility rendering uses
ordinary Godot materials, 4× MSAA and filtered directional shadows; no expensive custom shaders.
