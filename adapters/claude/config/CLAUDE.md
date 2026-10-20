# Global Claude Code Instructions

Engineering instructions are shared with OpenCode and maintained in
`@@REPO_DIR@@/core/instructions/AGENTS.md` (imported below).
Where they say "OpenCode" read "Claude Code"; where they say "the project's
`AGENTS.md`" read "the project's `CLAUDE.md` or `AGENTS.md`".

@@@REPO_DIR@@/core/instructions/AGENTS.md

## Claude Code specifics

- Claude Code is the lead agent. Use plan mode for substantial or ambiguous
  work; implement in the default mode.
- Delegating to OpenCode free models is your decision. Consider the
  `opencode-delegate` skill for well-specified, low-risk implementation or a
  second-opinion validation, and always review the result yourself.
- Use the `Explore` subagent for broad searches and `test-runner` for running
  test suites, so raw output stays out of the main context.

## Compact instructions

When compacting, preserve: the current goal and plan, files changed and why,
decisions made with the user, failing tests and their errors, GitNexus
findings that drove a change, and open questions. Drop raw tool output, file
dumps, and resolved dead ends.
