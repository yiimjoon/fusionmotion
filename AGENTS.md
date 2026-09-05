# Fusion Motion contributor notes

- Read `docs/FUSION_MOTION_KO.md` before changing motion graphs or scripting helpers.
- Export a snapshot before mutating live Fusion. Preserve user edits, including unnamed Transforms.
- No proxy changes or preview renders by default. Render only when requested, e.g. for viewing away from the workstation.
- Prefer built-in ImageGen for collage bitmap assets. Keep motion editable in Fusion.
- One movement per Transform. Separate local motion from global pan/zoom. Add background overscan before global motion.
- For new collage graphs use native Stop Motion (`ofx.com.blackmagicdesign.resolvefx.StopMotion`, `frameRepeat=2`). Review existing presets before migrations.
- Keep package contents, README and DRFX synchronized. Retain Codex Rise Fade Image.
- CodexTypo must remain an expandable GroupOperator. Preserve the Follower animation unless a change is requested.
- Distinguish static parsing, host input checks, rendering and user visual confirmation.
