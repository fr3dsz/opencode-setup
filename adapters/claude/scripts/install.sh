#!/usr/bin/env bash
#
# Claude Code adapter installer (macOS / Linux).
#
# Deploys repository content to live Claude Code configuration (~/.claude):
#   core/skills/*                         -> skills/*            (symlinks)
#   adapters/claude/skills/*              -> skills/*            (symlinks)
#   adapters/claude/agents/*.md           -> agents/*.md         (symlinks)
#   adapters/claude/rules/*.md            -> rules/*.md          (symlinks)
#   adapters/claude/config/CLAUDE.md      -> CLAUDE.md           (rendered)
#   adapters/claude/config/settings.json  -> settings.json       (rendered, seed only)
#
# Safety contract (same shape as the OpenCode adapter):
# - --dry-run is the DEFAULT and changes nothing. --check validates and
#   exits non-zero on drift. --apply is the only mode that writes.
# - Every replaced file or directory is first moved to
#   <name>.bak-YYYYmmdd-HHMMSS. Nothing is deleted.
# - settings.json is only seeded when missing: Claude Code edits it at
#   runtime (/config, permission prompts), so drift is reported, never
#   overwritten.
# - Machine-local content (memory, projects, sessions, plugins, Impeccable,
#   Anthropic-synced skills) is never touched.
# - CLAUDE_SETUP_DEST overrides ~/.claude for tests; it must be an absolute
#   path that is not ~/.claude itself.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: install.sh [--dry-run] [--check] [--apply] [--help]

  --dry-run   Print the deployment plan; change nothing (default).
  --check     Read-only: exit non-zero if live config differs from the repo.
  --apply     Back up and replace drifted entries. Requires operator approval.
USAGE
}

MODE="dry-run"
for arg in "$@"; do
  case "$arg" in
    --dry-run) MODE="dry-run" ;;
    --check) MODE="check" ;;
    --apply) MODE="apply" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Error: unknown argument: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

fail() { echo "Error: $1" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# adapters/claude/scripts -> repository root is three levels up.
REPO_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
ADAPTER="$REPO_DIR/adapters/claude"
for marker in core/instructions/AGENTS.md core/skills adapters/claude/config/CLAUDE.md; do
  [ -e "$REPO_DIR/$marker" ] || fail "invalid repository root (missing $marker): $REPO_DIR"
done

DEST="$HOME/.claude"
if [ "${CLAUDE_SETUP_DEST+set}" = "set" ]; then
  case "$CLAUDE_SETUP_DEST" in /?*) ;; *) fail "CLAUDE_SETUP_DEST must be a non-root absolute path." ;; esac
  mkdir -p "$CLAUDE_SETUP_DEST"
  DEST="$(cd "$CLAUDE_SETUP_DEST" && pwd -P)"
  [ "$DEST" != "$(cd "$HOME" && pwd -P)/.claude" ] || fail "CLAUDE_SETUP_DEST must not be the live ~/.claude."
  echo "SANDBOX MODE: $DEST"
fi

command -v opencode >/dev/null 2>&1 || echo "Note: opencode not on PATH; the opencode-delegate skill will report errors until it is installed."

STAMP="$(date +%Y%m%d-%H%M%S)"
DRIFT=0
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

render() { sed -e "s#@@REPO_DIR@@#$REPO_DIR#g" -e "s#@@HOME@@#$HOME#g" "$1"; }

backup() {
  local b="$1.bak-$STAMP" n=1
  while [ -e "$b" ] || [ -L "$b" ]; do b="$1.bak-$STAMP-$n"; n=$((n + 1)); done
  mv "$1" "$b"; echo "  backup  $b"
}

# link <source> <target>: target must be a symlink to source.
link() {
  local src="$1" dst="$2"
  [ "$(readlink "$dst" 2>/dev/null || true)" = "$src" ] && return 0
  DRIFT=1
  if [ -e "$dst" ] || [ -L "$dst" ]; then echo "replace  $dst -> $src"; else echo "link     $dst -> $src"; fi
  [ "$MODE" = apply ] || return 0
  mkdir -p "$(dirname "$dst")"
  { [ -e "$dst" ] || [ -L "$dst" ]; } && backup "$dst"
  ln -s "$src" "$dst"
}

# file <rendered> <target> [seed]: target must match rendered content.
file() {
  local src="$1" dst="$2" seed="${3:-}"
  [ -f "$dst" ] && [ ! -L "$dst" ] && cmp -s "$src" "$dst" && return 0
  if [ -n "$seed" ] && [ -e "$dst" ]; then
    echo "differs  $dst (runtime-managed; not replaced, compare with: diff $dst <rendered $seed>)"
    return 0
  fi
  DRIFT=1
  if [ -e "$dst" ] || [ -L "$dst" ]; then echo "replace  $dst"; else echo "write    $dst"; fi
  [ "$MODE" = apply ] || return 0
  mkdir -p "$(dirname "$dst")"
  { [ -e "$dst" ] || [ -L "$dst" ]; } && backup "$dst"
  cp "$src" "$dst"
}

echo "Mode: $MODE   Repo: $REPO_DIR   Dest: $DEST"

for d in "$REPO_DIR"/core/skills/*/ "$ADAPTER"/skills/*/; do
  d="${d%/}"; link "$d" "$DEST/skills/$(basename "$d")"
done
for f in "$ADAPTER"/agents/*.md; do link "$f" "$DEST/agents/$(basename "$f")"; done
for f in "$ADAPTER"/rules/*.md; do link "$f" "$DEST/rules/$(basename "$f")"; done

render "$ADAPTER/config/CLAUDE.md" > "$TMP/CLAUDE.md"
render "$ADAPTER/config/settings.json" > "$TMP/settings.json"
python3 -m json.tool "$TMP/settings.json" >/dev/null 2>&1 || fail "rendered settings.json is not valid JSON"
file "$TMP/CLAUDE.md" "$DEST/CLAUDE.md"
file "$TMP/settings.json" "$DEST/settings.json" adapters/claude/config/settings.json

if [ "$DRIFT" = 0 ]; then echo "Up to date."; exit 0; fi
case "$MODE" in
  check) echo "Drift found; run --apply to deploy."; exit 1 ;;
  dry-run) echo "Dry run: nothing changed. Run --apply to deploy." ;;
  apply) echo "Applied. Run --check to confirm." ;;
esac
