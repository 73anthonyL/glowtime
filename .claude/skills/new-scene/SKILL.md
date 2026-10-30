---
name: new-scene
description: Scaffold a new Glowtime visual scene (Three.js/WebGL2) that consumes GlowUniforms, register it with the compositor, and preview it on the replay feed. Use when the user asks for a new visualization, scene, effect, or look.
---

# New scene

**Precondition:** `web/src/engine/uniforms.ts` and `web/src/scenes/` must exist (milestone 3). If they don't, stop and tell the user the visual engine hasn't been built yet.

## Steps

1. Read `web/src/engine/uniforms.ts` and one existing scene in `web/src/scenes/` to match conventions exactly.
2. Restate the brief as a mood mapping before coding: what valence and arousal do to hue, motion, density, and what beats and bands do.
3. Create `web/src/scenes/<kebab-name>/index.ts` implementing `Scene { id, init(ctx), update(u, dt), render(target), dispose() }`. Put shaders in `.glsl` files beside it.
4. Register it in the scene registry so the tray Scene ▸ menu and compositor see it.
5. Run `pnpm --dir web dev`, open the replay feed with this scene, and screenshot it with Claude in Chrome. Check for non-black output and an empty console.

## Rules

- Read only from `GlowUniforms`. Never import a feed or Tauri API inside a scene.
- `dispose()` frees every geometry, material, texture, and render target. Crossfades create and destroy scenes constantly, so leaks add up fast.
- **Budget:** GPU time under 8 ms at 1440p on M1. Avoid per-frame allocations in `update`. Prefer one fullscreen fragment pass or instanced geometry over many draw calls.
- **Mood mapping defaults:**
  - valence → hue, from cool blue/violet to warm amber/magenta, built in OKLCH
  - arousal → saturation, contrast, speed, particle count
  - `onset` / `beatPhase` → pulses
  - `bands` → displacement
- Respond to `transition` (0→1 during crossfade) so the scene can fade in its own way.
