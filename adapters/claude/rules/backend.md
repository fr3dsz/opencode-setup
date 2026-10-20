---
paths:
  - "**/*.{java,kt,go,rs,cs,rb,php}"
  - "**/{api,server,services,routes,controllers,repositories}/**"
  - "**/{migrations,db/migrate}/**"
  - "**/*.sql"
---

# Backend files

- Use the `backend-engineering` skill; add `security` for auth, permissions, secrets, or untrusted input.
- Never edit a shipped migration; add a new one.
- Validate at trust boundaries and keep API error shapes stable.
