---
name: performance
description: Use when a task has explicit performance requirements, users or monitoring report slowness, a performance regression is suspected, profiling or measurement reveals a bottleneck, resource usage is problematic, or optimization of latency, throughput, responsiveness, memory, CPU, GPU, I/O, network, database, rendering, bundle size, training, inference, or other measurable performance behavior is requested. Focus on measurement, bottleneck identification, targeted optimization, comparable verification, and regression prevention. Do not activate merely because code could theoretically be faster. Use frontend-engineering, backend-engineering, machine-learning, architecture, testing, code-review, security, or other domain skills alongside this skill when relevant.
---

# Performance

Improve performance through evidence rather than intuition.

Performance optimization is an experimental engineering process:

1. Define what performance means for the task.
2. Establish a baseline.
3. Identify the actual bottleneck.
4. Form a specific optimization hypothesis.
5. Make the smallest targeted change.
6. Measure again under comparable conditions.
7. Keep the change only when its overall value justifies its cost.
8. Guard important performance characteristics when regression risk warrants it.

Do not optimize simply because an implementation looks theoretically inefficient.

## Core Principles

- Measure before significant optimization.
- Optimize the metric that matters to the actual user or system.
- Identify the bottleneck before selecting the technique.
- Change one important variable at a time when practical.
- Compare measurements under sufficiently similar conditions.
- Consider measurement noise and variance.
- Preserve correctness while optimizing.
- Prefer removing unnecessary work over making unnecessary work faster.
- Consider memory, CPU, GPU, I/O, network, storage, and operational cost as different resources.
- Do not trade maintainability for negligible gains.
- Do not keep additional complexity justified solely as an optimization when evidence does not support the benefit.
- Do not generalize performance targets across unrelated systems.

## When Performance Work Is Needed

Use this skill when:

- the user explicitly requests optimization
- performance requirements exist
- users report slowness
- monitoring shows degradation
- a regression is suspected
- profiling identifies expensive work
- resource usage is excessive
- the system must handle a known scale
- latency or throughput affects correctness or usability
- training or inference performance matters
- performance is part of a review or architectural decision

Do not activate this skill merely because:

- a loop exists
- memoization is possible
- caching could theoretically be added
- an index might help
- asynchronous code exists
- a file or bundle appears large without relevant context
- a different algorithm is theoretically faster at scales the system does not encounter

Obvious pathological behavior may justify investigation, but investigate before prescribing substantial optimization.

## Define the Performance Goal

Before optimizing, identify the relevant outcome.

Possible metrics include:

- latency
- response time
- p50 / p95 / p99 latency
- throughput
- startup time
- page load time
- interaction responsiveness
- frame rate
- render duration
- memory usage
- CPU usage
- GPU utilization
- VRAM usage
- disk I/O
- network transfer
- bundle size
- query duration
- queue lag
- job completion time
- training time
- inference latency
- samples or tokens processed per second
- cost per operation
- battery or power usage

Choose metrics based on the actual system.

Do not optimize a proxy metric unless its relationship to the desired outcome is understood.

## Establish a Baseline

A performance change needs a comparison point.

Capture enough information to reproduce or meaningfully compare the measurement.

Depending on the task, record:

- metric
- workload
- input size
- environment
- hardware
- dataset
- concurrency
- cache state
- software version
- relevant configuration
- sample count
- measurement method

The required rigor depends on the importance of the decision.

Do not pretend a casual measurement is a controlled benchmark.

## Measurement Quality

Performance measurements contain noise.

Where meaningful:

- repeat measurements
- inspect variance
- compare distributions or percentiles
- warm up runtimes where appropriate
- distinguish cold and warm behavior
- control relevant inputs
- use representative workloads
- avoid comparing materially different environments

A small numerical improvement inside normal variation is not strong evidence of improvement.

Do not report false precision.

## Identify the Bottleneck

Do not optimize every layer simultaneously.

Determine where time or resources are actually being consumed.

Potential bottlenecks include:

- algorithms
- repeated computation
- unnecessary work
- rendering
- serialization
- database queries
- locking
- connection pools
- network calls
- external services
- filesystem access
- memory allocation
- garbage collection
- data loading
- preprocessing
- CPU-bound computation
- GPU underutilization
- synchronization
- queue contention
- large payloads
- excessive dependencies or assets

Use the profiling and diagnostic tools appropriate to the actual stack.

Do not infer the bottleneck solely from common performance advice.

## Optimization Hypotheses

Before making a substantial optimization, state the reasoning:

- What is expensive?
- What evidence indicates it is expensive?
- Why should this change reduce the cost?
- Which metric should move?
- What tradeoff does the change introduce?

This does not need to become formal documentation for small tasks.

The purpose is to prevent unrelated optimization techniques from being applied without a causal reason.

## Remove Work First

Before making work faster, ask whether the work is necessary.

Potential opportunities include:

- avoiding duplicate computation
- eliminating redundant requests
- avoiding unnecessary renders
- avoiding repeated serialization
- selecting only required data
- removing unnecessary transformations
- reducing repeated initialization
- avoiding duplicate model inference
- eliminating unused assets or dependencies

Removing work often provides simpler performance improvements than optimizing the same work.

Do not remove behavior the product actually requires.

## Algorithms and Data Structures

When computation is the bottleneck, consider:

- algorithmic complexity
- data structure choice
- repeated scans
- unnecessary copying
- sorting
- searching
- allocation
- batching
- vectorization
- parallelism

Consider actual input sizes.

A theoretically superior algorithm may perform worse at the project's real scale or may add unjustified complexity.

Use representative measurements where the decision matters.

## Database Performance

When database behavior is the bottleneck, investigate before changing schema or queries.

Consider:

- query count
- query duration
- N+1 access
- query plans
- indexes
- filtering
- sorting
- joins
- selected columns
- result size
- transactions
- lock contention
- connection usage
- round trips

Use the database's actual diagnostic capabilities when available.

Do not add an index solely because a filtered column exists.

Indexes have costs, including:

- storage
- write amplification
- maintenance
- migration time

For important query optimization, compare the execution behavior before and after when practical.

Use backend-engineering for data-access architecture and correctness.

## Data Volume and Bounded Work

Consider whether work grows without meaningful bounds.

Examples include:

- loading entire tables
- rendering extremely large lists
- reading entire files unnecessarily
- retaining unlimited history in memory
- processing unlimited queue batches
- returning arbitrarily large responses

Possible strategies include:

- pagination
- cursors
- batching
- streaming
- virtualization
- incremental processing
- bounded caches
- chunking

Choose based on the actual access pattern.

Do not require pagination or batching mechanically when the dataset is known to remain small and bounded.

## Caching

Caching is a performance tradeoff, not a default solution.

Before adding a cache, understand:

- what operation is expensive
- how frequently the result is reused
- what determines the result
- acceptable staleness
- cache ownership
- cache key
- invalidation
- memory/storage cost
- failure behavior
- concurrency behavior

A cache key must include all relevant inputs that affect the cached result.

Be especially careful with:

- user identity
- tenant
- permissions
- locale
- feature flags
- authorization-sensitive data

Do not cache correctness-critical state without understanding the consistency implications.

Consider cache stampedes when many callers can miss the same expensive value simultaneously.

Use security alongside this skill when caching may expose sensitive or cross-user data.

## Concurrency and Parallelism

Concurrency can improve throughput or hide latency, but can also create contention and complexity.

Before increasing concurrency, determine whether the workload is constrained by:

- CPU
- GPU
- I/O
- network
- external rate limits
- database capacity
- memory
- synchronization

More workers, threads, requests, or connections do not automatically improve throughput.

Measure saturation and contention.

Do not introduce parallel execution when ordering, consistency, memory pressure, or downstream capacity makes it unsafe or counterproductive.

## Memory

When memory is the concern, investigate:

- retained objects
- leaks
- unbounded collections
- caches
- duplicate data
- large intermediate representations
- unnecessary copies
- lifecycle cleanup
- batch size
- model size
- loaded assets

Distinguish:

- temporary peak usage
- steady-state usage
- genuine leak behavior

Do not label memory growth a leak without evidence that memory remains unintentionally reachable or fails to stabilize as expected.

## Frontend Performance

For frontend systems, relevant concerns may include:

- initial loading
- rendering
- interaction responsiveness
- network waterfalls
- assets
- bundle size
- layout work
- large lists
- state updates
- unnecessary re-renders
- navigation
- device limitations

Use metrics appropriate to the platform.

Web, native mobile, desktop, and embedded interfaces have different performance characteristics.

Do not apply browser-specific metrics or techniques to non-browser applications.

Use frontend-engineering alongside this skill for implementation decisions.

Use Impeccable when perceived performance or interaction design is also part of the user experience problem.

## Backend Performance

For backend systems, relevant concerns may include:

- endpoint latency
- throughput
- database behavior
- serialization
- external calls
- connection pools
- background work
- queue processing
- caching
- locking
- CPU or memory usage

Distinguish application processing time from time spent waiting on dependencies.

Use traces, profiling, query timing, metrics, or other available evidence to identify where latency originates.

Use backend-engineering alongside this skill for implementation and reliability concerns.

## Network and I/O

When network or I/O dominates, consider:

- number of round trips
- payload size
- batching
- compression
- connection reuse
- request waterfalls
- storage access patterns
- serialization
- streaming
- external-service latency

Do not optimize local computation when most time is spent waiting elsewhere.

## Machine Learning Performance

For ML workloads, relevant metrics may include:

- training time
- inference latency
- throughput
- GPU utilization
- CPU utilization
- VRAM usage
- RAM usage
- data-loader throughput
- preprocessing time
- checkpoint overhead
- model size

Potential techniques depend on the actual bottleneck and may include:

- mixed precision
- gradient accumulation
- batch-size adjustment
- data-loader tuning
- caching preprocessing
- vectorization
- model simplification
- quantization
- compilation
- efficient storage formats

Do not apply these techniques automatically.

For example, a GPU may be underutilized because the data pipeline is slow rather than because batch size is too small.

Use machine-learning alongside this skill for model and experiment correctness.

Do not trade research validity or evaluation correctness for speed.

## Resource-Constrained Environments

When the project has hard constraints such as:

- limited RAM
- limited VRAM
- battery
- mobile hardware
- free-tier compute
- serverless limits
- restricted CPU
- network limitations

treat those constraints as part of the performance requirement.

Optimize for the constrained environment rather than an ideal development machine.

## Performance and Architecture

Some bottlenecks are architectural rather than local.

Examples include:

- excessive network hops
- repeated cross-service communication
- centralized contention
- inappropriate synchronization
- expensive data movement
- wrong state ownership

Use architecture alongside this skill when solving the bottleneck requires changing system structure.

Do not perform architectural restructuring for a micro-optimization.

## Performance and Correctness

Correctness is not optional.

An optimization is invalid if it improves the metric by incorrectly:

- skipping required validation
- returning stale data beyond allowed guarantees
- dropping required work
- weakening authorization
- losing updates
- changing required ordering
- reducing numerical correctness beyond acceptable limits
- changing model evaluation methodology improperly

Run relevant correctness verification after optimization.

Use testing when deeper regression verification is needed.

Use security when the optimization changes trust, permissions, sensitive data, or security controls.

## Re-Measure

After an optimization, measure again using conditions sufficiently comparable to the baseline.

Compare:

- relevant metric
- variance
- correctness
- resource tradeoffs
- complexity introduced

Possible outcomes:

### Meaningful improvement

Keep the optimization when the benefit justifies its complexity and tradeoffs.

### No meaningful performance improvement

Do not retain additional complexity solely because it was intended as an optimization.

If the change independently improves correctness, maintainability, or architecture, evaluate it on that basis rather than misrepresenting it as a performance improvement.

### Regression

Revert or revise the optimization unless there is an explicitly accepted tradeoff supported by the project's requirements.

Do not hide a performance regression behind an unrelated metric improvement.

## Multiple Optimizations

When practical, evaluate meaningful optimizations independently so their effects can be attributed.

If multiple changes must be combined, acknowledge that the measurement cannot attribute the result to one change unless additional experiments isolate them.

Avoid changing many unrelated performance variables simultaneously.

## Performance Budgets

Use budgets when the project has meaningful performance requirements or recurring regression risk.

Budgets may apply to:

- latency
- throughput
- memory
- bundle size
- frame time
- model size
- inference time
- startup time
- cost

Derive budgets from product, operational, research, or platform requirements.

Do not invent universal performance budgets.

## Regression Protection

When a performance characteristic is important and likely to regress, consider protecting it with:

- benchmark tests
- load tests
- CI budgets
- monitoring
- tracing
- production metrics
- alerts

Guard the metric that matters.

Do not add expensive or flaky performance infrastructure when the regression risk does not justify it.

## Recording Performance Work

For substantial performance investigations, record enough information to prevent future engineers or agents from repeating failed assumptions.

Useful information may include:

- bottleneck
- baseline
- attempted optimization
- resulting measurement
- decision
- important tradeoffs

Use existing project documentation or experiment tracking where appropriate.

Do not create a permanent performance document for every minor optimization.

## Code Review

When reviewing performance-sensitive changes, distinguish:

- confirmed regression
- measured improvement
- likely risk requiring measurement
- theoretical concern
- optional optimization

Do not block ordinary code merely because a theoretically faster implementation exists.

Use code-review alongside this skill for broader correctness and maintainability review.

## Verification

After meaningful performance work, verify:

- the relevant metric was identified
- a baseline exists where practical
- the bottleneck was investigated
- the optimization targets that bottleneck
- measurements are sufficiently comparable
- improvement exceeds meaningful noise where relevant
- correctness remains intact
- resource tradeoffs are understood
- new complexity is justified
- important regression protection is added when warranted

Do not claim a performance improvement without measurement supporting the claim.

## Avoid

Do not:

- optimize without understanding what matters
- optimize solely from intuition when measurement is available
- introduce caching without understanding invalidation
- add indexes without understanding query behavior
- increase concurrency blindly
- assume more connections mean more throughput
- apply browser performance rules to native or backend systems
- apply backend techniques mechanically to ML workloads
- use memoization everywhere
- introduce infrastructure for negligible gains
- sacrifice correctness for benchmark numbers
- claim improvement from incomparable measurements
- treat tiny changes inside measurement noise as proven gains
- retain unnecessary complexity solely because optimization work already took time
- invent universal performance budgets
