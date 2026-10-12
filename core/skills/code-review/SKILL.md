---
name: code-review
description: Use when reviewing completed or proposed code changes, diffs, pull requests, refactors, bug fixes, dependency changes, or AI-generated code for correctness, regressions, maintainability, architecture consistency, unnecessary complexity, test adequacy, security concerns, performance risks, and unintended effects. Focus on evidence-backed findings and actionable improvements rather than stylistic preference. Use specialized security, performance, testing, frontend-engineering, backend-engineering, or other domain skills alongside this skill when deeper review in those areas is needed.
---

# Code Review

Review code as an independent senior engineer focused on correctness, maintainability, architectural integrity, and regression risk.

A review is not an opportunity to rewrite code according to personal preference.

The goal is to identify meaningful problems, verify that the change accomplishes its intent, and improve overall code health without demanding unnecessary perfection.

## Core Principles

- Understand the change before judging it.
- Review against requirements and project conventions, not personal preference.
- Prioritize correctness and regressions over style.
- Distinguish confirmed problems from concerns that require verification.
- Prefer a few high-confidence findings over a long list of weak observations.
- Explain why a finding matters.
- Propose a concrete direction when identifying structural problems.
- Consider the resulting system, not only the changed lines.
- Do not assume passing tests prove the implementation is correct.
- Do not assume AI-generated code is correct because it looks plausible.
- Do not claim something is broken without evidence or a clear reasoning path.
- Do not require perfection when the change is correct, maintainable, and improves the system.

## Review Context

Before reviewing implementation, determine:

- what the change is intended to accomplish
- expected behavior
- relevant requirements
- affected modules or workflows
- project architecture and conventions
- existing tests and verification
- whether compatibility requirements exist

Read relevant project documentation first when available.

If the project has `AGENTS.md`, respect its project-specific instructions.

If a GitNexus index exists for the repository, use the GitNexus MCP tools when relationships, callers, dependencies, or impact need to be understood.

For a diff or targeted change, begin with the changed area rather than rediscovering the entire repository.

## Review Scope

Review the smallest scope that provides enough context to evaluate the change correctly.

Inspect surrounding code when necessary to determine:

- ownership
- existing conventions
- callers
- consumers
- shared behavior
- side effects
- compatibility
- architectural impact

Do not expand into unrelated cleanup merely because nearby code could also be improved.

Mention unrelated issues separately only when they materially affect the reviewed change.

## Correctness

Determine whether the implementation actually satisfies the intended behavior.

Consider:

- requirements
- expected outputs
- state transitions
- edge cases
- error paths
- null or empty states
- boundary values
- asynchronous behavior
- race conditions
- partial failures
- integration behavior

Look for mismatches between what the change claims to do and what the implementation actually does.

Do not infer correctness solely from naming, comments, or tests.

## Regression Risk

Ask what existing behavior could have been unintentionally changed.

Consider:

- existing callers
- shared utilities
- public interfaces
- persisted data
- configuration
- navigation
- state management
- external integrations
- background jobs
- platform-specific behavior

When a GitNexus index exists and dependency impact matters, use the GitNexus MCP tools to inspect callers, impact, or affected tests.

Distinguish a plausible regression path from speculation.

## Readability and Maintainability

Evaluate whether future developers can understand and safely modify the code.

Look for:

- unclear ownership
- misleading names
- unnecessary indirection
- duplicated logic
- hidden side effects
- deeply tangled control flow
- unnecessary state
- stale compatibility code
- dead code created by the change
- comments that contradict behavior
- abstractions that obscure rather than clarify

Do not enforce arbitrary line-count limits.

A large function or file is a concern when its responsibilities, coupling, or change boundaries make it difficult to understand or maintain—not merely because it crossed a numerical threshold.

## Simplicity

Ask whether the implementation is more complicated than the problem requires.

Look for:

- unnecessary abstractions
- unnecessary dependencies
- duplicated helpers
- speculative generalization
- wrappers that only forward calls
- additional state that can be derived
- multiple branches representing the same concept
- new infrastructure for a problem existing tools already solve

Do not equate fewer lines with better code.

Prefer the simplest solution that remains correct, clear, maintainable, secure, and consistent with the project.

When recommending simplification, explain what complexity can actually be removed.

## Architecture

Evaluate whether the change fits the system's existing architecture.

Consider:

- module responsibilities
- dependency direction
- separation of concerns
- ownership
- data flow
- state ownership
- service boundaries
- public interfaces
- integration boundaries

Watch for:

- feature-specific behavior leaking into shared infrastructure
- business logic moving into presentation code
- persistence details leaking into unrelated layers
- duplicated architectural paths
- circular dependencies
- competing patterns for the same responsibility
- abstractions that relocate complexity instead of reducing it

Do not demand a new architecture merely because another pattern might also work.

When a structural problem exists, propose the direction of the restructuring rather than only saying the code is complex.

## Types and Contracts

Where the language and project support explicit types or contracts, inspect whether important boundaries remain clear.

Look for:

- unjustified broad types
- unsafe casts
- silent fallbacks
- mismatched input/output types
- optional values that violate actual invariants
- interface changes that break consumers
- duplicated representations of the same concept

Do not demand additional type machinery when it provides no meaningful safety or clarity.

## Tests

Review tests as evidence, not as proof by themselves.

Determine:

- whether relevant behavior is covered
- whether regression-prone behavior has protection
- whether edge and failure cases matter
- whether tests assert meaningful behavior
- whether mocks hide important integration behavior
- whether the test would fail if the bug or regression returned

Do not require tests mechanically for every trivial change.

For bug fixes, strongly prefer a regression test when the project supports testing and the behavior can reasonably be tested.

Use the testing skill when deeper test design, implementation, or verification is required.

## Security Review Boundary

During any review, notice obvious security implications.

Examples include:

- missing authorization
- unsafe handling of untrusted data
- exposed secrets
- injection
- sensitive-data leakage
- unsafe external calls
- insecure file handling
- high-impact side effects

When security is substantial or uncertain, use the security skill for deeper analysis.

Do not duplicate a full security audit inside an ordinary code review unless security is actually part of the requested scope.

## Performance Review Boundary

Notice obvious performance regressions such as:

- repeated expensive work
- N+1 access patterns
- unbounded operations
- unnecessary network requests
- avoidable rendering work
- blocking work on critical paths
- excessive memory usage

Do not claim a performance problem from intuition alone when measurement is required.

Use the performance skill when deeper profiling or optimization analysis is appropriate.

## Dependencies

When the change adds or upgrades dependencies, consider:

- whether the existing stack already solves the problem
- why the dependency is needed
- maintenance and compatibility
- resulting transitive changes
- lockfile changes
- security implications
- licensing requirements when relevant to the project
- migration or behavioral changes

Do not assume semantic versioning guarantees compatibility.

For meaningful upgrades, inspect relevant release or migration information when available.

Use the security skill when supply-chain or vulnerability concerns are substantial.

## Dead Code

Changes may leave behind unused or obsolete code.

Identify dead code when evidence supports that conclusion.

Before deleting uncertain code, verify its usage through the available project tools.

If a GitNexus index exists, use it when appropriate to inspect references.

Do not delete code merely because its purpose is not immediately obvious.

Preserve unrelated user work.

## Findings

Report findings by importance.

Use these severity levels when useful:

### Critical

A high-confidence issue with potentially severe consequences, such as:

- data loss
- serious security vulnerability
- major broken functionality
- destructive unintended behavior

### High

A significant correctness, regression, architecture, or reliability problem that should normally be addressed before relying on the change.

### Medium

A real maintainability, edge-case, testing, or design problem worth addressing, but with more limited impact.

### Low

A minor improvement with concrete value.

### Suggestion

Optional improvement or alternative that is not required for correctness.

Do not inflate severity.

Do not label personal stylistic preferences as defects.

If no meaningful findings exist, say so rather than inventing issues to make the review appear thorough.

## Writing Findings

A useful finding should explain:

1. Where the issue is.
2. What is wrong.
3. Why it matters.
4. Under what condition it occurs.
5. What direction would resolve it.

Prefer:

"Concurrent requests can both pass this existence check before either insert completes, allowing duplicate records. Enforce the uniqueness invariant atomically in the database and handle the conflict."

over:

"Possible race condition."

Be concise when the issue is straightforward.

## Evidence

Base findings on evidence from:

- the diff
- implementation
- tests
- project documentation
- configuration
- dependency relationships
- actual command or test output

Clearly distinguish:

- confirmed issue
- likely issue
- question requiring clarification
- optional suggestion

Never invent command results, failing tests, runtime behavior, or project requirements.

## Verification Review

Inspect the verification story when relevant.

Ask:

- What was actually tested?
- Were relevant tests run?
- Was type checking or compilation performed?
- Was the build performed where appropriate?
- Were integration boundaries exercised?
- Were important failure states checked?
- Were platform-specific changes verified on the relevant platform?

Do not state that verification succeeded unless evidence exists.

If verification is missing, identify the specific verification that would materially reduce uncertainty.

## Self-Review

Use this skill when reviewing code you just implemented if an independent review pass would materially improve confidence.

During self-review:

- re-read the requirements
- inspect the resulting diff
- look for accidental scope expansion
- look for assumptions made during implementation
- check for dead code
- check relevant callers and consumers
- verify the smallest relevant behavior

Do not rubber-stamp your own implementation.

## Review Output

For substantial reviews, prefer this structure:

### Findings

Present meaningful findings from highest to lowest severity.

Include file/symbol references when available.

### Questions or Assumptions

Include only unresolved information that materially affects confidence.

### Verification

State what evidence was available and what remains unverified.

Do not produce a mandatory merge verdict unless the user or project workflow specifically asks for one.

## Documentation Impact

Check whether the change alters documented:

- architecture
- interfaces
- workflows
- module responsibilities
- configuration
- important system behavior

If so, identify the relevant documentation that should change.

Do not request documentation updates for implementation details that the documentation does not describe.

## Avoid

Do not:

- rubber-stamp code
- invent findings
- focus on formatting while missing correctness problems
- rewrite code based on personal taste
- enforce arbitrary file or diff size limits
- demand abstractions without demonstrated value
- demand fewer lines at the expense of clarity or correctness
- require every possible edge case regardless of actual risk
- perform unrelated cleanup as part of the review
- duplicate specialist security or performance audits unnecessarily
- assume tests prove correctness
- assume AI-generated code is trustworthy
- claim verification that did not occur
- make the human's merge decision unless explicitly asked by the workflow
