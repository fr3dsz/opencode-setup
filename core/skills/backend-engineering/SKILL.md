---
name: backend-engineering
description: Use when building, modifying, reviewing, or architecting backend systems, including APIs, services, business logic, database access, persistence, authentication or authorization integration, background jobs, queues, caching, external integrations, transactions, validation, error handling, concurrency, retries, and public or internal interfaces. Focus on reliable backend architecture, clear boundaries, data integrity, stable contracts, and maintainability. Use specialized security, testing, or performance skills alongside this skill when those concerns require deeper analysis.
---

# Backend Engineering

Build reliable, maintainable backend systems with clear responsibilities, stable interfaces, and explicit data boundaries.

This skill governs how backend systems are engineered.

Security, testing, and performance are cross-cutting concerns. Apply their specialized skills alongside this one when the task substantially involves those areas.

## Core Principles

- Understand the existing backend before changing it.
- Follow established architecture and conventions unless there is a concrete reason not to.
- Keep transport, business logic, persistence, and external integrations appropriately separated.
- Define clear contracts between system boundaries.
- Validate untrusted input at appropriate boundaries.
- Protect data integrity.
- Make failure behavior explicit.
- Consider retries, concurrency, and partial failure when side effects matter.
- Prefer the smallest architecture that correctly solves the problem.
- Do not introduce infrastructure, abstractions, or patterns merely because they are common in other systems.

## Project Discovery

Before substantial backend work, determine the relevant:

- runtime and framework
- application architecture
- route or transport layer
- service or domain layer
- persistence approach
- database and schema
- API conventions
- validation approach
- authentication and authorization architecture
- external integrations
- background processing
- caching
- configuration
- testing conventions
- deployment/runtime constraints

Read relevant project documentation first.

If `.codegraph/` exists, use CodeGraph to understand relevant routes, services, domain logic, persistence, callers, dependencies, and integration paths before broad manual exploration.

Do not impose a preferred backend architecture on a project that already has a coherent one.

## Architecture and Responsibilities

Keep responsibilities clear.

Depending on the project, backend responsibilities may include:

- transport or route handling
- input validation
- application orchestration
- domain or business logic
- persistence
- external service communication
- background processing
- event handling
- caching

These are responsibilities, not mandatory directories or layers.

Do not create controllers, services, repositories, domain layers, or other abstractions unless they improve the actual system.

Avoid:

- route handlers containing unrelated business and persistence logic
- business rules duplicated across entry points
- persistence details leaking unnecessarily throughout the application
- hidden side effects
- circular dependencies
- abstractions that only forward calls without adding useful boundaries

## Interfaces and Contracts

Treat interfaces between independently changing parts of the system as contracts.

Examples include:

- REST endpoints
- GraphQL schemas
- RPC interfaces
- events
- queue messages
- webhooks
- service interfaces
- module boundaries
- shared types

For important interfaces, make expected:

- inputs
- outputs
- errors
- side effects
- compatibility requirements

clear and predictable.

Do not expose implementation details unnecessarily.

When changing an existing interface, identify its consumers before making breaking changes.

Prefer additive, backward-compatible changes when practical.

Breaking changes should be intentional and their migration impact understood.

## API Design

Follow the project's established API style.

For APIs, consider:

- resource or operation semantics
- request and response shape
- status/error semantics
- filtering
- sorting
- pagination or bounded results
- compatibility
- retry behavior
- authentication requirements
- authorization requirements

Do not force REST conventions onto GraphQL, RPC, event-driven, or other interface styles.

Do not require pagination mechanically for every collection. Use pagination, cursors, limits, streaming, or another bounded strategy when result size can become significant.

Prefer predictable naming and behavior across related interfaces.

## Validation and Trust Boundaries

Treat data crossing a trust boundary as untrusted until the system has sufficient evidence otherwise.

Potential boundaries include:

- user input
- API requests
- uploaded data
- webhook payloads
- third-party responses
- queue or event payloads
- environment/configuration values
- imported files
- data produced by independently deployed systems

Validate according to risk and existing architecture.

Validation may include:

- shape
- type
- allowed values
- size
- format
- relationships
- business invariants

Avoid redundant validation at every internal function boundary when trusted typed code already establishes the necessary guarantees.

Do not assume database data is universally trustworthy. Legacy data, manual modifications, migrations, corruption, or independently written records may violate current assumptions.

## Business Logic

Business rules should have an identifiable owner.

Keep important rules:

- explicit
- testable
- reusable across relevant entry points
- separate from transport-specific behavior where practical

Do not duplicate the same business rule in multiple routes, jobs, or consumers.

Do not bury important domain behavior inside generic utilities.

## Persistence and Data Integrity

Understand the project's persistence model before modifying data behavior.

Consider:

- schema constraints
- relationships
- uniqueness
- transactions
- indexes
- migrations
- consistency requirements
- deletion behavior
- concurrency
- data lifecycle

Use database constraints when they are the appropriate source of truth for data invariants.

Do not rely solely on application-level checks for invariants that must remain true under concurrent writes.

Avoid read-then-write assumptions when another process can modify the same state between operations.

Use transactions when multiple operations must succeed or fail as one logical unit.

Do not introduce transactions mechanically when operations do not require atomicity.

## Error Handling

Failure behavior should be predictable.

Distinguish where relevant between:

- invalid input
- authentication failure
- authorization failure
- missing resources
- conflicts
- dependency failures
- transient failures
- internal failures

Use the project's established error representation.

For public interfaces, avoid exposing secrets, stack traces, internal queries, or unnecessary implementation details.

Do not silently swallow errors merely to keep a request successful.

Preserve useful diagnostic context for appropriate logging and observability.

## Authentication and Authorization

Understand the difference between:

- authentication: who or what is making the request
- authorization: whether that identity may perform the action

Follow the project's existing identity and permission architecture.

Do not invent custom cryptography, token formats, or authentication mechanisms when established secure mechanisms already exist.

Authorization should be enforced at a trustworthy backend boundary rather than relying on frontend visibility or client-side checks.

When authentication, authorization, credentials, permissions, sessions, tokens, or sensitive data are central to the task, use the security skill alongside this skill when available.

## External Integrations

Treat external systems as independent failure domains.

For integrations, understand:

- authentication
- request/response contracts
- timeouts
- rate limits
- retries
- error behavior
- idempotency
- availability
- data validation
- webhook behavior where applicable

Do not assume a successful network connection means a successful business operation.

Do not assume a timeout means the external operation failed.

Keep provider-specific behavior behind a clear boundary when practical.

## Side Effects and Idempotency

When an operation may be retried or delivered more than once and duplicate execution would be harmful, explicitly consider idempotency.

Examples include:

- payments
- order creation
- financial transfers
- inventory mutations
- webhook processing
- message consumers
- email or notification delivery
- provisioning operations

An idempotency mechanism must protect the operation, not merely accept a key.

Where idempotency keys are appropriate:

- identify one logical intent consistently across retries
- do not generate a new key for every retry attempt
- prevent concurrent claims atomically
- detect reuse of a key with incompatible input
- define behavior for requests already in progress
- retain records long enough to cover realistic retry or redelivery windows

Remember that remote side effects can have an unknown outcome.

A timeout or lost response may occur after the external system already completed the operation.

Design retry behavior accordingly.

Do not require idempotency machinery for operations where duplicate execution is naturally safe or where the architecture provides another reliable mechanism.

## Concurrency

When multiple requests, workers, jobs, or processes can modify the same state, consider concurrency explicitly.

Look for:

- race conditions
- lost updates
- duplicate processing
- check-then-act behavior
- ordering assumptions
- stale reads
- competing workers

Use appropriate mechanisms such as:

- database constraints
- atomic operations
- transactions
- optimistic concurrency
- locks
- idempotency
- queue semantics

Choose based on the actual consistency requirements.

Do not add locking or distributed coordination without evidence it is needed.

## Background Jobs and Queues

For asynchronous work, understand:

- delivery guarantees
- retry policy
- ordering requirements
- failure handling
- dead-letter behavior
- idempotency requirements
- visibility/acknowledgement behavior
- job state
- observability

Assume duplicate delivery is possible unless the actual system provides stronger guarantees that have been verified.

Do not treat queue delivery as equivalent to successful processing.

## Caching

Use caching only when there is a concrete reason.

Before adding or modifying caching, understand:

- what is cached
- cache key
- ownership
- invalidation
- expiration
- consistency requirements
- failure behavior

Do not allow a cache to accidentally become the authoritative source of data unless the architecture intentionally defines it that way.

Prefer correctness over cache complexity.

## Configuration and Secrets

Keep environment-specific configuration outside application logic where practical.

Validate important configuration at startup or another appropriate boundary.

Do not:

- hardcode secrets
- log credentials or tokens
- commit sensitive configuration
- expose server secrets to client bundles
- invent fallback credentials

Use the security skill for deeper secret-management or security-sensitive configuration work.

## Observability

Backend failures should be diagnosable.

Preserve useful context for:

- logs
- metrics
- traces
- correlation/request identifiers
- job execution information

Do not log unnecessary sensitive information.

Use the project's existing observability approach.

Use a specialized observability capability when deeper instrumentation design is required.

## Performance

Avoid obvious backend inefficiencies, including:

- unbounded queries
- repeated unnecessary database calls
- N+1 access patterns
- unnecessary serialization
- repeated external requests
- blocking expensive work in latency-sensitive paths

Do not perform major optimization based only on intuition.

Measure when performance is an actual concern.

Use a performance skill when deeper profiling or optimization is required.

## Verification

After backend changes, perform the smallest relevant verification available.

Depending on the project, verify:

- expected behavior
- type checking
- linting
- focused tests
- integration tests
- build
- API behavior
- database behavior
- migration behavior
- error cases
- authorization behavior
- retry behavior
- concurrency-sensitive behavior
- external integration boundaries

Do not claim a service, database, API, job, migration, external provider, or deployment was verified unless it was actually checked.

Use the testing skill when deeper test creation or regression verification is needed.

## Documentation

Update project documentation when backend changes affect documented:

- architecture
- service responsibilities
- interfaces
- data models
- data flow
- integrations
- configuration
- background processing
- important workflows

Do not update unrelated documentation for implementation details that do not change what the documentation describes.

## Avoid

Do not:

- impose unnecessary architectural layers
- invent APIs, schemas, fields, or provider behavior
- trust external input without considering the boundary
- duplicate important business rules
- scatter persistence logic without clear ownership
- rely on client-side authorization
- expose internal errors publicly
- assume timeouts mean remote failure
- assume queues guarantee exactly-once processing
- use check-then-act logic where atomicity matters
- introduce caching without an invalidation strategy
- add distributed coordination without a concrete need
- make breaking interface changes without understanding consumers
- optimize without evidence
- rewrite working backend code merely to fit a preferred pattern
