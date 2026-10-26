---
name: git-workflow
description: Use for any git task — checking status, creating branches, writing commit messages, committing, pushing, pull requests, merging, conflicts, version numbers, tags, and releases. Follows the main/development/feature branch model, Conventional Commit types, and semantic version tags.
---

# Git Workflow

## Before anything

```bash
git status
git branch --show-current
git log --oneline -5
```

- If there are uncommitted changes you did not make, leave them alone.
- Never work directly on `main`, `staging`, or `production`.

## Branches

| Branch | Purpose |
|---|---|
| `main` | Stable, released code |
| `development` | Features are merged here first |
| `staging` | Testing before release (only if the project is deployed) |
| `production` | What is live (only if there is a live deployment) |

Order: `feature/*` → `development` → `staging` → `main` → `production`. Skip the ones that do not exist.

New work branch, always from `development`:

```bash
git checkout development
git pull
git checkout -b feature/42-order-filters
```

Prefixes: `feature/`, `bugfix/`, `hotfix/` (from `main`), `refactor/`, `docs/`, `chore/`. Use the issue number if there is one.

## Commit messages

```
type(scope): short summary in imperative mood
```

| Type | Use for |
|---|---|
| feat | new feature |
| fix | bug fix |
| refactor | code change, same behavior |
| perf | faster |
| test | tests only |
| docs | documentation only |
| style | formatting only |
| build | build or dependencies |
| ci | CI config |
| chore | other maintenance |
| revert | undo a commit |

Examples: `feat(orders): filter by status (#42)`, `fix(auth): reject expired tokens`.

## Before committing

1. Commit only if the user asked.
2. `git diff` and read it.
3. Check: no secrets, no debug prints, no unrelated files, no generated files.
4. Stage specific files: `git add <file>` (not `git add .` unless every change is yours).
5. One logical change per commit.
6. No AI attribution lines.

## Pull requests

- Work branch → `development`. `development` → `main` for releases.
- Title in commit format. Body: what, why, how it was tested.
- Push or open a PR only if the user asked.

## Versions

Tag `main` after a release: `vMAJOR.MINOR.PATCH`.

- Major: new module, big refactor, or breaking change.
- Minor: new feature or workflow or build change.
- Patch: bug fix or small adjustment.

```bash
npm version minor -m "chore(release): %s"   # Node projects
git tag -a v1.4.0 -m "v1.4.0"              # other projects
```

Add an entry to `CHANGELOG.md` (Added / Changed / Fixed / Removed).

## Never

- `git push --force`, `git reset --hard`, `git clean`, `git checkout -- .`
- Deleting branches or tags
- Rewriting history that was already pushed

## Conflicts

Read both sides, keep what each side intended, run the tests, then show the user the result.
