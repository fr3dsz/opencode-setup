---
name: architecture
description: Use when designing a new system or module, deciding how to split responsibilities between modules, choosing a technology or pattern, planning a large change across many files, or restructuring a codebase. Not needed for small changes that fit the existing design.
---

# Architecture

Big design changes are expensive to undo. Always propose and get approval before building.

## Step 1: Understand

- [ ] What problem are we solving, for whom?
- [ ] What must stay true (constraints: deadline, budget, hosting, existing data)?
- [ ] How does the current system work? Read `docs/architecture.md` and the main modules.
- [ ] If the repo has GitNexus, check who depends on the code you want to change.

## Step 2: Design

Describe, in a short list:

1. **Modules:** each one's single responsibility.
2. **Boundaries:** which module owns which data. Only the owner writes it.
3. **Dependencies:** which module calls which. Avoid cycles. Shared code depends on nothing feature-specific.
4. **Data flow:** where data enters, how it moves, where it is stored, where it leaves.
5. **Failure:** what happens when a part or an external service is down.
6. **Security:** where login and permission checks happen (load `security`).

## Step 3: Compare

Give at most two options in a table: approach, pros, cons, effort. Recommend one and say why.

## Step 4: Get approval

Show the design and recommendation. Wait for a yes before editing code.

## Rules

- Prefer the simplest design that solves today's problem.
- Reuse existing patterns in the project. Do not introduce a second way of doing the same thing.
- No new framework, service, or database without approval.
- Move code in small steps that keep the build passing.
- Update `docs/architecture.md` and `docs/decisions.md` when the design changes.
