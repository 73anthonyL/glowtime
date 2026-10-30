---
name: release
description: Cut a Glowtime release. Bump the version, update the changelog, tag, push, watch the tauri-action build, and verify the notarized artifact.
disable-model-invocation: true
---

# Release

User-invoked only (`/release <version>`), because it publishes to GitHub.

## Preconditions

All of these must hold. If any fails, stop.

- On `main`, with a clean working tree, up to date with origin.
- `cargo test --workspace` and `pnpm --dir web test` pass.
- The signing secrets exist in the repo: `APPLE_CERTIFICATE`, `APPLE_ID`, `APPLE_PASSWORD`, `APPLE_TEAM_ID`, `TAURI_SIGNING_PRIVATE_KEY`. Check names only with `gh secret list`, never values.

## Steps

1. Set the version in `src-tauri/tauri.conf.json`, `src-tauri/Cargo.toml`, and `package.json`. They must match.
2. Add a `CHANGELOG.md` section from `git log <last-tag>..HEAD --oneline`, written for users, not developers.
3. Show the user the diff and the tag name. **Wait for an explicit yes.**
4. Commit `release: v<version>`, tag `v<version>`, then `git push && git push --tags`.
5. `gh run watch` the release workflow.
6. When it finishes, download the `.dmg`, then run `spctl --assess --type open --context context:primary-signature -v` and `xcrun stapler validate`.
7. Report the release URL. The release stays a **draft** until the user publishes it.
