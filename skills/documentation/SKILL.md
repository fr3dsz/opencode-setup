---
name: documentation
description: Use when writing or updating README files, docs folders, architecture notes, data-flow or security docs, API docs, changelogs, or decision records, and when code changes make existing docs wrong.
---

# Documentation

Docs describe what the system actually does. Check the code before writing.

## Standard files

| File | Contains |
|---|---|
| `README.md` | What it is, how to install, run, and test |
| `CHANGELOG.md` | Changes per version: Added, Changed, Fixed, Removed |
| `docs/architecture.md` | Main parts, what each does, how data moves between them |
| `docs/security.md` | Who can access what, data types, data flows, protections |
| `docs/decisions.md` | Short records: context, decision, consequence |

Small projects may only need `README.md`. Do not create files nobody needs.

## When to update docs

Update docs in the same change when you alter:

- how to install, configure, run, or test
- an API endpoint, request, or response
- a data flow, permission rule, or stored data
- module responsibilities or folder layout

Do not rewrite docs that the change does not affect.

## Writing style

- Short sections, plain words, concrete examples.
- Commands in code blocks that can be copied and run.
- Tables for lists of options, endpoints, or fields.
- No marketing language. No guessing: if you are unsure, check the code or ask.
- Never put secrets, real passwords, or real customer data in docs.

## If docs and code disagree

Do not silently pick one. Tell the user which file says what, and ask which is correct.
