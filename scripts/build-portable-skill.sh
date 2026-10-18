#!/bin/sh
# Writes skills/roast-loop/SKILL.md, the copy for Codex, Cursor and other agents that read the
# Agent Skills format, from the Claude Code plugin's copy. The plugin copy is the source of truth:
# edit plugins/roastbyai/skills/roast-loop/SKILL.md, then run this script.
#
# Differences in the portable copy:
# - no allowed-tools line (Claude Code plugin tool names; Codex and Cursor don't use the field)
# - no $ARGUMENTS placeholder (only Claude Code fills it in)
#
# Usage: scripts/build-portable-skill.sh [--check]   (--check exits 1 if the copy is stale)
set -eu
cd "$(dirname "$0")/.."
src=plugins/roastbyai/skills/roast-loop/SKILL.md
dst=skills/roast-loop/SKILL.md
tmp=$(mktemp)
sed -e '/^allowed-tools:/d' \
    -e 's/^The user'"'"'s arguments: `\$ARGUMENTS`\.$/The user'"'"'s request gives the target and options./' \
    "$src" > "$tmp"
if grep -q 'ARGUMENTS\|allowed-tools\|mcp__plugin_' "$tmp"; then
    echo "portable skill still contains Claude Code specifics:" >&2
    grep -n 'ARGUMENTS\|allowed-tools\|mcp__plugin_' "$tmp" >&2
    rm -f "$tmp"; exit 1
fi
if [ "${1:-}" = "--check" ]; then
    if cmp -s "$tmp" "$dst"; then rm -f "$tmp"; echo "portable skill is up to date"; exit 0; fi
    rm -f "$tmp"; echo "portable skill is stale: run scripts/build-portable-skill.sh" >&2; exit 1
fi
mkdir -p "$(dirname "$dst")"
mv "$tmp" "$dst"
echo "wrote $dst"
