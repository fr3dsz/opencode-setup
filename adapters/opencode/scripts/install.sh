#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

OPENCODE_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
OPENCODE_SKILLS_DIR="$OPENCODE_CONFIG_DIR/skills"
SOURCE_SKILLS_DIR="$REPO_DIR/skills"
SOURCE_CONFIG="$REPO_DIR/config/opencode.jsonc"
TARGET_CONFIG="$OPENCODE_CONFIG_DIR/opencode.jsonc"

backup_file() {
  local file="$1"

  if [ -f "$file" ] && [ ! -f "$file.backup" ]; then
    cp "$file" "$file.backup"
    echo "Backed up: $file -> $file.backup"
  fi
}

if ! command -v node >/dev/null 2>&1; then
  echo "Error: Node.js is required but was not found."
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "Error: npm is required but was not found."
  exit 1
fi
if ! command -v opencode >/dev/null 2>&1; then
  echo "Error: OpenCode is required but was not found."
  exit 1
fi
if ! command -v codegraph >/dev/null 2>&1; then
  echo "CodeGraph not found. Installing..."
  npm install -g @colbymchenry/codegraph@1.6.0
else
  echo "CodeGraph found: $(codegraph --version)"
fi

IMPECCABLE_SKILL="$HOME/.agents/skills/impeccable/SKILL.md"

if [ ! -f "$IMPECCABLE_SKILL" ]; then
  echo "Impeccable not found. Installing..."
  npx skills add pbakaus/impeccable \
    --skill impeccable \
    --global \
    --agent opencode \
    --yes
else
  echo "Impeccable found."
fi

mkdir -p "$OPENCODE_CONFIG_DIR"
mkdir -p "$OPENCODE_SKILLS_DIR"

SOURCE_AGENTS="$REPO_DIR/AGENTS.md"
TARGET_AGENTS="$OPENCODE_CONFIG_DIR/AGENTS.md"

if [ -f "$TARGET_AGENTS" ] && cmp -s "$SOURCE_AGENTS" "$TARGET_AGENTS"; then
  echo "AGENTS.md already up to date."
else
  backup_file "$TARGET_AGENTS"
  cp "$SOURCE_AGENTS" "$TARGET_AGENTS"
  echo "Installed AGENTS.md."
fi

for source_skill in "$SOURCE_SKILLS_DIR"/*; do
  [ -d "$source_skill" ] || continue

  skill_name="$(basename "$source_skill")"
  target_skill="$OPENCODE_SKILLS_DIR/$skill_name"

  if [ -d "$target_skill" ] && diff -qr "$source_skill" "$target_skill" >/dev/null 2>&1; then
    echo "Skill already up to date: $skill_name"
    continue
  fi

  if [ -d "$target_skill" ]; then
    rm -rf "$target_skill.backup"
    cp -R "$target_skill" "$target_skill.backup"
    echo "Backed up skill: $skill_name"
  fi

  rm -rf "$target_skill"
  cp -R "$source_skill" "$target_skill"
  echo "Installed skill: $skill_name"
done

if [ -f "$TARGET_CONFIG" ] && cmp -s "$SOURCE_CONFIG" "$TARGET_CONFIG"; then
  echo "opencode.jsonc already up to date."
else
  backup_file "$TARGET_CONFIG"
  cp "$SOURCE_CONFIG" "$TARGET_CONFIG"
  echo "Installed opencode.jsonc."
fi

echo "OpenCode Setup"
echo "Repository: $REPO_DIR"
echo "OpenCode config: $OPENCODE_CONFIG_DIR"
echo "OpenCode skills: $OPENCODE_SKILLS_DIR"
