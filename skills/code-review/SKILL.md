---
name: code-review
description: Use when reviewing a diff, pull request, branch, or recently written code — including your own before finishing. Checks correctness, security, structure, naming, comments, tests, and unintended changes, and reports findings with file and line.
---

# Code Review

## Get the change

```bash
git diff                         # uncommitted
git diff development...HEAD      # branch vs development
```

Read every changed file fully around the change, not only the diff lines.

## Check in this order

1. **Correctness**
   - [ ] Does it do what was asked? All cases, including empty, null, and error?
   - [ ] Could it break existing callers or saved data?
2. **Security** (load `security` skill if login, permissions, data, or input are involved)
   - [ ] Input validated on the server.
   - [ ] Permission checked for the specific record.
   - [ ] No secrets, no sensitive data in responses or logs.
3. **Structure** (see `project-structure`)
   - [ ] Files in the right folders, names follow the project scheme.
   - [ ] No business logic in controllers or templates.
   - [ ] No duplicated logic; existing helpers reused.
4. **Readability**
   - [ ] Clear names.
   - [ ] Functions short and focused.
   - [ ] Comments short and explain why; no comments that repeat code; no commented-out code.
5. **Tests**
   - [ ] New behavior is tested; bug fixes have a regression test.
   - [ ] Tests would fail if the code were wrong.
6. **Leftovers**
   - [ ] No debug prints, unused imports, unrelated changes, or generated files.

## Report format

```
[HIGH] path/to/File.java:42 — Order lookup does not filter by organization.
Fix: use findByIdAndOrganizationId(id, orgId).
```

Severity:

- **HIGH:** bug, security hole, or data loss. Must fix.
- **MEDIUM:** likely problem or missing test. Should fix.
- **LOW:** style or small improvement. Optional.

Only report real problems you can point to. Say plainly if you found nothing serious, and list what you checked.
