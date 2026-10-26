---
name: frontend-engineering
description: Use when building, modifying, reviewing, or architecting user-facing frontend code, including web and mobile interfaces, components, screens, forms, client-side state, data fetching, navigation, responsive behavior, accessibility implementation, loading/error/empty states, and frontend integration boundaries. Focus on frontend engineering and maintainability. For visual design, aesthetic direction, design critique, or interface polish, use Impeccable alongside this skill when available and relevant.
---

# Frontend Engineering

Build maintainable, accessible, reliable frontend systems that fit the architecture and conventions of the project.

This skill governs how frontend interfaces are engineered.

Visual design direction and aesthetic polish are separate concerns. When the task involves improving visual hierarchy, typography, spacing, composition, motion, design-system quality, or overall interface aesthetics, use Impeccable alongside this skill when available.

## Core Principles

- Understand the existing frontend before changing it.
- Follow project conventions unless there is a concrete reason not to.
- Prefer simple component boundaries and clear ownership.
- Separate presentation, state, business logic, and external communication where doing so improves clarity.
- Use the simplest state-management approach appropriate to the problem.
- Treat loading, empty, error, and success states as part of the feature.
- Build accessibility and responsive behavior into the implementation rather than treating them as later cleanup.
- Do not introduce libraries, patterns, abstractions, or directory structures merely because they are common elsewhere.

## Project Discovery

Before substantial frontend work, determine:

- framework and runtime
- routing/navigation approach
- component organization
- styling and design-system approach
- state-management patterns
- data-fetching patterns
- form and validation patterns
- API or service boundaries
- testing conventions
- accessibility conventions
- platform-specific requirements

Read relevant project documentation first.

If a GitNexus index exists for the repository, use the GitNexus MCP tools to understand relevant components, dependencies, state flows, services, and call relationships before broad manual exploration.

Do not impose React, Next.js, React Native, Vue, Svelte, or other framework conventions on a project that uses different established patterns.

## Component Design

Components should have clear responsibilities.

Prefer:

- focused components
- explicit inputs and outputs
- composition where it improves flexibility
- reusable primitives for genuinely repeated behavior
- feature-specific components when reuse is not needed
- predictable data flow

Avoid:

- components that mix unrelated responsibilities
- duplicated UI logic
- hidden side effects
- unnecessary wrapper components
- premature generic component systems
- large refactors solely to satisfy arbitrary size limits

Do not split components based only on line count.

Split when responsibilities, state ownership, reuse, readability, testing, or change boundaries justify it.

## UI and Business Logic

Keep rendering concerns separate from business rules and external communication when practical.

A component should not become the accidental owner of:

- API implementation details
- persistence logic
- complex domain rules
- unrelated data transformations
- cross-feature orchestration

Use the architecture already established by the project.

For example, a project may use services, hooks, controllers, stores, repositories, server actions, view models, or another pattern.

Do not introduce a new architectural layer unless it solves an actual problem.

## State Management

Use the smallest state scope that correctly represents ownership.

Consider:

- local component state for local interaction
- lifted state for nearby shared behavior
- URL/navigation state for shareable or navigational state
- server-state mechanisms for remote cached data
- context for suitable cross-tree concerns
- global stores for genuinely application-wide client state

These are options, not mandatory rules.

Follow the project's existing state architecture where appropriate.

Avoid:

- unnecessary global state
- duplicated sources of truth
- storing derived values when they can be safely computed
- synchronizing multiple states without a clear ownership model
- introducing a state library for problems existing tools already solve

## Data and API Boundaries

Frontend code should treat external data as untrusted until validated by the guarantees available in the project.

Understand:

- request lifecycle
- response shape
- authentication requirements
- error behavior
- loading behavior
- caching
- retries
- optimistic updates
- offline behavior where applicable

Keep transport-specific details away from presentation components when the project architecture supports that separation.

Do not invent backend fields, endpoints, response structures, or guarantees.

## Forms and User Input

Forms should handle:

- validation
- submission state
- errors
- disabled states
- success behavior
- repeated submissions
- relevant edge cases

Use the project's existing form and validation approach.

Do not duplicate validation rules unnecessarily.

Client-side validation improves user experience but must not be treated as a security boundary.

## Loading, Empty, Error, and Success States

User-facing asynchronous features should account for meaningful states where applicable:

- initial loading
- refreshing
- empty data
- partial data
- failure
- retry
- success
- stale or offline state

Do not leave users with unexplained blank interfaces or silent failures.

Choose skeletons, progress indicators, optimistic behavior, or other feedback based on the actual interaction rather than applying one pattern universally.

## Accessibility

Use semantic platform primitives whenever possible.

For web interfaces:

- preserve keyboard accessibility
- use semantic HTML
- provide accessible names for controls
- maintain logical focus behavior
- preserve meaningful heading and landmark structure
- do not rely only on color to communicate state
- respect project accessibility requirements and applicable WCAG targets

For native interfaces:

- use platform accessibility APIs
- provide meaningful labels and roles
- support appropriate touch targets
- account for screen readers and platform interaction conventions

Prefer native accessible primitives over recreating their behavior manually.

Accessibility requirements should be verified rather than assumed.

## Responsive and Adaptive Interfaces

Interfaces should work across the viewport sizes, devices, orientations, and platform constraints required by the project.

Do not hardcode universal breakpoints.

Use:

- the project's existing breakpoints
- content-driven layout decisions
- platform conventions
- device constraints
- safe areas where applicable

Test the ranges that matter to the actual product.

## Performance

Avoid obvious frontend performance problems, but do not optimize blindly.

Watch for:

- unnecessary renders
- excessive network requests
- oversized client bundles
- expensive computations during interaction
- unbounded lists
- unnecessarily large assets
- avoidable layout instability
- wasteful state updates

Measure before making significant performance-oriented architectural changes.

Use a dedicated performance skill when deeper profiling or optimization is required.

## Design Systems

When a project already has a design system:

- reuse its components
- reuse tokens
- preserve established interaction patterns
- avoid creating competing primitives
- avoid arbitrary styling values when established tokens exist

When no design system exists, do not create a large one unless project complexity justifies it.

For visual direction, aesthetic consistency, typography, spacing, composition, color, motion, or design critique, use Impeccable when available and relevant.

## Platform Awareness

Respect the platform being built.

Web and native applications have different:

- navigation models
- interaction patterns
- accessibility APIs
- lifecycle behavior
- performance constraints
- storage mechanisms
- layout constraints

Do not blindly transfer browser patterns into native applications or native patterns into web applications.

## Integration Boundaries

Understand how the frontend interacts with:

- backend APIs
- authentication
- storage
- analytics
- payments
- notifications
- maps
- device capabilities
- third-party SDKs
- content systems

Keep integrations behind clear boundaries where the existing architecture supports it.

Use specialized security, API/interface, or domain skills alongside this skill when those concerns are substantial.

## Verification

After frontend changes, perform the smallest relevant verification available.

Depending on the project, verify:

- expected behavior
- type checking
- linting
- relevant tests
- build
- navigation
- loading/error/empty states
- keyboard interaction
- accessibility
- responsive/adaptive behavior
- API integration
- platform-specific behavior

Do not claim a device, browser, screen reader, build, test, or interaction was verified unless it was actually checked.

Use the testing skill when deeper test creation or regression verification is needed.

## Documentation

Update project documentation when frontend changes affect documented:

- architecture
- component responsibilities
- state flow
- navigation
- data flow
- integrations
- configuration
- important workflows

Do not update documentation for trivial implementation changes that do not change what the documentation describes.

## Avoid

Do not:

- force a preferred framework pattern onto an existing project
- introduce libraries without a concrete need
- rewrite working frontend code merely for stylistic preference
- mix unrelated business logic into presentation components
- create global state unnecessarily
- invent API behavior
- treat client validation as security
- ignore failure and empty states
- hardcode arbitrary responsive rules without project context
- sacrifice accessibility for visual convenience
- perform major optimization without evidence
- duplicate an existing design system
- compete with Impeccable on visual design responsibilities
