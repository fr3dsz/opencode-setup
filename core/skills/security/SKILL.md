---
name: security
description: Use when a task has meaningful security implications, including authentication, authorization, permissions, secrets, credentials, sensitive or personal data, payments, file uploads, webhooks, external integrations, untrusted execution, server-side URL fetching, destructive filesystem operations, dependency or supply-chain risk, AI/LLM tool access, or an explicit security review. Focus on threat modeling, trust boundaries, least privilege, secure data handling, attack prevention, and evidence-based hardening. Use alongside frontend-engineering, backend-engineering, debugging, testing, or other domain skills when security is a cross-cutting concern.
---

# Security

Identify and reduce realistic security risks without imposing unnecessary controls or stack-specific assumptions.

Security is a cross-cutting engineering concern.

Use this skill when security materially affects the correctness or safety of the task. Ordinary implementation concerns should remain with the relevant engineering skill unless deeper security reasoning is needed.

## Core Principles

- Understand what must be protected.
- Identify who or what is trusted.
- Treat trust boundaries explicitly.
- Prefer secure defaults.
- Apply least privilege.
- Enforce authorization at trustworthy boundaries.
- Treat external and independently controlled data as untrusted.
- Keep secrets out of source code, logs, client bundles, and other unintended surfaces.
- Consider abuse cases in addition to intended use cases.
- Prefer established security mechanisms over custom security inventions.
- Match controls to actual risk rather than applying a checklist mechanically.
- Never weaken a security control merely to make implementation easier without understanding the consequence.

## Security Discovery

Before substantial security-sensitive work, understand the relevant:

- system architecture
- trust boundaries
- users and identities
- roles and permissions
- sensitive assets
- entry points
- external integrations
- data stores
- secrets
- deployment environment
- client/server boundaries
- background workers
- third-party dependencies
- existing security controls

Read relevant project documentation first.

If `.codegraph/` exists, use CodeGraph to understand relevant authentication paths, authorization checks, data flows, external calls, sensitive operations, and dependencies before broad manual exploration.

Do not assume a security mechanism exists merely because the framework commonly provides one.

## Threat Modeling

For security-sensitive changes, perform a lightweight threat assessment appropriate to the risk.

Identify:

1. What are we protecting?
2. Who or what can interact with it?
3. Where does untrusted data enter?
4. What privileged actions are possible?
5. What happens if the feature is abused?
6. What happens if a dependency or external system misbehaves?
7. What controls already exist?

STRIDE can be used as a reasoning lens when useful:

- Spoofing
- Tampering
- Repudiation
- Information disclosure
- Denial of service
- Elevation of privilege

Do not turn threat modeling into unnecessary ceremony for trivial changes.

## Trust Boundaries

Trust depends on who controls a value, not merely where the value arrived from.

Potentially untrusted sources include:

- HTTP requests
- forms
- uploaded files
- URLs
- webhooks
- third-party APIs
- queue messages
- imported data
- environment or job payloads written by another system
- shared filesystem content
- user-controlled filenames or paths
- AI/LLM output
- data from independently deployed services

Validate or constrain data according to the risk at the boundary.

Do not assume that data is safe merely because it came through an internal-looking channel.

## Authentication

Authentication establishes identity.

When authentication is involved:

- use established and maintained mechanisms
- protect credentials and session material
- handle expiration and revocation appropriately
- consider brute-force and credential-abuse risks
- avoid leaking authentication state or secrets
- follow platform and framework security guidance

Do not invent:

- password hashing algorithms
- encryption schemes
- token formats
- session protocols
- cryptographic primitives

Use appropriate established libraries and platform capabilities.

Do not hardcode one authentication architecture globally. Cookies, tokens, platform credentials, passkeys, OAuth/OIDC, service identities, and other mechanisms have different appropriate uses.

## Authorization

Authentication does not imply authorization.

For protected operations, determine whether the authenticated identity is allowed to perform the specific action on the specific resource.

Prefer server-side or otherwise trustworthy enforcement.

Do not rely on:

- hidden buttons
- disabled controls
- client-side route guards
- client-provided roles
- UI state

as the actual authorization boundary.

Consider:

- ownership
- roles
- permissions
- tenant boundaries
- resource relationships
- administrative operations
- privilege escalation

Apply least privilege.

## Input and Injection Safety

When untrusted input influences interpreters or structured operations, prevent injection.

Relevant surfaces include:

- SQL and database queries
- shell commands
- HTML
- templates
- file paths
- regular expressions
- query languages
- serialization formats
- dynamic code execution

Prefer:

- parameterized operations
- structured APIs
- allowlists where appropriate
- schema validation
- output encoding
- framework escaping

Avoid constructing executable commands or queries through unsafe string concatenation.

Validation alone is not always sufficient. Use the safe interface provided by the target system.

## Output Safety

Treat output as context-dependent.

Data that is safe as plain text may be unsafe when inserted into:

- HTML
- JavaScript
- SQL
- shell commands
- URLs
- file paths
- templates

Use the correct encoding or safe API for the destination context.

Do not bypass framework escaping without a concrete and reviewed need.

## Secrets and Credentials

Secrets may include:

- API keys
- passwords
- private keys
- access tokens
- refresh tokens
- signing secrets
- database credentials
- service credentials

Do not:

- hardcode secrets
- commit secrets
- expose server secrets to client applications
- include secrets in examples that may be committed
- log secrets
- return secrets in error responses

Use the project's established secret-management mechanism.

If a secret may have been exposed, treat rotation or revocation as part of the response. Removing the secret from the current source alone does not invalidate copies that may already exist.

## Sensitive and Personal Data

Collect and retain only data the system actually needs.

For sensitive or personal information, consider:

- purpose
- access
- storage
- transmission
- retention
- deletion
- logging
- backups
- analytics
- external sharing
- regulatory or contractual requirements

Do not claim legal compliance merely because technical controls exist.

Privacy requirements depend on jurisdiction, organization, data type, and actual processing behavior.

When compliance matters, distinguish technical engineering guidance from legal conclusions.

## Data Exposure

Return only data the consumer needs.

Be careful with:

- password hashes
- internal identifiers
- tokens
- private metadata
- administrative fields
- cross-tenant information
- debug information
- stack traces
- database errors

Use explicit response models or field selection when appropriate.

Do not assume that because a field is stored together with public data it should be returned with it.

## Web and API Security

For web or API systems, consider where relevant:

- authentication
- authorization
- CSRF
- XSS
- injection
- CORS
- security headers
- request size limits
- rate limiting
- session handling
- caching of sensitive responses
- error exposure

Use framework and deployment guidance appropriate to the actual stack.

Do not mechanically apply browser-specific controls to native, server-to-server, CLI, or non-web systems.

## Server-Side URL Fetching and SSRF

When a server fetches a location influenced by untrusted input, consider SSRF.

Examples include:

- URL imports
- image proxies
- link previews
- callbacks
- webhook testing
- document fetchers

Depending on the use case, controls may include:

- allowed schemes
- host allowlists
- DNS/IP validation
- private/reserved network restrictions
- redirect restrictions
- network egress controls
- request filtering

Be aware of DNS rebinding and check/use races in high-risk systems.

Do not assume URL syntax validation alone prevents SSRF.

## File Uploads

For uploaded files, consider:

- size limits
- type validation
- content validation where necessary
- storage location
- generated filenames
- executable content
- path traversal
- decompression bombs
- malware scanning where risk justifies it
- public accessibility
- retention

Do not trust filename extensions or client-provided MIME types as strong evidence of file content.

## Filesystem Safety

Treat paths influenced by another user, process, service, or job as potentially untrusted.

For destructive operations such as:

- delete
- overwrite
- move
- recursive cleanup

verify that the resolved target is actually within the intended scope.

Consider:

- path traversal
- symlinks
- ownership
- allowlisted roots
- race conditions
- accidental root-directory operations

Do not use weak string-prefix checks as proof that a resolved filesystem target is safe.

## External Integrations and Webhooks

Treat external services as separate trust and failure domains.

For integrations, consider:

- credential storage
- transport security
- signature verification
- replay protection
- input validation
- authorization
- rate limits
- timeouts
- retries
- idempotency
- data exposure

For webhooks, verify authenticity using the provider's supported mechanism when available.

Do not trust a webhook merely because it reached the expected endpoint.

## Payments and High-Impact Side Effects

Operations involving money, inventory, provisioning, account privileges, or other high-impact effects deserve additional scrutiny.

Consider:

- authorization
- integrity
- idempotency
- replay
- duplicate execution
- concurrency
- provider verification
- unknown outcomes
- auditability

Do not infer successful payment or other irreversible state solely from client-side state.

Use the backend-engineering skill alongside this skill for transaction and idempotency architecture.

## Dependency and Supply-Chain Security

When adding or updating dependencies:

- use the project's actual package manager
- respect the authoritative lockfile
- inspect unexpected dependency or lockfile changes
- consider package ownership and maintenance
- consider known vulnerabilities
- consider install/build scripts
- prefer established dependencies when security impact is significant

Package-manager audits identify known advisories. They do not prove a package is safe.

Do not automatically apply destructive or major-version audit remediation without understanding the resulting changes.

Do not assume a dependency is trustworthy solely because it is popular.

## AI and LLM Security

Treat model input and output as part of the system's trust model.

LLM output is untrusted data.

Do not directly execute model output as:

- shell commands
- SQL
- source code
- dynamic expressions
- HTML
- filesystem paths
- privileged tool arguments

without appropriate validation, constraints, or user authorization.

Assume untrusted content provided to a model can attempt prompt injection.

System prompts are not authorization boundaries.

Enforce permissions in deterministic application code.

Protect:

- secrets
- cross-user data
- system credentials
- privileged tools
- private retrieval data

from unnecessary model context.

For agentic systems:

- grant minimum required tool permissions
- validate tool arguments
- constrain accessible resources
- require appropriate confirmation for destructive or irreversible actions
- bound loops, requests, and resource consumption

For retrieval systems, preserve tenant and access boundaries when indexing and retrieving data.

## Logging and Auditability

Security-relevant events may require logging, but logs can also become a data leak.

Do not log:

- passwords
- raw authentication tokens
- secret keys
- unnecessary sensitive data

Where appropriate, preserve enough information to investigate:

- authentication failures
- permission failures
- privileged operations
- security-sensitive configuration changes
- suspicious activity

Use the project's established logging and observability approach.

## Denial of Service and Resource Abuse

When externally controlled input can consume significant resources, consider limits.

Potential controls include:

- request limits
- payload size limits
- timeouts
- concurrency limits
- rate limits
- quotas
- pagination
- bounded recursion or loops

Use controls appropriate to the deployment architecture.

For distributed or serverless systems, verify whether a local in-memory limiter actually provides the intended protection.

## Security Verification

Verify the risks relevant to the actual change.

Depending on the task, this may include:

- authentication tests
- authorization tests
- tenant-isolation tests
- invalid-input tests
- injection attempts
- upload validation
- webhook verification
- replay attempts
- dependency audits
- secret scanning
- security headers
- CORS behavior
- SSRF protections
- rate limiting
- sensitive-data exposure
- LLM tool restrictions

Use the testing skill when implementing or expanding security regression tests.

Do not claim a security property was verified unless it was actually tested, inspected, or otherwise evidenced.

## Security Reviews

When performing a security review:

1. Identify assets and trust boundaries.
2. Identify realistic attack paths.
3. Inspect existing controls.
4. Prioritize findings by impact and exploitability.
5. Distinguish confirmed vulnerabilities from potential concerns.
6. Recommend the smallest effective mitigation.
7. Verify the mitigation where possible.

Avoid flooding the user with theoretical findings that are not relevant to the actual system.

## Documentation

Update relevant documentation when security changes affect documented:

- authentication
- authorization
- permissions
- trust boundaries
- sensitive-data handling
- integrations
- configuration
- security-sensitive workflows

Do not expose secrets or unnecessary exploitable detail in documentation.

## Avoid

Do not:

- treat client-side checks as authorization
- invent cryptography
- hardcode secrets
- log credentials
- trust external data automatically
- expose internal errors unnecessarily
- concatenate untrusted data into executable contexts
- assume HTTPS alone makes an integration trustworthy
- assume dependency audits prove supply-chain safety
- disable security controls merely to remove an error
- claim legal compliance from a code review alone
- apply web-specific controls blindly to non-web platforms
- turn every minor implementation task into a heavyweight security audit
