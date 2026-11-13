# Original project art and audio

All geometry, vector artwork and short UI audio cues in this project were created for Dream World 3D.
No externally downloaded meshes, textures, audio, fonts or copyrighted game art are included.

- `textures/linen.svg`: explicit woven strokes, repeated in world space at consistent scale.
- `textures/ash_wood.svg`: subtle curved grain, used on planks, shelves and table surfaces.
- `textures/rug.svg`: original daisy medallion with layered mint/rose borders.
- `textures/meadow_print.svg`: original stylized meadow illustration.
- `ui/*.svg`: original house, leaf, settings and semantic action/lock symbols.
- `pairs/*.svg`: six original teacup/flower/ribbon/cloud/cake/star icons and a leaf card back.
- `audio/*.wav`: original locally synthesized short click, flip, match, reward, lamp-switch, watering, fridge, preparation, cooking, completion, purchasing, bedroom, sleeping and goal cues (mono 16-bit PCM, 22,050 Hz); no sampled music or external recordings.

Material profiles in `scripts/forms.gd` distinguish matte fabric, satin wood, glazed ceramic,
soft skin, hair and brass. Mipmaps are enabled for repeating material textures.
Meshes are generated locally at startup and reused where suitable. Compatibility rendering uses
ordinary Godot materials, 4× MSAA and filtered directional shadows; no expensive custom shaders.

Phase 1D adds an original procedural miniature house keepsake, animated existing curtain meshes,
and a reusable nine-drop watering effect. No external art or audio was introduced.

Phase 2A furnishings, three ingredient/preparation/finished-food sets, cookware and the
three-day/seven-day keepsakes are original procedural geometry. Eight additional quiet
mono PCM cues were synthesized locally, with no downloaded samples or music.

Phase 2B adds original procedural garden geometry, three crop stage sets, two distinct
visitor silhouettes, six social/garden keepsakes and six catalog upgrades. Eight more
quiet mono PCM cues (plant, water, harvest, arrival, conversation, friendship, event,
garden chime ambience) were synthesized locally with no samples or copyrighted music.
All 22 cues use the existing volume/mute system; audible playback remains unverified.

Phase 2C adds original branching foliage, household details, seating/tea/picnic geometry,
a cake cloche, lavender memory corner and a supported lantern gathering arch. Existing
procedural avatar parts gain blinking, expressive mouth motion and reusable social poses.
Eight more locally synthesized PCM cues cover sitting, standing, social/shared moments,
story completion, day-end and restrained interior/evening ambience. All 30 cues respect
the existing mute/volume settings. No downloaded art, third-party samples or runtime network
services are used. Audible playback remains unverified under the cloud Dummy driver.
