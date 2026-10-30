# Glowtime architecture

## Why it is shaped this way

Two outside constraints decided most of the design.

1. **Spotify cannot tell us the mood.** Its audio-features and audio-analysis endpoints return 403 for apps created after November 2024. Development Mode apps are also capped at 5 authorized Premium users. So Glowtime computes everything from the audio signal itself. Spotify's Web API is an optional extra for metadata and album art, never a dependency.
2. **No OS hands another app's audio over freely.** Each platform needs its own capture code: a Core Audio process tap on macOS 14.2+, WASAPI loopback on Windows, and a PipeWire monitor source on Linux. That code sits behind one Rust trait, so the rest of the app is identical everywhere.

## Pipeline

```
IOProc (Swift → Rust extern "C") ─ rtrb SPSC ─► analysis thread ─► latest-frame slot ─► tauri::ipc::Channel @ display rate
```

| Stage | Thread | Rules |
|---|---|---|
| Capture callback | Core Audio real-time | Downmix and push only. No allocation, locks, logging or panics. |
| Analysis | Dedicated thread | 1024-sample window, 512-sample hop (~94 Hz). 4096-sample FFT every 4th hop for chroma. |
| Frame slot | Shared | Latest-wins. A slow UI never back-pressures audio. |
| IPC | Tauri | JSON over a Channel, ~1 KB per frame. Carries `beatCount` and a timestamp so beats survive dropped frames. |
| Render | WebView | Interpolates between frames. Three.js on WebGL2. |

**End-to-end latency** is about 45–60 ms. A user-set visual delay, pre-filled from the output device latency, covers Bluetooth headphones (150–250 ms).

## Features and mood

- **Per hop:** RMS with slow auto-gain (so Spotify's volume slider doesn't change the visuals), 8 and 32 log-spaced bands, spectral centroid, spectral flux, onsets with an adaptive median threshold.
- **Rhythm:** tempo by autocorrelating ~8 s of onset strength. Beat phase is tracked by a phase-locked loop.
- **Harmony:** 12-bin chroma, then key and major/minor by Krumhansl profile correlation, with a confidence value.
- **Mood (shown as "vibe"):** arousal comes from loudness, onset density, tempo and flux. Valence comes from mode, brightness and consonance. Both are smoothed over ~6 s with hysteresis. Valence from audio alone is a weak signal, so it gets low weight and slow change.

## Visual engine

- **Contract:** every scene reads `GlowUniforms`: `time, rms, bands[8], onset, beatPhase, beatCount, bpm, valence, arousal, centroid, palette[4], transition`.
- **Scene interface:** `Scene { init, update, render, dispose }`, rendering to its own target.
- **Compositor:** crossfades scenes over 2–4 s on 16/32-beat boundaries or a sustained mood shift.
- **Mood to look:** valence sets hue (cool to warm, palettes in OKLCH). Arousal sets saturation, contrast, speed and density. Beats drive pulses and bands drive displacement.
- **Budget:** 60 fps at 1440p on an M1, GPU time under 8 ms, with dynamic resolution when frames run long.

## Presentation

- Tray menu: Enable/Disable, Display ▸ monitors, Scene ▸, Quit. Accessory activation policy (no Dock icon).
- Fullscreen: move the window to the chosen monitor, then `setFullscreen(true)`. Fallback is a borderless window sized to the monitor.
- Settings in `tauri-plugin-store`. Toggle key via `tauri-plugin-global-shortcut`.

## macOS capture details

- Find Spotify's audio objects through `kAudioHardwarePropertyProcessObjectList`, matching bundle-ID prefix `com.spotify.client` (helper processes may be the ones producing sound).
- `CATapDescription(stereoMixdownOfProcesses:)` + `AudioHardwareCreateProcessTap`, wrapped in a private aggregate device, read with `AudioDeviceCreateIOProcIDWithBlock`. Reference implementation: github.com/insidegui/AudioCap.
- Fallback: a global tap excluding Glowtime's own process.
- Teardown order: stop IO, destroy IOProc, destroy aggregate device, destroy tap.
- Permission: `NSAudioCaptureUsageDescription` in Info.plist. Denial yields silence, so a silence detector drives onboarding.

## Release

- `tauri-apps/tauri-action` on macOS runners, arm64 only, minimum macOS 14.2.
- Developer ID signing and notarization before any public release.
- `tauri-plugin-updater` with signed `latest.json` on GitHub Releases.

## Open questions (verify in the named milestone)

- Does hardened runtime need an entitlement for process taps? (M10)
- Does Tauri 2 expose macOS "simple fullscreen"? (M7)
- How should the tap react to output-device changes mid-stream? (M9)
