---
name: performance
description: Use when something is measurably slow or uses too much memory or CPU — slow pages, slow API calls, slow queries, large bundles, slow training or inference — or when the user asks to optimize. Measure first, change one thing, measure again.
---

# Performance

Never optimize without a number to compare.

## Steps

1. **Goal.** What is slow, and what is fast enough? (e.g. "orders page loads in under 1s")
2. **Baseline.** Measure now, the same way you will measure later. Write the number down.
3. **Find the bottleneck.** Profile; do not guess.
   - Browser: `browser-testing` skill, performance trace.
   - Backend: logs with timings, SQL query log, profiler.
   - Database: `EXPLAIN` the slow query.
4. **Change one thing.**
5. **Measure again** the same way. Keep the change only if it is clearly faster and still correct.
6. **Report** before and after numbers.

## Common causes (check these first)

- Database: N+1 queries (a query inside a loop), missing index, loading whole tables, no pagination.
- Backend: repeated work that could be done once, slow external calls without timeout.
- Frontend: huge bundles, unoptimized images, rendering long lists without paging, repeated API calls.
- ML: data loading on the main thread, wrong batch size, running on CPU by mistake.

## Rules

- [ ] Correctness first: tests still pass after the change.
- [ ] Remove unnecessary work before adding caches.
- [ ] A cache needs a clear rule for when it is refreshed.
- [ ] Do not make code much harder to read for a tiny gain.
