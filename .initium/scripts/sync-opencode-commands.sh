#!/usr/bin/env bash
# =============================================================================
# sync-opencode-commands.sh — Mirror .claude/commands/ → .opencode/commands/
# =============================================================================
# OpenCode discovers slash commands from .opencode/commands/*.md (same bodies as
# Claude Code / Cursor, including $ARGUMENTS placeholders).
#
# Usage:
#   bash .initium/scripts/sync-opencode-commands.sh
#   bash .initium/scripts/sync-opencode-commands.sh --check   # exit 1 if out of sync
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="${ROOT}/.claude/commands"
DST="${ROOT}/.opencode/commands"
CHECK=false

for arg in "$@"; do
  case "$arg" in
    --check) CHECK=true ;;
    --help|-h)
      echo "Usage: bash .initium/scripts/sync-opencode-commands.sh [--check]"
      exit 0
      ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

if [ ! -d "$SRC" ]; then
  echo "Missing source directory: $SRC" >&2
  exit 1
fi

if $CHECK; then
  shopt -s nullglob
  out_of_sync=false
  for src_file in "$SRC"/*.md; do
    base="$(basename "$src_file")"
    dst_file="${DST}/${base}"
    if [ ! -f "$dst_file" ] || ! cmp -s "$src_file" "$dst_file"; then
      echo "Out of sync: $base"
      out_of_sync=true
    fi
  done
  for dst_file in "$DST"/*.md; do
    base="$(basename "$dst_file")"
    if [ ! -f "${SRC}/${base}" ]; then
      echo "Extra OpenCode command (remove or restore in Claude): $base"
      out_of_sync=true
    fi
  done
  if $out_of_sync; then
    echo "Run: bash .initium/scripts/sync-opencode-commands.sh"
    exit 1
  fi
  echo "OpenCode commands are in sync with .claude/commands/"
  exit 0
fi

mkdir -p "$DST"

shopt -s nullglob
for dst_file in "$DST"/*.md; do
  base="$(basename "$dst_file")"
  if [ ! -f "${SRC}/${base}" ]; then
    rm -f "$dst_file"
  fi
done

for src_file in "$SRC"/*.md; do
  cp "$src_file" "${DST}/$(basename "$src_file")"
done

count="$(find "$SRC" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')"
echo "Synced ${count} command(s) to .opencode/commands/"
