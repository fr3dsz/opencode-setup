---
name: project-structure
description: Use when deciding where a new file goes, naming files, folders, classes, or functions, creating a project or feature folder, cleaning up messy code, or writing comments. Gives the standard feature-first layout for Spring Boot, Angular, Next.js, and Python, naming rules, size limits, and the short-comment rule.
---

# Project Structure and Clean Code

## Rule 0

In an existing project, follow its current layout and the rules in its `AGENTS.md`. Never move files as a side effect of another task. Propose a restructure and wait for approval.

## Spring Boot

```
src/main/java/com/<app>/
  shared/            security, web errors, config used everywhere
  <feature>/         e.g. ordering, catalog, identity
    api/             Controller + request/response records
    domain/          entities, enums
    persistence/     repositories
    service/         business logic
src/main/resources/db/migration/   V<n>__<description>.sql
src/test/java/com/<app>/<feature>/ same structure as main
```

- Small feature (under 8 files): flat folder is fine.
- One public class per file.
- Controller: validate input, call one service method, return a response record.
- Never return an entity from a controller.
- Names: `OrderController`, `OrderService`, `OrderRepository`, `Order`, `CreateOrderRequest`, `OrderResponse`.

## Angular

```
src/app/
  core/                 auth, interceptors, app shell
  shared/ui/            reusable components and pipes
  features/<feature>/
    <feature>.routes.ts
    pages/              orders.page.ts, order-detail.page.ts
    components/         order-status-badge.ts
    data/               order.service.ts, order.models.ts
```

- Every routed screen is in `features/<feature>/pages/`.
- File names: kebab-case. `.page.ts` for routed screens, `.service.ts`, `.models.ts`, `.pipe.ts`.
- Same word order everywhere: `sale-new`, `sale-detail`, `sale-edit` (not `new-sale`).
- Test data lives next to the `*.spec.ts` file, never imported by app code.

## Next.js (App Router)

```
app/                    routes only: page.tsx, layout.tsx, route.ts
components/ui/          generic UI pieces
components/<feature>/   feature components
lib/<feature>/          server logic, data access, validation
```

- Business logic goes in `lib/`, not in `app/` or components.
- File names kebab-case; component names PascalCase.

## Python

```
src/<package>/<feature>/
tests/          mirrors src/
configs/
scripts/        thin entry points only
```

## Naming

- Say what it is: `remainingStock`, not `data2`.
- Booleans: `isActive`, `hasPayment`.
- Functions start with a verb: `calculateTotal`.
- Same concept, same name in database, API, and UI.

## Size Limits (split when you hit them)

- File over 300 lines.
- Function over 40 lines or nested more than 3 levels.
- More than 4 parameters.
- More than 12 files in one folder.

## Comments

- Only explain **why**, never **what**. One or two lines.
- No comment that repeats the code. No banners. No commented-out code. No author or date notes.
- `TODO` only with a next step: `// TODO(#42): replace polling with SSE`.
- If you change code, fix or delete comments that are now wrong.

```java
// Bad: get the user by id
// Good: suspended sellers keep read access until the payout period closes.
```

## Clean Code Checklist

- [ ] Early returns instead of deep nesting.
- [ ] No dead code or unused imports.
- [ ] No duplicated logic you could reuse.
- [ ] Behavior unchanged when cleaning up (tests still pass).
