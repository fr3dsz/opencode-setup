#!/usr/bin/env bash
#
# Validates skills, agents, and rules: frontmatter present, skill name matches
# its directory, SKILL.md within the line budget, and no forbidden strings
# anywhere in the repository content.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAX_SKILL_LINES="${MAX_SKILL_LINES:-120}"
GLOBAL_FORBIDDEN='INTERNAL ONLY|CONFIDENTIAL'
# Extra private terms, one regex per line, kept out of git.
if [ -f "$REPO_DIR/.lint-forbidden" ]; then
  while IFS= read -r term; do
    [ -n "$term" ] && GLOBAL_FORBIDDEN="$GLOBAL_FORBIDDEN|$term"
  done < "$REPO_DIR/.lint-forbidden"
fi
CONTENT_FORBIDDEN='opencode-delegate|oc-run\.sh'
CONTENT_PATHS=(skills instructions config README.md)
ERRORS=0

err() { echo "FAIL  $1"; ERRORS=$((ERRORS + 1)); }

frontmatter_field() {
  awk -v key="$2" 'NR == 1 && $0 != "---" { exit } NR > 1 && $0 == "---" { exit }
    NR > 1 && index($0, key ": ") == 1 { print substr($0, length(key) + 3); exit }' "$1"
}

for skill in "$REPO_DIR"/skills/*/; do
  dir="$(basename "$skill")"
  file="$skill/SKILL.md"
  [ -f "$file" ] || { err "skills/$dir: missing SKILL.md"; continue; }
  name="$(frontmatter_field "$file" name)"
  [ "$name" = "$dir" ] || err "skills/$dir: frontmatter name '$name' does not match directory"
  [ -n "$(frontmatter_field "$file" description)" ] || err "skills/$dir: missing description"
  lines="$(wc -l < "$file" | tr -d ' ')"
  [ "$lines" -le "$MAX_SKILL_LINES" ] || err "skills/$dir: $lines lines exceeds budget $MAX_SKILL_LINES"
done

for f in "$REPO_DIR"/agents/*.md; do
  [ -e "$f" ] || continue
  for key in name description; do
    [ -n "$(frontmatter_field "$f" "$key")" ] || err "agents/$(basename "$f"): missing $key"
  done
done

for f in "$REPO_DIR"/rules/*.md; do
  [ -e "$f" ] || continue
  head -1 "$f" | grep -qx -- '---' || err "rules/$(basename "$f"): missing frontmatter"
done

hits="$(grep -rnE "$GLOBAL_FORBIDDEN" "$REPO_DIR" --exclude-dir=.git --exclude=lint-skills.sh --exclude=.lint-forbidden || true)"
[ -z "$hits" ] || { err "forbidden strings found:"; echo "$hits"; }
hits="$(cd "$REPO_DIR" && grep -rnE "$CONTENT_FORBIDDEN" "${CONTENT_PATHS[@]}" 2>/dev/null || true)"
[ -z "$hits" ] || { err "retired references found:"; echo "$hits"; }

if [ "$ERRORS" -gt 0 ]; then echo "$ERRORS problem(s)."; exit 1; fi
echo "OK: skills, agents, and rules are valid."
