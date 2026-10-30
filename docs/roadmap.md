# Roadmap

One milestone per session. Each pairs a build step with a Claude Code concept and a systems-design concept, and ends with a `docs/learning/NN-<topic>.md` note.

**Current milestone: 0** (environment files done; toolchain install and Tauri scaffold pending)

| # | Build | Claude Code lesson | Systems design lesson | Done when |
|---|---|---|---|---|
| 0 | Toolchain, workspace + Tauri scaffold, CLAUDE.md, settings, hooks | CLAUDE.md, permissions, hooks vs instructions | Module boundaries; pure core, impure shell | `pnpm tauri dev` opens a window; hooks fire |
| 1 | **Spike:** Swift CLI records Spotify to WAV via process tap | `platform-researcher` subagent; context isolation | De-risk the unknown first | WAV verified with ffprobe; denied permission detected |
| 2 | `glow-dsp` levels/bands/onsets, fixtures, `glow-cli`, tests | Skills with bundled scripts (`dsp-verify`) | Testability; golden/snapshot tests | 440 Hz → A; click track → 120±1 BPM |
| 3 | Web engine, GlowUniforms, first scene, mock + replay feeds | `new-scene` skill; Claude in Chrome verification | Contract-first design across languages | Replay renders; screenshot non-black, no GL errors |
| 4 | Capture crate: swift-rs, `AudioSource`, rtrb, live meter | `realtime-audio-reviewer`; `/code-review` | Real-time constraints; lock-free queues | Meter tracks Spotify; reviewer clean |
| 5 | Tauri Channel stream → first live visuals | Debugging across process boundaries | Data vs control plane; versioned schemas | Visuals pulse on beats |
| 6 | Tempo, beat phase, chroma, key, mood | Plan mode for algorithm design | Smoothing, hysteresis, honest uncertainty | C-major → major; stable snapshots |
| 7 | Tray, enable/disable, monitor fullscreen, settings, latency offset | Iterating with `run-glowtime` | Lifecycle state machines | Fullscreen on both displays; toggle stops tap |
| 8 | Three scenes, crossfades, dynamic resolution | `shader-artist` in parallel worktrees | Performance budgets; graceful degradation | 60 fps @1440p on M1 |
| 9 | Spotify restart, device change, sleep/wake, onboarding | Background agents | Failure modes and recovery | Survives each scenario without restart |
| 10 | CI, signing + notarization, updater, v0.1.0 | `release` skill (user-only); `/loop` on CI | Supply chain; reproducible builds | Notarized .dmg passes `spctl --assess` |
| 11 | `glowtime-mcp` server | Building an MCP server | Observability and introspection | Claude reads live frames, switches scenes |
| 12+ | Spotify metadata/palette; Windows + Linux capture; wallpaper; phone playback | Workflow tool fan-out | Platform abstraction; OAuth PKCE | — |
