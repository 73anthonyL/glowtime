---
name: run-glowtime
description: Launch Glowtime to see a change working, either the full Tauri app or the browser-only scene preview, and capture a screenshot. Use when asked to run, start, preview, or screenshot the app or a scene.
---

# Run Glowtime

Pick the lightest mode that shows the change.

## Browser preview (scenes, engine, uniforms)

**Precondition:** milestone 3 done (`web/` exists).

1. `pnpm --dir web dev` in the background. Note the local URL.
2. Open it in a new Claude in Chrome tab with `?feed=replay&scene=<id>`.
3. Wait about 2 s, then screenshot. Read the console for GL errors.

## Full app (capture, IPC, tray, windows)

**Precondition:** milestone 0 done (`src-tauri/` exists).

1. `pnpm tauri dev` in the background. The first build takes minutes.
2. The window can't be screenshotted through Chrome. Ask the user to confirm what they see, or use `screencapture -x` to a scratch file and read it.
3. For audio, the user must have Spotify playing. If visuals are flat, suspect the audio permission first: denial yields silence, not an error.

## Always

Stop background processes when done.
