#!/usr/bin/env bash
#
# Isolated installer test matrix (macOS). Exercises install.sh end to end
# against a disposable sandbox WITHOUT touching the live configuration.
#
# Safety design:
# - Every installer invocation routes through run_isolated(), which refuses
#   to run unless OPENCODE_SETUP_DEST is set to a directory inside SANDBOX.
# - The single exception is T0, which uses read-only --check to prove the
#   installer itself refuses live-equivalent and other unsafe destinations.
# - assert_live_untouched() snapshots the live tree (file list + md5) before
#   and after every test and fails the suite on any delta.
# - Failure injection is sandbox-only and deterministic (fixture copies,
#   type conflicts, seeded stale content). No chmod tricks, no live copies:
#   fixtures are synthesized; expected outputs derive from the repository
#   template and the paths the installer itself reports.
# - Set KEEP_SANDBOX=1 to retain the sandbox for post-mortem inspection.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
for marker in "instructions/AGENTS.md" "skills" "config/opencode.jsonc" "scripts/install.sh"; do
  if [ ! -e "$REPO_DIR/$marker" ]; then
    echo "FATAL: repository marker missing: $marker" >&2
    exit 2
  fi
done

INSTALLER="$REPO_DIR/scripts/install.sh"
LIVE_DIR="$HOME/.config/opencode"

SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/ocsetup-test.XXXXXX")"
# Canonicalize (macOS TMPDIR traverses the /var -> /private/var symlink) so
# sandbox-prefix assertions match the installer's own canonicalized paths.
SANDBOX="$(cd "$SANDBOX" && pwd -P)"
trap 'if [ "${KEEP_SANDBOX:-0}" != "1" ]; then rm -rf "$SANDBOX"; fi' EXIT

PASS=0
FAIL=0
pass() { PASS=$((PASS + 1)); echo "PASS: $1"; }
fail() { FAIL=$((FAIL + 1)); echo "FAIL: $1"; }

live_manifest() {
  if [ -d "$LIVE_DIR" ]; then
    find "$LIVE_DIR" -type f | LC_ALL=C sort | xargs md5 -r 2>/dev/null
    find "$LIVE_DIR" -type d | LC_ALL=C sort
  fi
}

assert_live_untouched() {
  local name="$1" before="$2"
  local after
  after="$(live_manifest)"
  if [ "$before" = "$after" ]; then
    pass "$name: live configuration untouched"
  else
    fail "$name: LIVE TREE CHANGED (see diff below)"
    diff <(printf '%s\n' "$before") <(printf '%s\n' "$after") || true
  fi
}

# Route every installer call through here. Aborts unless the override points
# inside our sandbox. No test may invoke --apply any other way.
run_isolated() {
  if [ -z "${OPENCODE_SETUP_DEST:-}" ]; then
    fail "refusing to run installer: OPENCODE_SETUP_DEST is unset"
    return 1
  fi
  case "$OPENCODE_SETUP_DEST" in
    "$SANDBOX"/*) ;;
    *) fail "refusing to run installer: destination outside sandbox: $OPENCODE_SETUP_DEST"; return 1 ;;
  esac
  "$INSTALLER" "$@" >"$SANDBOX/last-out.txt" 2>&1
}

# Every absolute target path printed in the plan must live under the sandbox.
assert_plan_sandboxed() {
  local name="$1"
  local bad
  bad="$(grep -o '([^)]*)' "$SANDBOX/last-out.txt" | tr -d '()' | grep '^/' | grep -v "^$SANDBOX/" || true)"
  if [ -z "$bad" ]; then
    pass "$name: all plan targets inside sandbox"
  else
    fail "$name: plan targets outside sandbox: $bad"
  fi
}

reported_path() { awk -v k="$1:" '$1 == k {print $2}' "$SANDBOX/last-out.txt"; }

set_dest() {
  export OPENCODE_SETUP_DEST="$SANDBOX/$1"
}

echo "Sandbox: $SANDBOX"
echo "Live (read-only oracle/manifest): $LIVE_DIR"
SUITE_BEFORE="$(live_manifest)"

# --- T0: interlock refuses unsafe destinations (read-only --check only) ---
for bad in "" "relative/path" "/" "$LIVE_DIR" "$HOME"; do
  export OPENCODE_SETUP_DEST="$bad"
  if OPENCODE_SETUP_DEST="$bad" "$INSTALLER" --check >"$SANDBOX/last-out.txt" 2>&1; then
    fail "T0: unsafe destination accepted: '${bad:-<empty>}'"
  else
    if grep -qi "refus\|must not\|must be" "$SANDBOX/last-out.txt"; then
      pass "T0: refused unsafe destination '${bad:-<empty>}'"
    else
      fail "T0: rejected '${bad:-<empty>}' without a clear message"
    fi
  fi
done
mkdir -p "$SANDBOX/livelink-target"
ln -sfn "$LIVE_DIR" "$SANDBOX/livelink"
export OPENCODE_SETUP_DEST="$SANDBOX/livelink"
if "$INSTALLER" --check >"$SANDBOX/last-out.txt" 2>&1; then
  fail "T0: symlink-aliased live destination accepted"
else
  pass "T0: refused symlink-aliased live destination"
fi
assert_live_untouched "T0" "$SUITE_BEFORE"

# --- T-dry: default mode is dry-run and writes nothing managed ---
set_dest "cfg-dry"
BEFORE="$(live_manifest)"
run_isolated
if grep -q "^Mode: dry-run" "$SANDBOX/last-out.txt" && grep -q "no changes made" "$SANDBOX/last-out.txt"; then
  pass "T-dry: default mode is dry-run"
else
  fail "T-dry: default mode is not dry-run"
fi
if [ -z "$(find "$SANDBOX/cfg-dry" -type f 2>/dev/null)" ]; then
  pass "T-dry: no managed files written"
else
  fail "T-dry: files written during dry run"
fi
assert_plan_sandboxed "T-dry"
assert_live_untouched "T-dry" "$BEFORE"

# --- T1: empty destination deploys fully ---
set_dest "cfg"
BEFORE="$(live_manifest)"
run_isolated --check || fail "T1: --check failed on empty destination"
assert_plan_sandboxed "T1-check"
run_isolated --apply || fail "T1: --apply failed on empty destination"
assert_plan_sandboxed "T1-apply"
NODE_BIN="$(reported_path Node)"
CLI_PATH="$(reported_path GitNexus)"
if [ -f "$SANDBOX/cfg/AGENTS.md" ] && cmp -s "$REPO_DIR/instructions/AGENTS.md" "$SANDBOX/cfg/AGENTS.md"; then
  pass "T1: AGENTS.md deployed"
else
  fail "T1: AGENTS.md missing or mismatched"
fi
ALL_SKILLS=1
SKILL_COUNT=0
for d in "$REPO_DIR"/skills/*/; do
  n="$(basename "$d")"
  SKILL_COUNT=$((SKILL_COUNT + 1))
  if [ ! -f "$SANDBOX/cfg/skills/$n/SKILL.md" ]; then ALL_SKILLS=0; fi
done
[ "$ALL_SKILLS" = "1" ] && pass "T1: all $SKILL_COUNT skills deployed" || fail "T1: skill set incomplete"
if grep -Eq '@@[A-Z_]+@@' "$SANDBOX/cfg/opencode.jsonc"; then
  fail "T1: unresolved placeholders in deployed config"
else
  pass "T1: no unresolved placeholders"
fi
if grep -qF "$NODE_BIN" "$SANDBOX/cfg/opencode.jsonc" && grep -qF "$CLI_PATH" "$SANDBOX/cfg/opencode.jsonc" && grep -q '"gitnexus"' "$SANDBOX/cfg/opencode.jsonc"; then
  pass "T1: deployed config carries installer-reported paths"
else
  fail "T1: deployed config does not match installer-reported paths"
fi
if [ -z "$(find "$SANDBOX/cfg" -name '*.bak-*' 2>/dev/null)" ]; then
  pass "T1: fresh deploy created no backups"
else
  fail "T1: unexpected backups on fresh deploy"
fi
assert_live_untouched "T1" "$BEFORE"

# --- T2: up-to-date destination converges with no new backups ---
BEFORE="$(live_manifest)"
BACKUPS_BEFORE="$(find "$SANDBOX/cfg" -name '*.bak-*' | wc -l)"
run_isolated --apply || fail "T2: --apply failed on up-to-date destination"
if grep -q "will-write" "$SANDBOX/last-out.txt"; then
  fail "T2: up-to-date destination still plans writes"
else
  pass "T2: second apply plans no writes"
fi
BACKUPS_AFTER="$(find "$SANDBOX/cfg" -name '*.bak-*' | wc -l)"
[ "$BACKUPS_BEFORE" = "$BACKUPS_AFTER" ] && pass "T2: no new backups" || fail "T2: backup count changed"
assert_live_untouched "T2" "$BEFORE"

# --- T3: outdated content is replaced with byte-verified backups ---
rm -rf "$SANDBOX/good" && cp -R "$SANDBOX/cfg" "$SANDBOX/good"
printf 'STALE-FIXTURE-AGENTS\n' > "$SANDBOX/cfg/AGENTS.md"
printf 'STALE-FIXTURE-SKILL\n' > "$SANDBOX/cfg/skills/debugging/SKILL.md"
printf '{"stale": true}\n' > "$SANDBOX/cfg/opencode.jsonc"
STALE_AGENTS="$(md5 -r "$SANDBOX/cfg/AGENTS.md" | awk '{print $1}')"
STALE_SKILL="$(md5 -r "$SANDBOX/cfg/skills/debugging/SKILL.md" | awk '{print $1}')"
STALE_CONFIG="$(md5 -r "$SANDBOX/cfg/opencode.jsonc" | awk '{print $1}')"
BEFORE="$(live_manifest)"
run_isolated --apply || fail "T3: --apply failed on outdated destination"
if diff -qr -x '*.bak-*' -x '*.backup' -x '*.pre-gitnexus-*' -x setup-backups "$SANDBOX/good" "$SANDBOX/cfg" >/dev/null 2>&1; then
  pass "T3: outdated destination converged to expected state"
else
  fail "T3: destination did not converge"
fi
FOUND=0
for b in "$SANDBOX"/cfg/AGENTS.md.bak-*; do
  [ -f "$b" ] && [ "$(md5 -r "$b" | awk '{print $1}')" = "$STALE_AGENTS" ] && FOUND=1
done
[ "$FOUND" = "1" ] && pass "T3: AGENTS.md backup byte-matches seeded original" || fail "T3: AGENTS.md backup mismatch"
FOUND=0
for b in "$SANDBOX"/cfg/setup-backups/skills/debugging.bak-*; do
  [ -d "$b" ] && [ "$(md5 -r "$b/SKILL.md" | awk '{print $1}')" = "$STALE_SKILL" ] && FOUND=1
done
[ "$FOUND" = "1" ] && pass "T3: skill backup byte-matches seeded original" || fail "T3: skill backup mismatch"
[ -z "$(find "$SANDBOX/cfg/skills" -maxdepth 1 -name '*.bak-*')" ] && pass "T3: no skill backups inside skills/" || fail "T3: skill backup left inside skills/"
FOUND=0
for b in "$SANDBOX"/cfg/opencode.jsonc.bak-* "$SANDBOX"/cfg/opencode.jsonc.bak-*-*; do
  [ -f "$b" ] && [ "$(md5 -r "$b" | awk '{print $1}')" = "$STALE_CONFIG" ] && FOUND=1
done
[ "$FOUND" = "1" ] && pass "T3: config backup byte-matches seeded original" || fail "T3: config backup mismatch"
assert_live_untouched "T3" "$BEFORE"

# --- T4: operator backups preserved in place; other extras swept on deploy ---
# Designed mirror semantics: backup-pattern files never deploy and stay in
# place (plan annotates them); any other extra makes the payload differ, so
# a successful apply replaces the directory with the backup retaining it.
BEFORE="$(live_manifest)"
printf 'old backup\n' > "$SANDBOX/cfg/skills/backend-engineering/SKILL.md.pre-gitnexus-9"
printf 'skill backup\n' > "$SANDBOX/cfg/skills/backend-engineering/extra.backup"
printf 'operator notes\n' > "$SANDBOX/cfg/skills/architecture/notes.txt"
printf 'old backup\n' > "$SANDBOX/cfg/skills/architecture/SKILL.md.pre-gitnexus-9"
run_isolated --apply || fail "T4: --apply failed with extras present"
for f in SKILL.md.pre-gitnexus-9 extra.backup; do
  [ -f "$SANDBOX/cfg/skills/backend-engineering/$f" ] && pass "T4: preserved backend $f in place" || fail "T4: lost backend $f"
done
grep -q "skill backend-engineering: up-to-date (live-only extras preserved" "$SANDBOX/last-out.txt" && pass "T4: plan annotates preserved extras" || fail "T4: plan silent about preserved extras"
SWEPT=0
for b in "$SANDBOX"/cfg/setup-backups/skills/architecture.bak-*; do
  [ -f "$b/notes.txt" ] && [ "$(cat "$b/notes.txt")" = "operator notes" ] && SWEPT=1
done
[ "$SWEPT" = "1" ] && pass "T4: non-backup extra swept into timestamped backup" || fail "T4: swept extra not found in backup"
[ ! -e "$SANDBOX/cfg/skills/architecture/notes.txt" ] && pass "T4: swept extra removed from live dir" || fail "T4: swept extra still in live dir"
assert_live_untouched "T4" "$BEFORE"

# --- T5: repeated changed deployments accumulate distinct backups ---
printf 'STALE-ROUND-1\n' > "$SANDBOX/cfg/AGENTS.md"
R1="$(md5 -r "$SANDBOX/cfg/AGENTS.md" | awk '{print $1}')"
run_isolated --apply || fail "T5: round 1 failed"
printf 'STALE-ROUND-2\n' > "$SANDBOX/cfg/AGENTS.md"
run_isolated --apply || fail "T5: round 2 failed"
NAMES="$(find "$SANDBOX/cfg" -maxdepth 1 -name 'AGENTS.md.bak-*' | sort)"
COUNT="$(printf '%s\n' "$NAMES" | grep -c . || true)"
UNIQ="$(printf '%s\n' "$NAMES" | sort -u | grep -c . || true)"
if [ "$COUNT" -ge 2 ] && [ "$COUNT" -eq "$UNIQ" ]; then
  pass "T5: distinct backup names across rapid re-runs (B2)"
else
  fail "T5: backup collision (names: $NAMES)"
fi
cmp -s "$REPO_DIR/instructions/AGENTS.md" "$SANDBOX/cfg/AGENTS.md" && pass "T5: final state converged" || fail "T5: final state diverged"
if [ "$R1" = "$(md5 -r "$SANDBOX/cfg/AGENTS.md" 2>/dev/null | awk '{print $1}')" ]; then
  fail "T5: stale content survived"
else
  pass "T5: stale content replaced"
fi
BEFORE_T5_END="$(live_manifest)"
assert_live_untouched "T5" "$SUITE_BEFORE"

# --- T6: validation failures abort before any write ---
FIXREPO="$SANDBOX/fixrepo"
mkdir -p "$FIXREPO/scripts" "$FIXREPO/config" "$FIXREPO/instructions" "$FIXREPO/skills/debugging"
cp "$INSTALLER" "$FIXREPO/scripts/install.sh"
cp "$REPO_DIR/instructions/AGENTS.md" "$FIXREPO/instructions/AGENTS.md"
cp -R "$REPO_DIR"/skills/* "$FIXREPO/skills/"
cp "$REPO_DIR/config/opencode.jsonc" "$FIXREPO/config/opencode.jsonc"
# T6a: corrupted template (unresolvable placeholder).
sed 's/@@NODE@@/@@BROKEN@@/' "$FIXREPO/config/opencode.jsonc" > "$FIXREPO/config/opencode.jsonc.bad" && mv "$FIXREPO/config/opencode.jsonc.bad" "$FIXREPO/config/opencode.jsonc"
export OPENCODE_SETUP_DEST="$SANDBOX/cfg6a"
if bash "$FIXREPO/scripts/install.sh" --check >"$SANDBOX/last-out.txt" 2>&1; then
  fail "T6a: corrupted template passed validation"
else
  grep -qi "placeholder\|refus" "$SANDBOX/last-out.txt" && pass "T6a: corrupted template rejected" || fail "T6a: unclear rejection"
fi
[ -e "$SANDBOX/cfg6a/AGENTS.md" ] || [ -e "$SANDBOX/cfg6a/opencode.jsonc" ] && fail "T6a: writes despite failure" || pass "T6a: no writes on validation failure"
# T6b: missing SKILL.md in fixture repo.
cp "$REPO_DIR/config/opencode.jsonc" "$FIXREPO/config/opencode.jsonc"
rm "$FIXREPO/skills/debugging/SKILL.md"
export OPENCODE_SETUP_DEST="$SANDBOX/cfg6b"
if bash "$FIXREPO/scripts/install.sh" --check >"$SANDBOX/last-out.txt" 2>&1; then
  fail "T6b: missing SKILL.md passed validation"
else
  grep -qi "SKILL.md" "$SANDBOX/last-out.txt" && pass "T6b: missing SKILL.md rejected" || fail "T6b: unclear rejection"
fi
# T6c: no suitable Node via fixture HOME (empty nvm) + wrong-version fixture node.
mkdir -p "$FIXREPO/fakehome" "$FIXREPO/bin"
printf '#!/bin/sh\necho v0.0.0-test\n' > "$FIXREPO/bin/node" && chmod +x "$FIXREPO/bin/node"
OPCODE_DIR="$(dirname "$(command -v opencode)")"
cp -R "$REPO_DIR"/skills/debugging/SKILL.md "$FIXREPO/skills/debugging/SKILL.md" 2>/dev/null || cp "$REPO_DIR/skills/testing/SKILL.md" "$FIXREPO/skills/debugging/SKILL.md"
export OPENCODE_SETUP_DEST="$SANDBOX/cfg6c"
if HOME="$FIXREPO/fakehome" PATH="$FIXREPO/bin:$OPCODE_DIR:/usr/bin:/bin" bash "$FIXREPO/scripts/install.sh" --check >"$SANDBOX/last-out.txt" 2>&1; then
  fail "T6c: wrong-version node passed validation"
else
  grep -qi "No suitable Node" "$SANDBOX/last-out.txt" && pass "T6c: wrong-version node rejected" || fail "T6c: unclear rejection"
fi
assert_live_untouched "T6" "$SUITE_BEFORE"

# --- T7: deterministic partial-state failure and recovery (no chmod) ---
set_dest "cfg"
BEFORE="$(live_manifest)"
# T7a: regular file where a skill directory is expected aborts deterministically.
rm -rf "$SANDBOX/cfg/skills/performance" && printf 'BLOCKER\n' > "$SANDBOX/cfg/skills/performance"
if run_isolated --apply; then
  fail "T7a: type conflict did not abort"
else
  pass "T7a: type conflict aborted with non-zero exit"
fi
[ -f "$SANDBOX/cfg/skills/performance" ] && pass "T7a: blocker preserved, no stray replacement" || fail "T7a: blocker state changed unexpectedly"
cmp -s "$SANDBOX/good/opencode.jsonc" "$SANDBOX/cfg/opencode.jsonc" && pass "T7a: later stages untouched after abort" || fail "T7a: config changed despite abort"
rm "$SANDBOX/cfg/skills/performance"
run_isolated --apply || fail "T7a: recovery apply failed"
diff -qr --exclude='*.bak-*' --exclude='*.backup' --exclude='*.pre-gitnexus-*' --exclude='notes.txt' "$REPO_DIR/skills/performance" "$SANDBOX/cfg/skills/performance" >/dev/null 2>&1 && pass "T7a: recovery converged" || fail "T7a: recovery diverged"
# T7b: simulated post-crash partial state converges on re-run.
rm -rf "$SANDBOX/cfg/skills/testing"
printf '{}\n' > "$SANDBOX/cfg/opencode.jsonc"
run_isolated --apply || fail "T7b: convergence apply failed"
[ -f "$SANDBOX/cfg/skills/testing/SKILL.md" ] && pass "T7b: missing skill restored" || fail "T7b: skill not restored"
if ! run_isolated --check; then
  fail "T7b: post-recovery check failed"
elif grep -q "will-write" "$SANDBOX/last-out.txt"; then
  fail "T7b: not converged"
else
  pass "T7b: partial state converged"
fi
assert_live_untouched "T7" "$BEFORE"

assert_live_untouched "SUITE" "$SUITE_BEFORE"
echo "=== MATRIX RESULT: $PASS passed, $FAIL failed ==="
[ "$FAIL" = "0" ]
