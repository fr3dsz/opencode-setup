---
name: security
description: Use for anything touching login, sessions, passwords, permissions, roles, secrets, API keys, personal or customer data, payments, file uploads, webhooks, external APIs, CORS, or AI/LLM features, and for "is this secure" or "how does data flow" questions. Map the data flow, apply the always/ask/never rules, and verify.
---

# Security

## Step 1: Map the data flow

For each piece of data the change handles, fill this in (in your plan, and in `docs/security.md` if the project has one):

| Question | Answer |
|---|---|
| Where does it come in? | endpoint, form, webhook, file |
| Who controls it? | anonymous user, logged-in user, other system |
| Where is it checked? | validation class or schema |
| Who is allowed to see or change it? | rule and where it is enforced |
| Where is it stored? | table, file, cookie |
| Where does it go out? | API response, logs, emails, third parties |

Label each field: **public**, **internal** (business data), **personal** (name, phone, address), or **sensitive** (passwords, tokens, payment data).

If you cannot fill the table, ask the user.

## Step 2: Always

- [ ] Validate every input on the server (type, length, allowed values).
- [ ] Use parameterized queries or the ORM. Never build SQL or shell commands with string concatenation.
- [ ] Check permission on the server for the specific record: does this user or organization own it?
- [ ] Get the user, role, and organization from the server session, never from the request body.
- [ ] Return response objects with only the needed fields. Never return entities or password hashes.
- [ ] Error responses show a short safe message. Details go to server logs.
- [ ] Hash passwords with the framework's encoder (bcrypt or argon2).
- [ ] Secrets come from environment variables. Only `.env.example` with placeholders is committed.

## Step 3: Ask the user first

- Changing login, sessions, roles, or permissions.
- Storing a new kind of personal or sensitive data.
- Adding an external API, webhook, or sending data to a third party (including AI services).
- Changing CORS, security headers, or rate limits.
- Adding file uploads.
- Turning off or weakening any existing check.

## Step 4: Never

- Commit secrets, or log passwords, tokens, or card numbers.
- Trust the frontend for permissions (hidden buttons and route guards are not security).
- Store login tokens in `localStorage` or `sessionStorage`.
- Use `eval`, `innerHTML`, `bypassSecurityTrust*`, or `dangerouslySetInnerHTML` with user data.
- Show stack traces or SQL errors to users.
- Write your own encryption or password hashing.
- Run `npm audit fix --force`.

## Specific Cases

- **Uploads:** allow only listed file types, limit size, generate the stored file name, store outside public folders.
- **Webhooks:** verify the provider signature before doing anything.
- **Fetching a URL the user gave:** allow only listed hosts; block `localhost` and private IPs.
- **Deleting files from a path in data:** make sure the real path is inside the allowed folder.
- **Login and password reset:** rate limit; same error message whether or not the account exists.
- **AI features:** treat model output like user input. Never pass it straight to SQL, a shell, HTML, or file paths.

## Stack Notes

- **Spring Boot:** `@Valid` on request records, `findByIdAndOrganizationId(...)` style lookups, `PasswordEncoder` bean, secrets as `${ENV_VAR}` in `application.yml`, keep CSRF on for browser sessions.
- **Angular:** no secrets in `environment.ts`; guards are UX only; use the backend's session cookie.
- **Next.js:** `NEXT_PUBLIC_` values are visible to everyone; server actions and route handlers must validate input and check permission themselves.

## Step 5: Verify

- [ ] Test: another user's or organization's record returns 403 or 404.
- [ ] Test: bad input returns 400 without internal details.
- [ ] Sensitive fields are not in responses or logs.
- [ ] Staged diff has no secrets: `git diff --cached | grep -iE "password|secret|api[_-]?key|token"`
- [ ] Say exactly what you checked. Do not claim "secure" without a check.
