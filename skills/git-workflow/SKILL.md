---
name: git-workflow
description: Use when inspecting Git state, creating commits, preparing branches, reviewing diffs, resolving merge issues, or performing other repository version-control workflows.
---

# Git Workflow

Treat Git as a safety mechanism and historical record.

## Before Significant Changes

Inspect:

- current branch
- working tree status
- relevant existing modifications
- recent commits when useful

Do not overwrite unrelated user changes.

## Before Editing

If the working tree already contains changes:

- identify whether they are related
- preserve unrelated changes
- do not reset or discard them without explicit permission

## Diff Review

Before committing, inspect the diff.

Check for:

- unintended files
- debugging code
- secrets
- generated files
- unrelated changes
- accidental deletions
- formatting-only noise

## Commits

Only create commits when:

- explicitly requested
- the project's workflow explicitly requires it

Do not automatically commit after completing a task.

## Commit Quality

When creating a commit:

- keep it focused
- describe the actual change
- avoid unrelated modifications
- do not include secrets or temporary files

## Destructive Operations

Do not automatically run destructive Git commands such as:

- git reset --hard
- git clean
- force push
- deleting branches

unless explicitly authorized.

## Merge Conflicts

When resolving conflicts:

1. understand both sides
2. determine intended behavior
3. preserve required changes
4. inspect the resulting diff
5. run relevant verification

Never resolve conflicts by blindly choosing one side.

## Final State

After Git operations, report:

- branch
- relevant changed files
- commit status if applicable
- remaining uncommitted changes
- unresolved conflicts if any