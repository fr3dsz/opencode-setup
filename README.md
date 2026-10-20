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

On macOS/Linux, skills, agents, and rules are symlinked into `~/.claude`, so
edits in this repository take effect immediately. On Windows, skills are
directory junctions (no admin rights needed) and agents/rules are copied,
because file symlinks need elevation; re-run `--apply` after `git pull`.
Memory, sessions, plugins, MCP servers (`~/.claude.json`), Impeccable, and
project-local skills (such as a thesis repo's `thesis-research`) stay
machine-local and are not managed here.

```bash
./adapters/claude/scripts/install.sh            # dry run (default)
./adapters/claude/scripts/install.sh --check    # exit 1 on drift
./adapters/claude/scripts/install.sh --apply    # back up, then link/write
```

```powershell
.\adapters\claude\scripts\install.ps1 --check
.\adapters\claude\scripts\install.ps1 --dry-run
.\adapters\claude\scripts\install.ps1 --apply
```

Replaced entries are moved to
`~/.claude/setup-backups/YYYYmmdd-HHMMSS/<relative path>`, outside the
directories Claude Code loads. Set `CLAUDE_SETUP_DEST` to an absolute
sandbox path to test without touching `~/.claude`.

`install.ps1` has not been runtime-tested (no PowerShell on the
maintainer's Mac). Run `--check` and `--dry-run` first on Windows and review
the output before `--apply`. `oc-run.sh` runs under Git Bash on Windows; its
timeout watchdog (`pkill`/`kill`) is unverified there.

## New Machine Setup

Same steps on macOS and Windows; Windows commands are in PowerShell.

1. Install prerequisites: Git (on Windows, Git for Windows, which Claude
   Code needs for Git Bash), Claude Code, and optionally Node v22.23.2 +
   GitNexus 1.6.12 and OpenCode 1.19.0.
2. Clone to the same relative place:
   `git clone https://github.com/fr3dsz/opencode-setup.git ~/Dev/opencode-setup`
   (Windows: `$HOME\Dev\opencode-setup`).
3. Claude Code: run the adapter installer `--check`, then `--dry-run`, then
   `--apply` (see above).
4. GitNexus MCP for Claude Code (user scope, lives in `~/.claude.json`, so
   it is registered per machine rather than deployed):

   ```bash
   # macOS / Linux: absolute paths to the pinned Node and GitNexus CLI
   claude mcp add gitnexus -s user -- \
     ~/.nvm/versions/node/v22.23.2/bin/node \
     ~/.nvm/versions/node/v22.23.2/lib/node_modules/gitnexus/dist/cli/index.js mcp
   ```

   ```powershell
   # Windows: after `npm install -g gitnexus@1.6.12`
   claude mcp add gitnexus -s user -- cmd /c gitnexus mcp
   ```

   Verify with `claude mcp list`.
5. OpenCode (optional, needed for `opencode-delegate`): run the OpenCode
   installer (see Installation), then `opencode auth login`.
6. Optional: install Impeccable from its upstream repository into
   `~/.claude/skills/impeccable`.
