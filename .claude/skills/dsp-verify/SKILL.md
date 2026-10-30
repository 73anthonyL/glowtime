---
name: dsp-verify
description: Verify Glowtime's audio analysis against generated fixture audio with known answers (tones, click tracks, chords). Use after changing anything in crates/glow-dsp, or when the user asks whether beat, tempo, key, or mood detection is correct.
---

# DSP verify

**Precondition:** `crates/glow-dsp` and `crates/glow-cli` must exist (milestone 2). If they don't, stop and say so.

## Steps

1. Regenerate fixtures: `scripts/gen-fixtures.sh` (ffmpeg; outputs to `fixtures/`, gitignored).
2. Run the test suite: `cargo test -p glow-dsp`.
3. For any failure, dump features for that fixture and inspect the series:
   `cargo run -p glow-cli -- analyze fixtures/<name>.wav > /tmp/frames.json`
4. Report a table of fixture, expected value, measured value, and pass/fail.

## Expected answers

| Fixture | Expectation |
|---|---|
| `sine_440.wav` | dominant chroma = A, centroid near 440 Hz |
| `click_120bpm.wav` | tempo 120 ± 1 BPM, onsets within ±15 ms of clicks |
| `chord_cmaj.wav` | key C, mode major |
| `chord_amin.wav` | key A, mode minor |
| `pink_noise.wav` | no tempo lock, low key confidence |
| `silence.wav` | silence detector fires, no onsets |

## Rules

- Never "fix" a test by widening tolerance without telling the user why the old tolerance was wrong.
- Snapshot changes (`insta`) need an explanation of which algorithm change caused them.
