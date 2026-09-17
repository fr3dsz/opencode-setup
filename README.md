# OpenCode Setup

Portable, version-controlled OpenCode development environment containing my
global engineering instructions, reusable skills, OpenCode configuration, and
setup scripts.

The repository acts as the source of truth for my OpenCode configuration across
development machines.

## Included

- `AGENTS.md` — global engineering and orchestration instructions.
- `skills/` — reusable global engineering skills.
- `config/opencode.jsonc` — portable OpenCode configuration, including CodeGraph MCP.
- `scripts/` — installation and setup scripts.

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

Impeccable is installed separately from its upstream repository and is not
vendored into this repository.

## External Dependencies

The setup currently uses:

- OpenCode
- Node.js and npm
- CodeGraph (`@colbymchenry/codegraph`)
- Impeccable (`pbakaus/impeccable`)

CodeGraph is used as the primary code intelligence and navigation tool for
repositories containing `.codegraph/`.

## Installation

### macOS / Linux

Clone this repository and run:

```bash
./scripts/install.sh
```

### Windows

Clone this repository and run the setup script from PowerShell:

```powershell
.\scripts\install.ps1
```

The installer runs as the current user and does not require administrator
elevation. It installs the OpenCode configuration under:

```text
%USERPROFILE%\.config\opencode
```

If CodeGraph is not already available, the installer attempts to install it
through npm using the current user's environment.
