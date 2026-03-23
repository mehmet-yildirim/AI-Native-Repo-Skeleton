# CLAUDE.md — Project Instructions for Claude Code

> **CUSTOMIZE THIS FILE.** Replace all `TODO` sections with project-specific information.

---

## Project Overview

**Name:** TODO: Project Name
**Type:** TODO: REST API / Web App / CLI Tool / Library
**Purpose:** TODO: One or two sentences describing what this project does and for whom.

**Primary language(s):** TODO: e.g., TypeScript / Python / Go
**Framework(s):** TODO: e.g., Next.js / FastAPI / Gin
**Runtime:** TODO: e.g., Node.js 22 / Python 3.12 / Go 1.23

---

## Essential Commands

```bash
# Install dependencies
TODO: e.g., bun install

# Run development server
TODO: e.g., bun dev

# Run tests
TODO: e.g., bun test

# Run tests with coverage
TODO: e.g., bun test --coverage

# Lint
TODO: e.g., bun lint

# Format
TODO: e.g., bun format

# Type check
TODO: e.g., bun typecheck

# Build
TODO: e.g., bun build

# Database migrations
TODO: e.g., bun db:migrate
```

---

## Repository Layout

```
TODO: List key directories and files with one-line descriptions.
```

---

## Architecture

TODO: Describe the high-level architecture (3–5 bullet points).

- **Pattern:** TODO
- **Database:** TODO
- **Auth:** TODO
- **External services:** TODO
- **Deployment:** TODO

See `docs/architecture/overview.md` for the full architecture document.

### Architectural Constraints

Prefer **Hexagonal Architecture** (Ports & Adapters). Use the **Adapter pattern** for all external integrations — never call vendor SDKs from domain or application code directly. Apply design patterns to reduce coupling. Full rules: `.cursor/rules/02-architecture.mdc`.

---

## Coding Conventions

### General
- Follow the existing code style — match surrounding code before introducing a new pattern
- Prefer explicit over clever; optimize for readability
- No premature abstractions — abstract only when a pattern repeats 3+ times
- Delete dead code rather than commenting it out

### Naming
- TODO: e.g., camelCase for variables/functions, PascalCase for types/classes
- TODO: e.g., kebab-case for file names

### Imports / Modules
- TODO: e.g., absolute imports via `@/` alias; group: stdlib → third-party → internal

### Error Handling
- TODO: e.g., never swallow errors silently; use typed error classes for domain errors

### Comments
- Write comments to explain *why*, not *what*
- TODO functions must include a linked issue: `// TODO(#123): ...`
- Avoid noise comments that restate the code

---

## Testing Standards

- Every non-trivial function must have unit tests
- Integration tests cover all API endpoints
- Test file naming: TODO: e.g., `*.test.ts` co-located / `tests/test_*.py`
- Use descriptive test names: `it('returns 404 when user does not exist')`
- Tests must not depend on execution order
- Mock external I/O in unit tests; use real dependencies in integration tests

---

## Git & PR Workflow

- Branch naming: `feat/<ticket-id>-short-description` | `fix/...` | `chore/...`
- Commits: conventional commits format (`feat:`, `fix:`, `chore:`, `docs:`, `test:`)
- PRs require at least one reviewer approval before merge
- Squash merge to keep main branch history clean
- Never force-push to `main` or `develop`

### Branch Before Any Code Change

**Before writing or modifying any code — even for a small fix or an inline request — always create and switch to a feature branch first.**

This applies regardless of how the request is made:
- Via a slash command (`/implement`, `/debug`, `/fix`, etc.)
- As a direct instruction ("fix this bug", "change this function", "update this file")
- As an inline edit request in chat

```bash
git branch --show-current           # confirm you are NOT on main or develop
git checkout -b fix/<short-slug>    # for bug fixes
git checkout -b feat/<short-slug>   # for features
git checkout -b chore/<short-slug>  # for config/tooling changes
```

If already on a feature branch (not `main` or `develop`), proceed without creating a new one.

See `.github/PULL_REQUEST_TEMPLATE.md` for the PR checklist.

---

## Do Not

- Do **not** commit secrets, credentials, or `.env` files
- Do **not** use `console.log` / `print` for debugging in production code — use the logger
- Do **not** disable type checking (`@ts-ignore`, `type: ignore`) without a comment explaining why
- Do **not** merge PRs with failing CI
- Do **not** add dependencies without discussing with the team first
- TODO: Add project-specific prohibitions

---

## Domain Glossary

TODO: Define key domain terms so AI understands your business context.

Full glossary: `docs/context/domain-glossary.md`

---

## External References

- TODO: Link to API docs, design docs, Notion/Confluence, Jira, Figma, etc.
- Architecture overview: `docs/architecture/overview.md`
- AI workflow guide: `docs/ai-workflow.md`
