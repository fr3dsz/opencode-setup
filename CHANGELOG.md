# Changelog

## v2.0.0 — 2026-10-26

### Added

- `clarify`, `project-structure`, and `browser-testing` skills.
- Chrome DevTools MCP server (pinned 1.12.0, isolated profile, no telemetry, reduced tool set).
- Permission guardrails for free models: `.env` access denied, ask before push, commit, deletes, and installs; destructive git denied; step limits.
- `lint-skills.sh` enforcing frontmatter and a 120-line skill budget.
- OpenCode 2.x version check in both installers.

### Changed

- Repository is OpenCode-only; layout flattened to `instructions/`, `skills/`, `config/`, `scripts/`.
- Config template migrated to the OpenCode 2.x schema (`mcp.servers`, ordered `permissions`, `agents`).
- `AGENTS.md` and every skill rewritten as short, imperative checklists for free models.
- `security` centers on a data-flow table and always/ask/never rules; `git-workflow` follows the main/development/feature model with Conventional Commits and semver tags.
- Skill backups moved to `setup-backups/skills/` so they are never discovered as duplicate skills.
- Windows installer renders paths with forward slashes so they stay valid JSON.

### Removed

- Claude Code adapter and the `opencode-delegate` skill (moved to a separate private repository, delegation dropped).
- Shared `core/` directory.
