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
(`*.bak-YYYYmmdd-HHMMSS`), one file at a time (ordered replacement, not
atomic across files). A working live configuration is never overwritten
without explicit deployment approval. Validate with `--check` after any
deployment.
