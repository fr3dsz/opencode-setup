---
name: clarify
description: Use before building when a request is unclear, could mean more than one thing, or is a new feature or change that needs a plan. Ask the right questions with a recommended answer, confirm what done looks like and what is out of scope, then write a short step-by-step plan.
---

# Clarify, Then Plan

## Step 1: Write your understanding

One sentence: what the user wants, for whom, and what done looks like.

```
I think you want: sellers can filter the orders list by status on /orders.
Unclear: should the filter survive a page reload?
```

If nothing is unclear and the task is small, skip to Step 4.

## Step 2: Ask (only what you cannot find yourself)

First look in the code, `README.md`, `AGENTS.md`, and `docs/`. Ask only what is still unclear.

Ask when:

- [ ] The request can mean two different things.
- [ ] It deletes, moves, renames, or restructures code.
- [ ] It touches login, permissions, personal data, payments, or production.
- [ ] It needs a new library, service, or database change.
- [ ] You cannot say what done looks like.

Format, one question at a time:

```
Question: <one clear question>
Recommended: <your best answer and why, in one line>
```

If the user says "whatever you think", offer two options and recommend one.

## Step 3: Confirm

```
Goal:          <one line>
Done when:     <what the user will see or be able to do>
Out of scope:  <what you will NOT do>
```

Wait for the user to say yes.

## Step 4: Plan

Write the plan before editing any file:

```
1. <task>  Files: <paths>  Check: <command or what to look at>
2. <task>  Files: <paths>  Check: <command>
3. ...
```

Rules for the plan:

- Each task changes 1 to 5 files.
- Order tasks so each one can be checked on its own (database, then API, then UI).
- Every task has a check.
- After every 2 or 3 tasks, run the checks and show the user.

## Step 5: While working

- If you find the plan is wrong, stop and tell the user before changing direction.
- If a new question appears, ask it. Do not guess.
- Do not add things that were not in the confirmed goal. List them as follow-ups.
