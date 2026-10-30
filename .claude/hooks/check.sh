#!/usr/bin/env bash
# Stop hook: refuse to end a turn while the Rust workspace fails to compile.
# Exit 2 feeds stderr back to Claude so it fixes the error before stopping.
set -u
input=$(cat)
# Avoid loops: if Claude is already continuing because of this hook, let it stop.
[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)" = "true" ] && exit 0
root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
[ -f "$root/Cargo.toml" ] || exit 0          # workspace not scaffolded yet
command -v cargo >/dev/null || exit 0          # toolchain not installed yet
if ! out=$(cd "$root" && cargo check -q --workspace --message-format short 2>&1); then
  echo "cargo check failed. Fix these before finishing:" >&2
  printf '%s\n' "$out" | tail -n 40 >&2
  exit 2
fi
exit 0
