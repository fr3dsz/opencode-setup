---
name: debugging
description: Use when diagnosing bugs, errors, crashes, unexpected behavior, failing tests, incorrect output, or runtime problems. Follow a root-cause-first debugging workflow instead of guessing or rewriting code.
---

# Debugging

Use this skill whenever the task involves diagnosing or fixing unexpected behavior.

## Core Principle

Do not treat the first symptom as the root cause.

Understand the failure before changing code.

Prefer the smallest change that correctly fixes the root cause.

## Workflow

### 1. Reproduce

Determine:

- What is expected?
- What actually happens?
- Can the failure be reproduced?
- What exact command, action, input, or state triggers it?

If reproduction is impossible, clearly state that and continue with evidence-based investigation.

### 2. Locate the Failure

Inspect only the code and configuration relevant to the failure.

Look at:

- error messages
- stack traces
- logs
- failing tests
- recent changes
- relevant call paths
- configuration
- data entering the failing component

Do not read the entire repository unless necessary.

### 3. Identify the Root Cause

Before modifying code, form a concrete explanation of why the failure occurs.

Distinguish:

- symptom
- immediate cause
- underlying cause

Do not make speculative fixes without evidence.

### 4. Check Existing Architecture

Before changing a component, understand:

- who calls it
- what it depends on
- what depends on it
- expected inputs
- expected outputs
- relevant project documentation

Use CodeGraph when available.

### 5. Apply the Smallest Correct Fix

Prefer:

- localized changes
- preserving existing interfaces
- preserving established patterns
- avoiding unnecessary refactors

Do not rewrite working systems merely because another implementation is cleaner.

### 6. Verify

After the fix:

- reproduce the original failure
- confirm the expected behavior
- run relevant tests
- run type checking/build/lint where applicable
- check for obvious regressions

### 7. Explain

When reporting the fix, summarize:

1. What failed
2. Why it failed
3. What changed
4. How it was verified

## Avoid

Do not:

- randomly change multiple files
- suppress errors without understanding them
- remove validation simply to make tests pass
- rewrite large sections unnecessarily
- assume an error message identifies the root cause
- claim a fix is verified when it was not tested

## Debugging Priority

Prioritize:

1. Correctness
2. Data integrity
3. Security
4. Reliability
5. Maintainability
6. Performance
7. Style