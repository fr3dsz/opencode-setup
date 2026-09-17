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
