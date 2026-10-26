---
name: backend-engineering
description: Use when building or changing backend code — REST APIs, controllers, services, business logic, database queries, entities, migrations, transactions, background jobs, external API calls, caching, configuration, Java/Spring Boot, Node, or Python servers.
---

# Backend Engineering

## Before you change anything

1. Read the project's `AGENTS.md`, `README.md`, and `docs/` (API conventions, domain model).
2. Find an existing endpoint or service that does something similar. Copy its style.
3. If the change touches login, permissions, or personal data, also load the `security` skill.

## Where code goes

- **Controller:** read the request, validate it, call one service method, return a response record. No business logic.
- **Service:** business rules and transactions.
- **Repository:** database access only.
- **Request/response records:** the API shape. Never expose entities.
- Follow the `project-structure` skill for folders and names.

## API rules

- [ ] Same URL style, status codes, and error format as existing endpoints.
- [ ] Validate input at the controller (`@Valid` with constraints on the request record).
- [ ] Lists are paginated or bounded.
- [ ] Changing an existing response shape breaks clients. Ask first.

## Data rules

- [ ] Never edit a migration that already ran. Add a new one: `V<next>__<what>.sql`.
- [ ] Use a transaction when several writes must succeed together.
- [ ] Money uses `BigDecimal` (Java) or integer cents, never `double`.
- [ ] Scope every query to the caller's organization or owner.
- [ ] Use parameterized queries; never concatenate input into SQL.

## Errors

- Throw specific exceptions; map them in the global exception handler to a stable error body.
- Never swallow an exception silently.
- Never show stack traces or SQL errors to the client.

## External calls

- Set a timeout.
- Handle failure: retry only if the call is safe to repeat.
- Keys and URLs come from configuration, not code.

## Repeated or double requests

- Payments, orders, and other one-time actions must not run twice if the request is sent twice. Use an idempotency key or a unique constraint.

## Config and secrets

- Values come from `application.yml` with `${ENV_VAR}` placeholders, or environment variables.
- Add new variable names to `.env.example` with placeholder values.

## Verify

- Run the backend tests: `./mvnw test` (Spring), `npm test`, or `pytest`.
- Add a test for the new behavior and one for a failure case.
- Report the command and result.

## Do not

- Put business logic in controllers or entities serialized to JSON.
- Add a new library without asking.
- Change unrelated endpoints.
