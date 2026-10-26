---
name: frontend-engineering
description: Use when building or changing user interface code — pages, components, forms, routing, state, API calls from the client, loading and error states, accessibility, responsive layout, Angular, React, Next.js, Vue, CSS or SCSS.
---

# Frontend Engineering

## Before you change anything

1. Read `AGENTS.md`, `README.md`, and any design doc (`DESIGN.md`).
2. Find a similar page or component in the project. Copy its patterns: state handling, services, styling.
3. Follow the `project-structure` skill for where files go.

## Components

- One component, one job. Split when a file passes ~300 lines.
- Presentational components take inputs and emit events. Data loading lives in a service or page.
- No business rules in templates. Compute values in the component or service.
- Reuse existing shared components before making new ones.

## Every screen handles four states

- [ ] Loading
- [ ] Empty (no data)
- [ ] Error (with a clear message and a retry when it makes sense)
- [ ] Success

## Forms

- [ ] Labels on every field.
- [ ] Show validation messages next to the field.
- [ ] Disable the submit button while sending; prevent double submits.
- [ ] The server validates again; client validation is only for user experience.

## Data and API

- Call the API through a service, not directly from templates.
- Use the project's existing HTTP client and error interceptor.
- Never store login tokens in `localStorage`.
- Never put secrets in frontend code or environment files that ship to the browser.

## Accessibility

- [ ] Buttons are `<button>`, links are `<a>`.
- [ ] Images have `alt` text.
- [ ] Everything works with the keyboard (Tab, Enter, Escape).
- [ ] Text has enough contrast.

## Angular specifics

- Standalone components and signals, following the project's existing style.
- Lazy-load feature routes.
- Avoid `bypassSecurityTrust*` and direct DOM writes.

## Next.js and React specifics

- Server components by default; `'use client'` only when needed.
- Never use `dangerouslySetInnerHTML` with user or CMS data.

## Verify

- Run the build and tests (`npm run build`, `npm test`, or the project's command).
- Check the page in the browser with the `browser-testing` skill: console clean, network OK, all four states.
