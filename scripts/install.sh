#!/usr/bin/env bash
#
# OpenCode setup installer (macOS / Linux).
#
# Deploys repository content to live OpenCode configuration:
#   instructions/AGENTS.md  -> ~/.config/opencode/AGENTS.md
#   skills/*                -> ~/.config/opencode/skills/*
#   config/opencode.jsonc   -> ~/.config/opencode/opencode.jsonc (rendered)
#
# Safety contract (mirrored by install.ps1):
# - --dry-run is the DEFAULT. It prints the full deployment plan and changes
#   nothing. --check performs read-only validation and exits before any
#   write. --apply is the ONLY mode permitted to write live configuration.
# - Failure-before-write: every input is resolved and validated, and every
#   rendered output is verified, BEFORE the first write. Any failure aborts
#   with a clear message before anything is written.
# - Timestamped backups (<name>.bak-YYYYmmdd-HHMMSS) precede every
#   replacement. Deployment is ordered per file, NOT atomic across files:
#   each file is backed up and replaced individually.
# - A working live configuration is never overwritten without explicit
#   deployment approval (an explicit --apply invocation by the operator).
# - Skill backups go to setup-backups/skills/, outside skills/, so OpenCode
#   never discovers a backup as a duplicate skill.
# - No automatic installation of Node, GitNexus, chrome-devtools-mcp, or any
#   package. No repository indexing. Impeccable is an optional existing dependency
#   documented in README.md; this installer does not install it.

set -euo pipefail

REQUIRED_NODE_VERSION="v22.23.2"
REQUIRED_GITNEXUS_VERSION="1.6.12"
REQUIRED_DEVTOOLS_VERSION="1.12.0"
REQUIRED_OPENCODE_MAJOR="2"

usage() {
  cat <<'USAGE'
Usage: install.sh [--dry-run] [--check] [--apply] [--help]

  --dry-run   Print the deployment plan; change nothing (default).
  --check     Read-only validation of inputs and rendered outputs; exit
              before any write. Exit non-zero on any validation failure.
  --apply     Validate everything, then write live configuration with
              timestamped backups. Requires explicit operator approval.
  --help      Print this help.
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# scripts -> repository root is one level up.
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Verify the resolved root before using it (marker files, not machine paths).
for marker in "instructions/AGENTS.md" "skills" "config/opencode.jsonc"; do
  if [ ! -e "$REPO_DIR/$marker" ]; then
    echo "Error: resolved repository root is invalid (missing $marker): $REPO_DIR" >&2
    exit 1
  fi
done

fail() { echo "Error: $1" >&2; exit 1; }

LIVE_DEFAULT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
if [ "${OPENCODE_SETUP_DEST+set}" = "set" ]; then
  # Test-only destination override. The production default is unchanged
  # when OPENCODE_SETUP_DEST is unset. Every managed write and backup below
  # derives from OPENCODE_CONFIG_DIR, so validation here covers all of them.
  [ -n "$OPENCODE_SETUP_DEST" ] || fail "OPENCODE_SETUP_DEST must not be empty."
  case "$OPENCODE_SETUP_DEST" in
    /*) ;;
    *) fail "OPENCODE_SETUP_DEST must be an absolute path: $OPENCODE_SETUP_DEST" ;;
  esac
  [ "$OPENCODE_SETUP_DEST" != "/" ] || fail "OPENCODE_SETUP_DEST must not be the filesystem root."
  mkdir -p "$OPENCODE_SETUP_DEST" || fail "Cannot create sandbox destination: $OPENCODE_SETUP_DEST."
  # Canonicalize (resolving symlinks) before any containment check.
  SANDBOX_DIR="$(cd "$OPENCODE_SETUP_DEST" && pwd -P)"
  if [ -d "$LIVE_DEFAULT_DIR" ]; then
    LIVE_CANON="$(cd "$LIVE_DEFAULT_DIR" && pwd -P)"
  else
    LIVE_CANON="$LIVE_DEFAULT_DIR"
  fi
  [ "$SANDBOX_DIR" != "$LIVE_CANON" ] || fail "OPENCODE_SETUP_DEST resolves to the live configuration; refusing unsafe destination."
  case "$LIVE_CANON/" in
    "$SANDBOX_DIR/"*) fail "OPENCODE_SETUP_DEST is an ancestor of the live configuration; refusing unsafe destination." ;;
  esac
  case "$SANDBOX_DIR/" in
    "$LIVE_CANON/"*) fail "OPENCODE_SETUP_DEST is inside the live configuration; refusing unsafe destination." ;;
  esac
  OPENCODE_CONFIG_DIR="$SANDBOX_DIR"
  echo "SANDBOX MODE: all writes redirected to $OPENCODE_CONFIG_DIR"
else
  OPENCODE_CONFIG_DIR="$LIVE_DEFAULT_DIR"
fi
OPENCODE_SKILLS_DIR="$OPENCODE_CONFIG_DIR/skills"
SOURCE_SKILLS_DIR="$REPO_DIR/skills"
SOURCE_AGENTS="$REPO_DIR/instructions/AGENTS.md"
SOURCE_TEMPLATE="$REPO_DIR/config/opencode.jsonc"
TARGET_AGENTS="$OPENCODE_CONFIG_DIR/AGENTS.md"
TARGET_CONFIG="$OPENCODE_CONFIG_DIR/opencode.jsonc"

# --- Discovery (no personal absolute paths; $HOME is portable) ---

find_node() {
  local pinned="$HOME/.nvm/versions/node/$REQUIRED_NODE_VERSION/bin/node"
  if [ -x "$pinned" ]; then
    local v
    v="$("$pinned" --version 2>/dev/null || true)"
    if [ "$v" = "$REQUIRED_NODE_VERSION" ]; then
      printf '%s' "$pinned"
      return 0
    fi
    echo "Warning: pinned node $pinned reports '$v', required '$REQUIRED_NODE_VERSION'." >&2
  fi
  # PATH node is accepted only on exact version match; never assumed suitable.
  if command -v node >/dev/null 2>&1; then
    local v
    v="$(node --version 2>/dev/null || true)"
    if [ "$v" = "$REQUIRED_NODE_VERSION" ]; then
      command -v node
      return 0
    fi
    echo "Warning: PATH node reports '$v', required '$REQUIRED_NODE_VERSION'; ignoring PATH node." >&2
  fi
  return 1
}

find_gitnexus_cli() {
  local node_bin="$1"
  local node_dir
  node_dir="$(cd "$(dirname "$node_bin")/.." && pwd)"
  local sibling="$node_dir/lib/node_modules/gitnexus/dist/cli/index.js"
  if [ -f "$sibling" ]; then
    printf '%s' "$sibling"
    return 0
  fi
  if command -v gitnexus >/dev/null 2>&1; then
    echo "Warning: no GitNexus CLI in the resolved Node tree; falling back to PATH gitnexus (version still verified)." >&2
    command -v gitnexus
    return 0
  fi
  return 1
}

# Backup-pattern files are live-operator artifacts: they never deploy from
# the repo and never block up-to-date detection. They are swept into the
# timestamped backup only when a payload write actually occurs.
find_devtools_cli() {
  local node_dir
  node_dir="$(cd "$(dirname "$1")/.." && pwd)"
  local cli="$node_dir/lib/node_modules/chrome-devtools-mcp/build/src/bin/chrome-devtools-mcp.js"
  [ -f "$cli" ] || return 1
  printf '%s' "$cli"
}

skills_equal() {
  diff -qr -x '*.backup' -x '*.bak-*' -x '*.pre-gitnexus-*' "$1" "$2" >/dev/null 2>&1
}

echo "Mode: $MODE"
echo "Repository: $REPO_DIR"

command -v opencode >/dev/null 2>&1 || fail "OpenCode is required but was not found on PATH."
OPENCODE_VERSION="$(opencode --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || true)"
case "$OPENCODE_VERSION" in
  "$REQUIRED_OPENCODE_MAJOR".*) echo "OpenCode found: $OPENCODE_VERSION" ;;
  *) fail "OpenCode reports '$OPENCODE_VERSION', required $REQUIRED_OPENCODE_MAJOR.x (the config uses the 2.x schema)." ;;
esac

NODE_BIN="$(find_node)" || fail "No suitable Node found (required $REQUIRED_NODE_VERSION). Install it via nvm and re-run with --check."
echo "Node: $NODE_BIN ($("$NODE_BIN" --version))"

GITNEXUS_CLI="$(find_gitnexus_cli "$NODE_BIN")" || fail "GitNexus CLI not found for the resolved Node tree."
GITNEXUS_VERSION="$("$NODE_BIN" "$GITNEXUS_CLI" --version 2>/dev/null || true)"
[ "$GITNEXUS_VERSION" = "$REQUIRED_GITNEXUS_VERSION" ] || fail "GitNexus reports '$GITNEXUS_VERSION', required '$REQUIRED_GITNEXUS_VERSION'. Will not proceed."
echo "GitNexus: $GITNEXUS_CLI ($GITNEXUS_VERSION)"

DEVTOOLS_CLI="$(find_devtools_cli "$NODE_BIN")" || fail "chrome-devtools-mcp not found in the resolved Node tree. Install it: $(dirname "$NODE_BIN")/npm install -g --ignore-scripts chrome-devtools-mcp@$REQUIRED_DEVTOOLS_VERSION"
DEVTOOLS_VERSION="$("$NODE_BIN" -p "require(process.argv[1]).version" "$(dirname "$DEVTOOLS_CLI")/../../../package.json" 2>/dev/null || true)"
[ "$DEVTOOLS_VERSION" = "$REQUIRED_DEVTOOLS_VERSION" ] || fail "chrome-devtools-mcp reports '$DEVTOOLS_VERSION', required '$REQUIRED_DEVTOOLS_VERSION'. Will not proceed."
echo "Chrome DevTools MCP: $DEVTOOLS_CLI ($DEVTOOLS_VERSION)"

# --- Template validation and rendering (installer-owned @@PLACEHOLDER@@ syntax) ---

for placeholder in NODE GITNEXUS_CLI DEVTOOLS_CLI; do
  grep -q "@@${placeholder}@@" "$SOURCE_TEMPLATE" || fail "Template missing @@${placeholder}@@ placeholder."
done

RENDERED_TMP="$(mktemp "${TMPDIR:-/tmp}/opencode.jsonc.XXXXXX")"
# B1: staging files are unique (mktemp) and removed on every exit path,
# including validation failures and signals (EXIT trap).
trap 'rm -f "$RENDERED_TMP"; if [ -n "${CONFIG_TMP:-}" ]; then rm -f "$CONFIG_TMP"; fi' EXIT

# Escape sed replacement metacharacters in resolved paths.
sed_escape() { printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'; }
# Template documentation uses full-line comments only; the renderer strips
# them so the deployed live config stays minimal JSONC.
sed -e "s|@@NODE@@|$(sed_escape "$NODE_BIN")|g" \
    -e "s|@@GITNEXUS_CLI@@|$(sed_escape "$GITNEXUS_CLI")|g" \
    -e "s|@@DEVTOOLS_CLI@@|$(sed_escape "$DEVTOOLS_CLI")|g" \
    "$SOURCE_TEMPLATE" | grep -v '^[[:space:]]*//' > "$RENDERED_TMP"

if grep -Eq '@@[A-Z_]+@@' "$RENDERED_TMP"; then
  fail "Unresolved placeholders remain in rendered config; refusing to deploy."
fi
if grep -Eq '^[[:space:]]*//' "$RENDERED_TMP"; then
  fail "Template documentation comments leaked into rendered config; refusing to deploy."
fi
grep -q '"gitnexus"' "$RENDERED_TMP" || fail "Rendered config missing gitnexus entry; refusing to deploy."
grep -q '"chrome-devtools"' "$RENDERED_TMP" || fail "Rendered config missing chrome-devtools entry; refusing to deploy."
[ -s "$RENDERED_TMP" ] || fail "Rendered config is empty; refusing to deploy."
echo "Template rendered and verified (placeholders resolved, MCP entries present)."

# --- Deployment plan (computed without writing) ---

PLAN_AGENTS="up-to-date"
if [ ! -f "$TARGET_AGENTS" ] || ! cmp -s "$SOURCE_AGENTS" "$TARGET_AGENTS"; then
  PLAN_AGENTS="will-write"
fi
PLAN_CONFIG="up-to-date"
if [ ! -f "$TARGET_CONFIG" ] || ! cmp -s "$RENDERED_TMP" "$TARGET_CONFIG"; then
  PLAN_CONFIG="will-write"
fi

echo "Plan:"
echo "  AGENTS.md ($TARGET_AGENTS): $PLAN_AGENTS"
echo "  opencode.jsonc ($TARGET_CONFIG): $PLAN_CONFIG [rendered, absolute-path stdio launch]"
for source_skill in "$SOURCE_SKILLS_DIR"/*; do
  [ -d "$source_skill" ] || continue
  skill_name="$(basename "$source_skill")"
  [ -f "$source_skill/SKILL.md" ] || fail "Source skill missing SKILL.md: $skill_name"
  target_skill="$OPENCODE_SKILLS_DIR/$skill_name"
  if [ -d "$target_skill" ] && skills_equal "$source_skill" "$target_skill"; then
    extras="$(cd "$target_skill" && find . \( -name '*.backup' -o -name '*.bak-*' -o -name '*.pre-gitnexus-*' \) -print | head -n 5)"
    if [ -n "$extras" ]; then
      echo "  skill $skill_name: up-to-date (live-only extras preserved, not deployed)"
    else
      echo "  skill $skill_name: up-to-date"
    fi
  else
    echo "  skill $skill_name: will-write"
  fi
done

if [ "$MODE" = "check" ]; then
  echo "Check passed: all inputs and rendered outputs valid. No changes made."
  exit 0
fi
if [ "$MODE" = "dry-run" ]; then
  echo "Dry run: no changes made. Re-run with --apply to deploy with timestamped backups."
  exit 0
fi

# --- --apply: ordered, per-file backup + replace (NOT atomic across files) ---

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
# B2: collision-safe backup names. An existing backup is never overwritten;
# a numeric suffix is appended until the name is free.
unique_backup_path() {
  local base="$1"
  local cand="$base.bak-$TIMESTAMP"
  local i=1
  while [ -e "$cand" ]; do
    cand="$base.bak-$TIMESTAMP-$i"
    i=$((i + 1))
  done
  printf '%s' "$cand"
}
backup_file() {
  local file="$1"
  if [ -e "$file" ]; then
    local dest
    dest="$(unique_backup_path "$file")"
    cp "$file" "$dest" || fail "Backup failed for $file; aborting before further writes."
    echo "Backed up: $file -> $dest"
  fi
}

mkdir -p "$OPENCODE_CONFIG_DIR" || fail "Cannot create $OPENCODE_CONFIG_DIR."
mkdir -p "$OPENCODE_SKILLS_DIR" || fail "Cannot create $OPENCODE_SKILLS_DIR."

if [ "$PLAN_AGENTS" = "will-write" ]; then
  backup_file "$TARGET_AGENTS"
  cp "$SOURCE_AGENTS" "$TARGET_AGENTS" || fail "Failed writing $TARGET_AGENTS."
  echo "Installed AGENTS.md."
else
  echo "AGENTS.md already up to date."
fi

for source_skill in "$SOURCE_SKILLS_DIR"/*; do
  [ -d "$source_skill" ] || continue
  skill_name="$(basename "$source_skill")"
  target_skill="$OPENCODE_SKILLS_DIR/$skill_name"
  if [ -d "$target_skill" ] && skills_equal "$source_skill" "$target_skill"; then
    echo "Skill already up to date: $skill_name"
    continue
  fi
  if [ -d "$target_skill" ]; then
    mkdir -p "$OPENCODE_CONFIG_DIR/setup-backups/skills" || fail "Cannot create skill backup directory."
    skill_backup="$(unique_backup_path "$OPENCODE_CONFIG_DIR/setup-backups/skills/$skill_name")"
    cp -R "$target_skill" "$skill_backup" || fail "Backup failed for skill $skill_name; aborting."
    echo "Backed up skill: $skill_name -> $skill_backup"
    rm -rf "$target_skill"
  fi
  cp -R "$source_skill" "$target_skill" || fail "Failed installing skill $skill_name."
  echo "Installed skill: $skill_name"
done

if [ "$PLAN_CONFIG" = "will-write" ]; then
  CONFIG_TMP="$(mktemp "$OPENCODE_CONFIG_DIR/opencode.jsonc.tmp.XXXXXX")"
  cp "$RENDERED_TMP" "$CONFIG_TMP" || fail "Failed staging rendered config."
  backup_file "$TARGET_CONFIG"
  mv "$CONFIG_TMP" "$TARGET_CONFIG" || fail "Failed activating rendered config."
  echo "Installed opencode.jsonc (rendered)."
else
  echo "opencode.jsonc already up to date."
fi

echo "Deployment complete (ordered per-file replacement with backups; verify with --check)."
echo "Repository: $REPO_DIR"
echo "OpenCode config: $OPENCODE_CONFIG_DIR"
echo "OpenCode skills: $OPENCODE_SKILLS_DIR"
