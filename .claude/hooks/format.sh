#!/usr/bin/env bash
# PostToolUse hook (Edit|Write): format the file Claude just touched.
# Deterministic: the harness runs this every time, unlike advice in CLAUDE.md.
# Never blocks: formatting problems are reported by lint/CI, not here.
set -u
f=$(jq -r '.tool_response.filePath // .tool_input.file_path // empty' 2>/dev/null)
[ -n "${f:-}" ] && [ -f "$f" ] || exit 0
root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
case "$f" in
  *.rs)
    command -v rustfmt >/dev/null && rustfmt --edition 2021 "$f" 2>/dev/null ;;
  *.ts|*.tsx|*.js|*.mjs|*.json|*.css|*.html|*.md)
    p="$root/node_modules/.bin/prettier"
    [ -x "$p" ] || p="$root/web/node_modules/.bin/prettier"
    [ -x "$p" ] && "$p" --write --log-level silent "$f" 2>/dev/null ;;
esac
exit 0
