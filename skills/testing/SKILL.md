---
name: testing
description: Use when writing, fixing, or running tests, or when you need to prove a change works — unit tests, integration tests, regression tests for a bug, test data, and reading test results.
---

# Testing

## Find how the project tests

Look for the test command in `README.md`, `package.json` scripts, `pom.xml` / `mvnw`, `pyproject.toml`, or `Makefile`. Use that command. Do not invent a new test setup.

## What to test

- New behavior: at least one test for the normal case and one for a failure or edge case.
- Bug fix: first write a test that fails because of the bug, then fix the code, then see it pass.
- Permissions: a user cannot read or change another user's or organization's data.

## Writing a good test

- [ ] Test name says what should happen: `rejectsExpiredToken`, `returns404ForOtherOrganization`.
- [ ] Arrange, act, assert. One behavior per test.
- [ ] Assert on results the user cares about, not on internal details.
- [ ] No real network calls or real secrets.
- [ ] Test data lives in the test folder, next to the tests.
- [ ] Copy the style of the existing tests in the same folder.

## Running tests

1. Run only the related tests first (one file or class).
2. Then run the full suite if it is fast enough.
3. If a test fails, read the full error, find the file and line, and fix the cause. Do not delete or skip the test to make it pass.

## Reporting

Say:

- The exact command you ran.
- How many passed, failed, skipped.
- For each failure: test name, file, and the error message.

Never say tests pass if you did not run them.
