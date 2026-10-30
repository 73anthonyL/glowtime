# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Glowtime is a music visualizer. It captures the audio Spotify is playing on this computer, analyzes it locally (beat, energy, spectrum, key/mode, and a slow-moving "vibe" estimate), and renders mood-reactive abstract scenes in a window that can go fullscreen on any monitor. Stack: Tauri 2 (Rust core) + Vite/TypeScript/Three.js front end. macOS ships first; Windows/Linux come later.

**Status:** pre-scaffold. Only the Claude Code environment and docs exist. The roadmap and current milestone live in `docs/roadmap.md`; check it before starting work. Commands below marked *(planned)* do not work until their milestone lands.

## Commands

```bash
pnpm tauri dev                                  # run the app (planned, M0)
cargo check --workspace                         # fast compile check (planned, M0)
cargo test -p glow-dsp                          # DSP tests on fixture audio (planned, M2)
cargo test -p glow-dsp onset_click_track        # single test by name (planned, M2)
cargo run -p glow-cli -- analyze <file.wav>     # offline feature dump to JSON (planned, M2)
scripts/gen-fixtures.sh                         # regenerate ffmpeg test audio (planned, M2)
pnpm --dir web dev                              # browser-only scene preview with mock/replay feed (planned, M3)
pnpm --dir web test                             # front-end tests (planned, M3)
```

## Architecture (target)

```
Spotify ─► Core Audio process tap (Swift, crates/glow-capture-macos)
        ─► rtrb lock-free ring buffer
        ─► analysis thread (crates/glow-dsp: FFT, bands, onsets, tempo, chroma, key, mood)
        ─► FeatureFrame (crates/glow-core, TS types via ts-rs)
        ─► tauri::ipc::Channel at display rate
        ─► web/ engine: GlowUniforms ─► Scene ─► compositor crossfades ─► fullscreen window
```

- `crates/glow-core`: shared types and the `AudioSource` trait. No platform deps.
- `crates/glow-dsp`: pure analysis. No Tauri, no I/O. Everything here is testable offline against `fixtures/`.
- `crates/glow-capture-macos`: Swift package `GlowTap` exposing a tiny C ABI (`gt_start`/`gt_stop`), linked via swift-rs in `build.rs`.
- `crates/glow-cli`: offline `analyze` and a live terminal meter, for debugging DSP without the GUI.
- `src-tauri/`: the shell only (IPC, tray menu, windows, settings). Keep logic out of it.
- `web/feeds/{tauri,mock,replay}`: scenes never know where frames come from. Develop scenes against `replay`.

Full design and rationale: `docs/architecture.md`.

## Invariants (do not break)

- **Audio callback is real-time.** No allocation, locks, logging, syscalls, or panics in the IOProc/callback path. It only downmixes and pushes into the ring buffer. Get changes there reviewed by the `realtime-audio-reviewer` agent.
- **FeatureFrame is a versioned contract.** Change it in `glow-core`, bump its `version` field, and regenerate TS types. Never hand-edit generated TS.
- **Spotify is optional.** The visualizer must work with no Spotify login. Never call Spotify's `audio-features` or `audio-analysis` endpoints: they return 403 for new apps. Development Mode allows 5 users, so public builds use a bring-your-own Client ID with PKCE.
- **Capture stays behind `AudioSource`.** Platform code never leaks into dsp, core, or the front end.
- **Disabled means idle.** Disabling the visualizer stops both rendering and the audio tap.

## Gotchas

- A denied "System Audio Recording" permission produces **silence, not an error**. The silence detector is how we notice.
- `pnpm tauri dev` runs a bare binary. It needs Info.plist embedded (`-sectcreate __TEXT __info_plist`), or macOS attributes the audio permission to the terminal.
- Ad-hoc code signatures change every build and reset the permission grant. Use the stable local signing identity.
- Release target is arm64 only, minimum macOS 14.2 (process taps).

## Working agreements

- The user is learning agent orchestration, MCP, and systems design through this build. When introducing a Claude Code feature or design pattern for the first time, explain the why briefly. At the end of each milestone, draft `docs/learning/NN-<topic>.md` with them.
- Hooks run automatically: `.claude/hooks/format.sh` after edits, and `.claude/hooks/check.sh` (cargo check) before a turn ends.
- Project skills: `new-scene`, `dsp-verify`, `run-glowtime`, `release` (user-only). Agents: `realtime-audio-reviewer`, `shader-artist`, `platform-researcher`.
