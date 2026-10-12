---
name: architecture
description: Use when designing a new system, establishing or changing project architecture, decomposing a system into major responsibilities, deciding module or subsystem boundaries, defining dependency direction, designing data or state flow, evaluating architectural alternatives, planning substantial cross-cutting changes, restructuring a codebase, or reasoning about how a significant feature should fit into an existing system. Focus on requirements, constraints, responsibilities, interfaces, dependencies, data flow, tradeoffs, evolution, and maintainability. Do not use for routine implementation that already fits clearly within the existing architecture. Use frontend-engineering, backend-engineering, security, machine-learning, documentation, code-review, or other domain skills alongside this skill when relevant.
---

# Architecture

Design and evolve software systems so their structure supports the project's actual requirements, constraints, and expected change.

Architecture is about important structural decisions and relationships, not about maximizing abstraction or applying fashionable patterns.

Use the smallest architecture that provides clear responsibilities, manageable dependencies, reliable behavior, and room for the changes the project reasonably expects.

## Core Principles

- Understand requirements and constraints before designing structure.
- Preserve coherent existing architecture unless there is a concrete reason to change it.
- Make responsibilities and ownership clear.
- Keep dependency direction understandable.
- Keep important data and state flows understandable.
- Hide unnecessary implementation complexity behind appropriate interfaces.
- Prefer architecture that localizes change.
- Introduce abstractions only when they solve an actual problem.
- Consider operational and failure behavior where architecture depends on it.
- Make tradeoffs explicit.
- Distinguish current requirements from speculative future needs.
- Architecture should reduce cognitive and change complexity, not merely move it elsewhere.
- Do not redesign a system merely because another architecture could also work.

## When Architecture Is Needed

Use architectural reasoning when the task involves meaningful structural decisions such as:

- designing a new application or system
- defining major subsystems
- deciding where a significant feature belongs
- changing module responsibilities
- changing dependency direction
- introducing a major integration
- changing data or state ownership
- designing communication between independently changing parts
- restructuring a tangled codebase
- planning a substantial cross-cutting change
- evaluating competing architectural approaches
- addressing scaling, reliability, deployment, or operational constraints that affect system structure

Architecture is usually not necessary for:

- small bug fixes
- routine CRUD additions
- isolated UI changes
- straightforward endpoint additions
- local refactors
- ordinary test additions
- implementation that clearly follows an established pattern

unless those changes reveal or require a broader structural decision.

## Existing Projects

For existing projects, recover the architecture before proposing changes.

Start with:

1. Project `AGENTS.md`, if present.
2. Relevant architecture and system documentation.
3. Relevant configuration and project structure.
4. GitNexus MCP tools, when an index exists for the repository and implementation relationships matter.
5. Targeted source inspection where documentation or graph information is insufficient.

Determine:

- major responsibilities
- module or subsystem ownership
- dependency direction
- important interfaces
- data flow
- state ownership
- integration boundaries
- persistence boundaries
- runtime/deployment boundaries where relevant
- existing architectural decisions and constraints

Do not rediscover the entire repository when reliable documentation already provides the necessary map.

Do not treat documentation as implementation proof. Verify important details against the actual project when necessary.

## New Projects

For new projects, begin with the problem rather than a preferred architecture.

Understand:

- what the system must do
- primary users or consumers
- important workflows
- expected scale
- data requirements
- security requirements
- reliability requirements
- deployment/runtime constraints
- external integrations
- team or maintenance constraints
- technology constraints
- known future requirements that are reasonably concrete

Then choose the smallest architecture that supports those needs.

Do not introduce distributed systems, microservices, event buses, queues, repositories, domain layers, plugin systems, or other architectural machinery without a concrete reason.

Start simple while preserving sensible change boundaries.

## Requirements and Constraints

Architectural decisions should trace back to actual requirements or constraints.

Possible constraints include:

- latency
- throughput
- data volume
- consistency
- availability
- offline operation
- device limitations
- compute limitations
- security
- privacy
- regulatory requirements
- deployment environment
- cost
- team size
- development speed
- maintainability
- integration requirements

Distinguish:

- hard constraints
- current requirements
- reasonable near-term expectations
- speculation

Do not design primarily for hypothetical scale or hypothetical future features.

## System Decomposition

Decompose systems around meaningful responsibilities and change boundaries.

A useful subsystem or module should have:

- a clear purpose
- understandable ownership
- coherent responsibilities
- clear interactions with the rest of the system

Prefer high cohesion within responsibilities and manageable coupling between them.

Do not split a system simply to create more modules.

Do not combine unrelated responsibilities merely to reduce file or directory count.

The appropriate scale depends on the project.

A module may be:

- a function
- component
- feature
- package
- service
- process
- application
- pipeline stage
- subsystem

Use terminology that fits the actual project rather than enforcing one universal vocabulary.

## Boundaries and Ownership

Important responsibilities should have identifiable owners.

Consider ownership of:

- business rules
- user interface state
- application state
- persisted data
- external communication
- authentication
- authorization
- configuration
- background processing
- caching
- model inference
- preprocessing
- workflows
- side effects

Unclear ownership often produces duplication, inconsistent behavior, and difficult debugging.

Avoid creating multiple authoritative owners for the same state or rule unless the architecture explicitly requires synchronization and defines how it works.

## Interfaces

Interfaces should expose what consumers need without forcing them to understand unnecessary implementation detail.

An interface may be:

- function or class contract
- module interface
- API
- event
- queue message
- schema
- component contract
- hook
- service boundary
- command
- file format
- model input/output
- integration contract

Prefer interfaces that are:

- clear
- stable enough for their consumers
- appropriately typed or validated
- explicit about meaningful errors and side effects
- no larger than necessary

Hide complexity when doing so improves callers' ability to use the system correctly.

Do not create interfaces merely to place another layer between two pieces of code.

## Abstraction Depth

An abstraction should earn its existence.

Ask:

- Does it hide meaningful complexity?
- Does it centralize behavior that would otherwise be duplicated?
- Does it provide a useful change boundary?
- Does it make callers simpler?
- Does it improve testability or replaceability where that matters?

A useful thought experiment is the deletion test:

If removing the abstraction would spread meaningful complexity across multiple consumers, it is likely providing value.

If removing it would simply eliminate a pass-through layer with little consequence, the abstraction may not be earning its complexity.

This is a reasoning tool, not an automatic deletion rule.

## Dependency Direction

Dependencies should follow understandable ownership and responsibility.

Watch for:

- circular dependencies
- lower-level infrastructure controlling higher-level policy
- shared modules depending on feature-specific behavior
- UI code becoming the owner of domain rules
- domain logic depending unnecessarily on transport or presentation details
- duplicated integration logic across unrelated modules

Prefer dependency direction that keeps important policy and behavior from being unnecessarily coupled to volatile implementation details.

Do not introduce dependency inversion mechanically.

Use it when variation, testing, ownership, or replacement requirements justify it.

## Data Flow

Important data flows should be understandable from origin to destination.

For significant workflows, determine:

- where data enters
- where it is validated
- where it is transformed
- where business rules apply
- where state changes
- where it is persisted
- where side effects occur
- where it leaves the system

Avoid hidden transformations and unexplained state mutation across many layers.

For complex systems, architecture documentation should make major data flows visible.

## State Ownership

State should have a clear authoritative owner.

Consider:

- local UI state
- application state
- server state
- persisted state
- cached state
- derived state
- distributed state
- workflow state

Avoid duplicated sources of truth.

When multiple representations are necessary, define:

- which is authoritative
- how synchronization occurs
- what consistency guarantees exist
- what happens when synchronization fails

Use frontend-engineering or backend-engineering for detailed implementation decisions within those domains.

## Integration Architecture

External systems are independent boundaries with their own contracts and failure behavior.

For significant integrations, consider:

- ownership of integration code
- authentication
- contract translation
- failure handling
- retries
- idempotency
- rate limits
- timeouts
- availability
- data validation
- observability

Keep provider-specific details localized where practical.

Use backend-engineering and security alongside this skill when integration behavior becomes implementation- or security-sensitive.

## Reliability and Failure Boundaries

Architecture should account for important failure modes.

Depending on the system, consider:

- partial failure
- dependency outage
- retry behavior
- duplicate processing
- network interruption
- process restart
- corrupted or inconsistent state
- queue failure
- storage failure
- offline behavior
- degraded operation

Do not introduce reliability infrastructure for failures the project does not meaningfully need to tolerate.

When reliability requirements are important, make the intended guarantees explicit.

## Scalability

Scale architecture according to evidence and credible requirements.

Consider independently:

- request volume
- concurrent users
- data volume
- compute demand
- model-training demand
- storage
- network traffic
- background work
- team/development scale

Do not treat "scalable" as synonymous with microservices or distributed systems.

A well-structured monolith may be the correct scalable architecture for many systems.

Prefer designs that allow future evolution without paying unnecessary distributed-system complexity today.

## Technology Choices

Architecture should not become technology shopping.

Before introducing a technology, determine:

- what problem it solves
- why existing tools are insufficient
- operational cost
- maintenance cost
- team familiarity
- compatibility
- failure modes
- migration cost
- lock-in implications where relevant

Prefer existing project technology when it solves the problem adequately.

Do not introduce a new technology solely because it is popular or architecturally fashionable.

## Architectural Tradeoffs

Meaningful architecture decisions usually involve tradeoffs.

When comparing approaches, evaluate relevant dimensions such as:

- complexity
- maintainability
- reliability
- performance
- security
- consistency
- development speed
- operational burden
- cost
- testability
- portability
- future change

Do not present one approach as universally superior.

Recommend based on the actual project's constraints.

State important disadvantages of the recommended approach.

## Architectural Alternatives

For consequential decisions, consider more than one plausible approach when alternatives materially differ.

Do not manufacture alternatives for trivial decisions.

When comparing alternatives:

1. State the decision being made.
2. State relevant constraints.
3. Describe realistic options.
4. Explain meaningful tradeoffs.
5. Choose the simplest option that satisfies the requirements.
6. Identify what future condition would justify revisiting the decision.

Avoid architecture-by-checklist.

## Evolution and Refactoring

Architecture changes should have a concrete reason.

Potential reasons include:

- repeated change friction
- duplicated business rules
- unclear ownership
- excessive coupling
- difficult testing
- recurring regressions
- scaling constraints
- reliability requirements
- new product requirements that no longer fit existing boundaries

Do not perform architectural refactoring merely to make a diagram look cleaner.

Prefer incremental evolution when possible.

For substantial restructuring:

- understand current behavior
- identify affected consumers
- preserve required compatibility
- separate structural change from behavioral change when doing so materially reduces risk
- define verification
- update architecture documentation

Use code-review when evaluating whether a proposed refactor genuinely improves the resulting system.

## Locality and Change Impact

Good architecture tends to localize related knowledge and change.

When a small requirement requires modifications across many unrelated parts of the system, investigate whether responsibilities are poorly placed.

When the same rule must be changed in multiple locations, investigate whether ownership is duplicated.

Do not automatically centralize everything.

Some duplication is preferable to coupling unrelated domains through an abstraction they do not truly share.

Optimize for understandable change boundaries rather than maximum reuse.

## Testability

Architecture should make important behavior verifiable without requiring unrealistic test setups.

Consider whether:

- dependencies can be controlled where necessary
- important behavior can be exercised through meaningful interfaces
- external systems can be isolated when appropriate
- state transitions can be observed
- failure cases can be reproduced

Do not distort production architecture solely to satisfy mocking patterns.

Dependency injection, adapters, seams, and other techniques are tools, not universal requirements.

Use the testing skill for detailed test strategy and implementation.

## Security Architecture

Security-sensitive architecture may require explicit:

- trust boundaries
- identity boundaries
- authorization ownership
- sensitive-data flows
- secret boundaries
- tenant isolation
- privileged operations

Use the security skill alongside architecture when these concerns materially affect system design.

Do not attempt to replace a security review with general architectural reasoning.

## Machine Learning Architecture

For ML systems, architectural responsibilities may include:

- ingestion
- dataset preparation
- preprocessing
- feature extraction
- training
- evaluation
- experiment tracking
- model artifacts
- inference
- post-processing

Keep major stages replaceable when research or experimentation requires iteration.

Separate research methodology decisions from ordinary implementation details.

Use the machine-learning skill alongside architecture for ML-specific reasoning.

## Documentation

Architecture decisions and system structure should be documented at a depth appropriate to the project.

Documentation may include:

- system overview
- architecture diagrams
- module responsibilities
- data flow
- integration boundaries
- important workflows
- deployment structure
- architectural decisions

Use the documentation skill when creating or substantially updating these artifacts.

Do not create documentation solely because an architecture template lists it.

For small projects, lightweight documentation may be sufficient.

## Repository graph (GitNexus)

When an index exists for the repository, use the GitNexus MCP tools to
support architectural reasoning about the implementation.

Useful operations may include:

- `query` to understand an area
- `context` (`name` + `file_path`) to gather implementation context
- `impact` with `direction: "upstream"` before significant changes
- `trace` (`from`/`to`) when dependency direction matters
- targeted source inspection where documentation or graph information is insufficient

The graph describes implementation relationships.

It does not determine architectural intent, requirements, or methodology.

Do not infer architectural requirements solely from the graph.

## Verification

Architecture proposals should be checked against the actual system and constraints.

Before finalizing a significant architectural change, verify:

- requirements are understood
- affected responsibilities are identified
- important consumers are known
- data flow remains coherent
- state ownership is clear
- dependencies remain manageable
- important failure behavior is considered
- security implications are considered
- migration or compatibility impact is understood
- testing remains practical
- documentation impact is identified

Do not claim an architecture is proven to scale, perform, or remain reliable without evidence appropriate to that claim.

## Avoid

Do not:

- redesign working systems without a concrete reason
- impose one architecture style on every project
- force microservices, clean architecture, DDD, hexagonal architecture, MVC, repositories, event-driven systems, or other patterns mechanically
- create abstractions for hypothetical future variation
- split modules merely because they are large
- centralize unrelated behavior solely to eliminate duplication
- confuse more layers with better architecture
- introduce technology without a concrete need
- optimize for theoretical scale
- treat diagrams as more authoritative than implementation
- treat current implementation as proof that the architecture is intentional
- ignore migration and compatibility impact
- relocate complexity while claiming it was reduced
- make architecture a prerequisite for routine implementation that already has a clear place
