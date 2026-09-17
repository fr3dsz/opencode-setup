---
name: testing
description: Use when creating, updating, running, or evaluating tests, or when verifying that a code change works correctly without introducing regressions.
---

# Testing

Use this skill when verification through tests is relevant.

## Core Principle

Tests should provide evidence that the system behaves correctly.

Do not create tests merely to increase coverage numbers.

## Before Writing Tests

Understand:

- what behavior is expected
- which component owns that behavior
- existing testing conventions
- existing test structure
- available test commands
- relevant project documentation

Reuse existing patterns whenever possible.

## Test Selection

Choose the smallest appropriate test scope.

Prefer:

1. focused unit test
2. component/service test
3. integration test
4. end-to-end test

Use broader tests when the change affects multiple components.

## Test Design

Tests should verify behavior rather than implementation details when practical.

Prefer:

- clear inputs
- deterministic behavior
- explicit expected results
- isolated failures
- meaningful test names

Avoid brittle tests that depend unnecessarily on:

- internal implementation details
- timing
- random values
- external services
- machine-specific state

## When Fixing a Bug

For a bug:

1. reproduce the failure
2. create or identify a test that demonstrates it
3. fix the implementation
4. verify the test now passes
5. run relevant regression tests

## Test Data

Use safe and representative test data.

Do not use:

- real credentials
- production secrets
- unnecessary personal information
- destructive production data

## Verification

After changes, use the project's existing verification commands.

Examples include:

- unit tests
- integration tests
- type checking
- linting
- builds
- static analysis

Do not invent commands if the project already documents them.

## Reporting

State:

- what tests were run
- what passed
- what failed
- what could not be run
- any remaining uncertainty

Never claim tests passed if they were not actually executed.