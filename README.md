# OpenCode Setup

Portable, version-controlled AI engineering platform containing
agent-independent engineering instructions and skills, plus an OpenCode
runtime adapter with configuration and setup scripts.

The repository acts as the source of truth for my development environment
across machines. Pinned for this phase: OpenCode 1.19.0, GitNexus 1.6.12,
Node v22.23.2. OpenCode 2.0 migration is deferred to a separate phase.

## Layout

- `core/instructions/AGENTS.md` — agent-independent engineering and
  orchestration instructions.
- `core/skills/` — reusable agent-independent engineering skills.
- `adapters/opencode/config/opencode.jsonc` — portable OpenCode
  configuration template (GitNexus MCP). Contains installer-owned
  `@@PLACEHOLDER@@` entries, never absolute paths; the installer renders
  them into the live configuration.
- `adapters/opencode/scripts/` — installation and setup scripts
  (`install.sh` for macOS/Linux, `install.ps1` for Windows).
- `adapters/claude/` — Claude Code adapter (see below). Claude Code is the
  lead agent; OpenCode free models are optional delegated workers.

`evidence/` (Bronze/Silver/Gold refinement) and token/context budgets are
separate concerns with reserved paths; neither lives inside the other.

## Global Skills

- architecture
- backend-engineering
- code-review
- debugging
- documentation
- frontend-engineering
- git-workflow
- machine-learning
- performance
- security
- testing

Impeccable is an optional existing dependency installed separately from its
upstream repository. It is not vendored here, and the installers do not
install it.

## External Dependencies

The setup currently uses:

- OpenCode 1.19.0
- Node.js v22.23.2 and npm
- GitNexus 1.6.12 (sole graph provider)

GitNexus is used conditionally as the repository-intelligence provider where
a repository index exists. Indexing always requires explicit approval; the
installers never install GitNexus and never index projects. The default
`node` on PATH is never assumed suitable: deployment resolves and verifies
the pinned Node/GitNexus pair and fails closed otherwise.

## Installation

### macOS / Linux

From the repository root, inspect the plan first (default; changes nothing):

```bash
./adapters/opencode/scripts/install.sh --check
./adapters/opencode/scripts/install.sh --dry-run
```

Deploy only with explicit approval:

```bash
./adapters/opencode/scripts/install.sh --apply
```

### Windows

From the repository root in PowerShell:

```powershell
.\adapters\opencode\scripts\install.ps1 --check
.\adapters\opencode\scripts\install.ps1 --dry-run
```

> Note: `install.ps1` has not been runtime-tested on this Mac (no
> PowerShell available there). The first Windows execution must be
> `--check`, followed by `--dry-run`, with output reviewed before any
> `--apply`. Requires Windows PowerShell 5.1 or PowerShell 7+.

```powershell
.\adapters\opencode\scripts\install.ps1 --apply
```

The installer runs as the current user and does not require administrator
elevation. It deploys the OpenCode configuration under the user's config
directory (`~/.config/opencode` on macOS/Linux,
`%USERPROFILE%\.config\opencode` on Windows).

`--apply` writes live configuration with timestamped backups
(`*.bak-YYYYmmdd-HHMMSS`, collision-suffixed on re-runs), one file at a
time (ordered replacement, not atomic across files). A working live
configuration is never overwritten without explicit deployment approval.
Validate with `--check` after any deployment.

## Testing (isolated)

`adapters/opencode/scripts/test-isolated.sh` runs the macOS installer
matrix against a disposable sandbox. It exports `OPENCODE_SETUP_DEST` for
every installer call and refuses to run otherwise.

Destination override rules (enforced by both installers before any write):

- Unset means production: the default destination is unchanged.
- Empty, relative, filesystem-root, live-equivalent, symlink-aliased, and
  live-ancestor/live-contained destinations are refused with a clear error.
- Paths are canonicalized (symlinks resolved) before containment checks.
- An active override prints a `SANDBOX MODE` banner with the effective root.

Test matrix: interlock refusals (T0), default dry-run (T-dry), empty
destination (T1), up-to-date convergence (T2), outdated replacement with
byte-verified backups (T3), unrelated-file and operator-backup preservation
(T4), repeated deployments with distinct backup names (T5), pre-write
validation failures (T6), and deterministic partial-state failure plus
recovery (T7). Every test snapshots the live tree before and after and
fails on any delta, and every plan output is checked so all target paths
stay inside the sandbox. Fixtures are synthesized; no live configuration
or secret is ever copied into them.

```bash
./adapters/opencode/scripts/test-isolated.sh
```

Platform coverage: the full matrix is verified on macOS for `install.sh`.
`install.ps1` mirrors the contract by construction and review only — it has
never been runtime-tested (see the Windows note above). Windows layout
discovery (B3), UTF-8-no-BOM bytes, and activation semantics remain
unverified until a Windows `--check` → `--dry-run` output review.

## Claude Code Adapter

Claude Code reads the same `core/` content as OpenCode, so instructions and
skills exist once.

- `config/CLAUDE.md` — global `~/.claude/CLAUDE.md`; @imports
  `core/instructions/AGENTS.md` and adds Claude-specific orchestration.
- `config/settings.json` — permission allow/deny baseline (secrets, build
  output, destructive git). Seeded only when missing, because Claude Code
  edits it at runtime; afterwards the installer reports drift.
- `agents/` — `Explore` and `test-runner` subagents on Haiku, so searches
  and test output stay out of the main context.
- `rules/` — path-scoped rules that point backend, frontend, and ML files
  to the right skills.
- `skills/opencode-delegate/` — lets Claude hand small, fully specified tasks
  to an OpenCode free model through `scripts/oc-run.sh` (commits and pushes
  blocked, every run undoable), then review the diff itself. Use only
  zero-retention free models; see the skill for the list.

Skills, agents, and rules are symlinked into `~/.claude`, so edits in this
repository take effect immediately. Memory, sessions, plugins, Impeccable,
and project-local skills (such as a thesis repo's `thesis-research`) stay
machine-local and are not managed here.

```bash
./adapters/claude/scripts/install.sh            # dry run (default)
./adapters/claude/scripts/install.sh --check    # exit 1 on drift
./adapters/claude/scripts/install.sh --apply    # back up, then link/write
```

Replaced entries are moved to `<name>.bak-YYYYmmdd-HHMMSS`. Set
`CLAUDE_SETUP_DEST=/abs/sandbox` to test without touching `~/.claude`.
