---
name: debugging
description: Use when something is broken — errors, exceptions, crashes, failing tests, wrong output, a page that does not load, or behavior that differs from what is expected. Find the root cause before changing code.
---

# Debugging

Find the cause first. Do not change code hoping it helps.

## Steps

1. **Get the facts.** Exact error message, stack trace, file and line, steps to reproduce, expected vs actual.
2. **Reproduce.** Run the failing test, command, or page yourself. If you cannot reproduce it, say so and ask for details.
3. **Read the code** at the line in the error. Follow the call path back to where the bad value comes from.
4. **Form one guess** about the cause. Write it down in one sentence.
5. **Check the guess** with evidence: a log line, a test, a debugger value, a query result.
6. **Fix the cause**, not the symptom. Smallest change that fixes it.
7. **Prove it.** Run the reproduction again. Add a test that would have caught the bug.
8. **Clean up.** Remove temporary prints and debug code.

## Look here first

1. The exact line in the error message.
2. What changed recently: `git diff`, `git log -5`.
3. Configuration and environment differences.
4. Input data: null, empty, wrong type, wrong format.
5. Timing: async calls, order of operations.

## Stop and ask when

- Two attempts at a fix did not work.
- The fix needs a change to login, permissions, the database schema, or production.
- You find that the "bug" might be intended behavior.

## Do not

- Catch and ignore the exception to hide the error.
- Delete or skip a failing test.
- Rewrite large parts of the code to fix a small bug.
- Say it is fixed without running the reproduction again.
