---
name: opencode-delegate
description: Delegate a small, fully specified coding task to an OpenCode free model to save Claude tokens, then review the result. Use at your own discretion for mechanical implementation with a clear spec (boilerplate, a single function or test file from an exact contract, repetitive edits across known files, docstrings, simple refactors) or for a second-opinion review of a diff. Do not use for architecture, security-sensitive code, thesis methodology decisions, ambiguous requirements, or anything touching secrets, production, or git history.
argument-hint: "[implement|review] <task>"
---

# OpenCode Delegation

Claude Code is the lead. OpenCode free models are cheap, untrusted workers.
Claude decides what to delegate, writes the prompt, and owns the result.

## Decide

Delegate only when all hold:

- The task is fully specified: exact files, function signatures or contracts,
  expected behavior, and how to verify it.
- Writing the prompt and reviewing the diff costs clearly less than doing it
  yourself. Typical win: output much larger than the spec (boilerplate, tests
  from a contract, repetitive edits). One-line fixes are cheaper to do directly.
- A wrong result is cheap to detect: tests, a type check, or a small diff.
- No secrets, credentials, `.env` contents, or private data go into the prompt.
  Free models may retain prompts.

Never delegate: design or architecture choices, auth/security code, money or
data-integrity logic, research methodology (DWT/PRNU, dataset splits,
evaluation), migrations, or anything the user asked you to do personally.

## Prompt

Keep it small and self-contained. The worker sees the repository but not this
conversation. Use this shape:

```
Task: <one sentence>
Files: <exact paths to change; do not touch others>
Contract: <signatures, inputs/outputs, invariants>
Conventions: <only those that matter, e.g. "use existing helper X in Y">
Done when: <exact verification command and expected result>
Do not: commit, push, add dependencies, or edit files outside Files.
Reply with: DONE or BLOCKED: <reason>, then a 3-line summary.
```

## Run

```bash
${CLAUDE_SKILL_DIR}/scripts/oc-run.sh --mode implement -- "<prompt>"
${CLAUDE_SKILL_DIR}/scripts/oc-run.sh --mode review -f <diff-or-file> -- "<review prompt>"
```

Options: `-m provider/model` (default `$OC_DELEGATE_MODEL` or
`opencode/deepseek-v4.1-flash-free`), `-t seconds` (default 600),
`--models` lists free models. Pick only zero-retention, no-training models
(per OpenCode Zen docs: `deepseek-v4.1-flash-free`, `glm-5.3-flash-free`,
`minimax-m3.1-flash-free`, `longcat-2.5-preview-free`); others such as
`big-pickle`, MiMo, and Nemotron may log prompts or use them for training.
Free models are free only for a limited time, so recheck if one disappears. Implement mode requires a git work tree.
Commits and pushes are blocked for the run.

If status is not `ok`, read the reported error. On a provider or auth error,
stop delegating for this session and tell the user (for example,
`opencode auth login` is needed). Retry at most once with another free model.

## Review (mandatory)

1. Read the diff of every file listed under `changed:` (`git diff -- <path>`;
   new files with Read). Ignore the worker's claims; trust only the diff.
2. Reject any change outside the specified files, new dependencies, deleted
   tests, weakened assertions, or swallowed errors.
3. Run the verification from `Done when` yourself.
4. Then either accept, fix the remaining issues yourself, or restore exactly
   what the run changed with `oc-run.sh --undo <run-id>` (it restores
   pre-run content, including your own uncommitted edits, and removes files
   the run created).
5. Tell the user in one line that the work was delegated, to which model, and
   what you changed afterwards.

For review mode, treat the worker's findings as leads: verify each against the
code before reporting it.
