# OpenCode Setup

Portable OpenCode configuration used as the **emergency backup** when Claude Code is unavailable. It is tuned for free models: short imperative instructions, checklist-style skills, explicit "stop and ask" points, and permission guardrails in config.

Claude Code is configured separately in a private `claude-setup` repository. The two share nothing.

Pinned: OpenCode 2.x (tested on 2.0.30), Node v22.23.2, GitNexus 1.6.12, chrome-devtools-mcp 1.12.0.

## Quick Start

1. Install OpenCode 2.x, Git, and Node v22.23.2 (via nvm).
2. Install the MCP servers into the pinned Node tree (the installer never installs packages):

   ```bash
   N=~/.nvm/versions/node/v22.23.2/bin
   PATH=$N:$PATH $N/npm install -g --ignore-scripts gitnexus@1.6.12 chrome-devtools-mcp@1.12.0
   ```

3. Clone and deploy:

   ```bash
   git clone https://github.com/fr3dsz/opencode-setup.git ~/Dev/opencode-setup
   cd ~/Dev/opencode-setup
   ./scripts/install.sh --check     # validate inputs, change nothing
   ./scripts/install.sh             # dry run: print the plan
   ./scripts/install.sh --apply     # deploy with backups
   ```

   Windows (PowerShell): `.\scripts\install.ps1 --check`, then `--dry-run`, then `--apply`. It is not runtime-tested; review the output first.

4. Sign in and pick a model: `opencode auth login`, then `opencode models` to see what is available.

## Choosing a Free Model

- Prefer free models whose provider does not retain or train on your data. As of 2026-10-20, OpenCode Zen listed only its DeepSeek, GLM, MiniMax, and LongCat free models as zero-retention. Re-check the Zen docs before relying on this; the list changes.
- Never paste secrets or customer data into a session with a model whose retention you have not checked.
- If a model struggles, keep tasks small: one feature or fix per session, and start with the `clarify` skill.

## What Gets Deployed

| Source | Live location |
|---|---|
| `instructions/AGENTS.md` | `~/.config/opencode/AGENTS.md` |
| `skills/<name>/` | `~/.config/opencode/skills/<name>/` (copied) |
| `config/opencode.jsonc` | `~/.config/opencode/opencode.jsonc` (rendered) |

The config template contains `@@NODE@@`, `@@GITNEXUS_CLI@@`, and `@@DEVTOOLS_CLI@@` placeholders. The installer resolves them in the pinned Node tree, verifies exact versions, and refuses to deploy if any placeholder remains.

## Guardrails in Config

`config/opencode.jsonc` adds ordered permission rules on top of OpenCode's defaults:

- `.env` and `.env.*` files: read and edit denied (`.env.example` allowed).
- Ask before: `git push`, `git commit`, `git rebase`, `git branch -D`, `rm -r`, `rm -rf`, dependency installs, `curl`, `wget`.
- Denied: force-push, `reset --hard`, `git clean`, `git checkout --`, `sudo`.
- Step limits: 100 for `build`, 50 for `plan`, so a struggling model cannot loop forever.

Shell rules match the command text with wildcards, so they are guardrails, not a sandbox. Unusual phrasings of a command may not match.

## MCP Servers

- **GitNexus**: repository graph for callers and impact. Indexing always needs your approval.
- **Chrome DevTools** (`chrome-devtools-mcp`): `--isolated` temporary profile, no usage statistics, network auth headers redacted, memory and emulation tools disabled to keep the tool list small (29 tools).

Both launch through the pinned Node with absolute paths, so they work even when `node` is not on PATH.

## Skills

| Skill | Use |
|---|---|
| clarify | Unclear request or new feature: ask, confirm, plan |
| project-structure | Where files go, naming, comments, cleanup |
| security | Data-flow table, always/ask/never rules, verification |
| git-workflow | Branches, commits, PRs, versions |
| backend-engineering, frontend-engineering | Implementation rules |
| browser-testing | Chrome DevTools checks |
| testing, debugging, code-review | Verification workflows |
| documentation, architecture, performance, machine-learning | Specialized work |

Each skill stays under 120 lines: `./scripts/lint-skills.sh` enforces this along with valid frontmatter.

## Installer Behavior

- `--dry-run` (default) and `--check` never write. `--apply` validates everything first, then replaces one file at a time.
- `AGENTS.md` and `opencode.jsonc` backups are written next to the file as `<name>.bak-YYYYmmdd-HHMMSS`. Skill backups go to `setup-backups/skills/`, outside `skills/`, so OpenCode never loads a backup as a duplicate skill.
- `OPENCODE_SETUP_DEST=/abs/sandbox` redirects every write. Live-equivalent, ancestor, contained, relative, and root destinations are refused.

## Tests

```bash
./scripts/lint-skills.sh
./scripts/test-isolated.sh
```

`test-isolated.sh` runs the installer matrix against a disposable sandbox and fails if the live configuration changes. It covers refusals, dry run, fresh deploy, convergence, byte-verified backups, extras, repeated deploys, validation failures, and partial-state recovery. It is verified on macOS only; `install.ps1` mirrors it by review.

## Git

This repo follows its own `git-workflow` skill: `feature/*` from `development`, PR into `development`, release `development` → `main` with a semver tag and a CHANGELOG entry.

Adapted content is credited in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
