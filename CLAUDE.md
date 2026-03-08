# CLAUDE.md — Project Instructions for Claude Code

> **CUSTOMIZE THIS FILE.** Replace all placeholder sections (marked with `TODO`) with
> your project-specific information before starting development.

---

## Project Overview

**Name:** TODO: Project Name
**Type:** TODO: e.g., REST API / Web App / CLI Tool / Library
**Purpose:** TODO: One or two sentences describing what this project does and for whom.

**Primary language(s):** TODO: e.g., TypeScript, Python, Go
**Framework(s):** TODO: e.g., Next.js 14, FastAPI, Gin
**Runtime:** TODO: e.g., Node.js 22, Python 3.12, Go 1.23

---

## Essential Commands

Replace these with the actual commands for this project.

```bash
# Install dependencies
TODO: e.g., bun install / pip install -e ".[dev]" / go mod tidy

# Run development server / REPL
TODO: e.g., bun dev / uvicorn main:app --reload / go run ./cmd/server

# Run tests
TODO: e.g., bun test / pytest / go test ./...

# Run tests with coverage
TODO: e.g., bun test --coverage / pytest --cov / go test -cover ./...

# Lint
TODO: e.g., bun lint / ruff check . / golangci-lint run

# Format
TODO: e.g., bun format / ruff format . / gofmt -w .

# Type check
TODO: e.g., bun typecheck / mypy . / (Go is statically typed)

# Build
TODO: e.g., bun build / python -m build / go build ./...

# Database migrations
TODO: e.g., bun db:migrate / alembic upgrade head / goose up
```

---

## Repository Layout

```
TODO: Add the key directories and files with one-line descriptions.
Example:

src/
├── api/          # HTTP route handlers
├── domain/       # Core business logic (no framework dependencies)
├── infra/        # Database, cache, external service clients
└── main.ts       # Entry point

tests/
├── unit/         # Pure function tests
├── integration/  # Tests with real DB/services
└── e2e/          # End-to-end tests
```

---

## Architecture

TODO: Describe the high-level architecture in 3–5 bullet points.

- **Pattern:** e.g., Hexagonal / Clean / MVC / CQRS
- **Database:** e.g., PostgreSQL with Drizzle ORM
- **Auth:** e.g., JWT via Auth0
- **External services:** e.g., Stripe for payments, SendGrid for email
- **Deployment:** e.g., Docker → AWS ECS via GitHub Actions

See `docs/architecture/overview.md` for the full architecture document.

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
- TODO: e.g., SCREAMING_SNAKE_CASE for constants

### Imports / Modules
- TODO: e.g., Use absolute imports via `@/` alias
- TODO: e.g., Group imports: stdlib → third-party → internal

### Error Handling
- TODO: e.g., Never swallow errors silently
- TODO: e.g., Use typed error classes for domain errors
- TODO: e.g., Return `Result<T, E>` rather than throwing in library code

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
- Mock external I/O (DB, HTTP, file system) in unit tests; use real dependencies in integration tests

---

## Git & PR Workflow

- Branch naming: `feat/<ticket-id>-short-description` | `fix/...` | `chore/...`
- Commits: conventional commits format (`feat:`, `fix:`, `chore:`, `docs:`, `test:`)
- PRs require at least one reviewer approval before merge
- Squash merge to keep main branch history clean
- Never force-push to `main` or `develop`

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

| Term | Meaning |
|------|---------|
| TODO | TODO |

Full glossary: `docs/context/domain-glossary.md`

---

## External References

- TODO: Link to API docs, design docs, Notion/Confluence, Jira, Figma, etc.
- Architecture overview: `docs/architecture/overview.md`
- AI workflow guide: `docs/ai-workflow.md`
