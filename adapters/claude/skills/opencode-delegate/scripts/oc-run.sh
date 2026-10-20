#!/usr/bin/env bash
# Run one OpenCode task headlessly on a (free) model for Claude Code to review.
#
#   oc-run.sh [--mode implement|review] [-m provider/model] [-t seconds] [-f file]... -- "prompt"
#   oc-run.sh --undo <run-id>     restore exactly the files a run changed
#   oc-run.sh --models            list free models
#
# implement: OpenCode build agent, may edit files; requires a git work tree.
# review:    OpenCode plan agent (read-only); reports any file it changed anyway.
# Commits and pushes are blocked during the run. Prints a summary, the changed
# files, and the tail of the model's answer; the full log path is printed too.
set -uo pipefail

MODEL="${OC_DELEGATE_MODEL:-opencode/deepseek-v4.1-flash-free}"
TIMEOUT="${OC_DELEGATE_TIMEOUT:-600}"
MODE=implement
FILES=()
STATE="${OC_DELEGATE_HOME:-$HOME/.claude/opencode-delegate}"

die() { echo "oc-run: $*" >&2; exit 2; }

file_blob() { [ -e "$1" ] || [ -L "$1" ] && git hash-object -w -- "$1" || echo ABSENT; }

undo() {
  local dir="$STATE/runs/$1" pre path
  [ -f "$dir/manifest.tsv" ] || die "no manifest for run $1"
  cd "$(cat "$dir/root")" || die "repo root missing"
  while IFS=$'\t' read -r pre path; do
    if [ "$pre" = ABSENT ]; then rm -f -- "$path"; echo "removed  $path"
    else mkdir -p -- "$(dirname -- "$path")"; git cat-file blob "$pre" > "$path"; echo "restored $path"; fi
  done < "$dir/manifest.tsv"
  # Restore index entries the run staged or unstaged.
  git ls-files -s > "$dir/index.now"
  { cut -f2 "$dir/index.pre"; cut -f2 "$dir/index.now"; } | sort -u | while IFS= read -r path; do
    a="$(awk -F'\t' -v p="$path" '$2==p{print $1}' "$dir/index.pre")"
    b="$(awk -F'\t' -v p="$path" '$2==p{print $1}' "$dir/index.now")"
    [ "$a" = "$b" ] && continue
    if [ -z "$a" ]; then git rm -q --cached -- "$path"
    else set -- $a; git update-index --add --cacheinfo "$1,$2,$path"; fi
    echo "index    $path"
  done
  exit 0
}

while [ $# -gt 0 ]; do
  case "$1" in
    --mode) MODE="$2"; shift 2 ;;
    -m|--model) MODEL="$2"; shift 2 ;;
    -t|--timeout) TIMEOUT="$2"; shift 2 ;;
    -f|--file) FILES+=("$2"); shift 2 ;;
    --undo) undo "$2" ;;
    --models) opencode models < /dev/null 2>/dev/null | grep -E -- '-free$|big-pickle'; exit 0 ;;
    --) shift; break ;;
    *) break ;;
  esac
done
PROMPT="$*"
[ -n "$PROMPT" ] || die "empty prompt"
case "$MODE" in implement) AGENT=build ;; review) AGENT=plan ;; *) die "unknown mode $MODE" ;; esac

IN_GIT=0; git rev-parse --is-inside-work-tree >/dev/null 2>&1 && IN_GIT=1
[ "$MODE" = implement ] && [ $IN_GIT = 0 ] && die "implement mode needs a git work tree (changes must be reviewable and undoable)"

RUN_ID="$(date +%Y%m%d-%H%M%S)-$$"
RUN="$STATE/runs/$RUN_ID"; mkdir -p "$RUN"
LOG="$RUN/output.log"

# Snapshot files that already differ from HEAD so undo restores Claude's own edits, not HEAD.
if [ $IN_GIT = 1 ]; then
  ROOT="$(git rev-parse --show-toplevel)"; cd "$ROOT"; echo "$ROOT" > "$RUN/root"
  HEAD0="$(git rev-parse -q --verify HEAD || echo NONE)"
  { git diff --name-only HEAD 2>/dev/null; git ls-files -o --exclude-standard; } | sort -u > "$RUN/pre-paths"
  while IFS= read -r p; do printf '%s\t%s\n' "$(file_blob "$p")" "$p"; done < "$RUN/pre-paths" > "$RUN/pre.tsv"
  git ls-files -s > "$RUN/index.pre"
  HOOKS="$RUN/hooks"; mkdir -p "$HOOKS"
  for h in pre-commit pre-push pre-merge-commit; do
    printf '#!/bin/sh\necho "blocked: delegated OpenCode runs may not commit or push" >&2\nexit 1\n' > "$HOOKS/$h"
    chmod +x "$HOOKS/$h"
  done
  export GIT_CONFIG_COUNT=2 \
    GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0="$HOOKS" \
    GIT_CONFIG_KEY_1=url.blocked-by-oc-run://.pushInsteadOf GIT_CONFIG_VALUE_1=""
fi

ARGS=(run --standalone --auto --agent "$AGENT" -m "$MODEL" --title "claude-delegate $RUN_ID")
for f in "${FILES[@]+"${FILES[@]}"}"; do ARGS+=(-f "$f"); done
ARGS+=("$PROMPT")

START=$(date +%s)
opencode "${ARGS[@]}" < /dev/null > "$LOG" 2>&1 &
PID=$!
# Watchdog must not hold our stdout open, or callers block until it expires.
( sleep "$TIMEOUT"; pkill -TERM -P "$PID" 2>/dev/null; kill -TERM "$PID" 2>/dev/null ) > /dev/null 2>&1 & WATCH=$!
wait "$PID"; RC=$?
pkill -P "$WATCH" 2>/dev/null; kill "$WATCH" 2>/dev/null; wait "$WATCH" 2>/dev/null
ELAPSED=$(( $(date +%s) - START ))

STATUS=ok
[ $RC -ne 0 ] && STATUS="failed (exit $RC)"
[ $RC -eq 143 ] && STATUS="timeout after ${TIMEOUT}s"
# OpenCode can exit 0 on provider errors, so inspect the output as well.
if grep -qE '^(\x1b\[[0-9;]*m)*Error:|AI\.Error|API key has expired|rate limit' "$LOG"; then STATUS="failed (provider/runtime error)"; fi

CHANGED=0
if [ $IN_GIT = 1 ]; then
  { cut -f2 "$RUN/pre.tsv"; git diff --name-only HEAD 2>/dev/null; git ls-files -o --exclude-standard; } | sort -u > "$RUN/post-paths"
  : > "$RUN/manifest.tsv"
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    pre="$(awk -F'\t' -v p="$p" '$2==p{print $1; exit}' "$RUN/pre.tsv")"
    if [ -z "$pre" ]; then
      pre="$( [ "$HEAD0" != NONE ] && git rev-parse -q --verify "$HEAD0:$p" 2>/dev/null || echo ABSENT )"
    fi
    now="$(file_blob "$p")"
    [ "$pre" != "$now" ] && printf '%s\t%s\n' "$pre" "$p" >> "$RUN/manifest.tsv"
  done < "$RUN/post-paths"
  CHANGED=$(wc -l < "$RUN/manifest.tsv" | tr -d ' ')
  HEAD1="$(git rev-parse -q --verify HEAD || echo NONE)"
fi

echo "run-id:   $RUN_ID"
echo "model:    $MODEL ($AGENT agent, $MODE mode)"
echo "status:   $STATUS in ${ELAPSED}s"
echo "log:      $LOG"
if [ $IN_GIT = 1 ]; then
  [ "$HEAD0" != "$HEAD1" ] && echo "WARNING:  HEAD moved $HEAD0 -> $HEAD1 (undo does not cover commits)"
  [ "$MODE" = review ] && [ "$CHANGED" -gt 0 ] && echo "WARNING:  review run changed files"
  echo "changed:  $CHANGED file(s)   (undo: $0 --undo $RUN_ID)"
  awk -F'\t' '{print ($1=="ABSENT" ? "  + " : "  ~ ") $2}' "$RUN/manifest.tsv"
fi
echo "--- answer (tail) ---"
sed -E 's/\x1b\[[0-9;]*m//g' "$LOG" | grep -vE '^timestamp=' | tail -n "${OC_DELEGATE_TAIL:-60}"

case "$STATUS" in ok) exit 0 ;; *) exit 1 ;; esac
