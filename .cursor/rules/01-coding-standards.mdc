---
description: Coding standards, style, naming conventions, and patterns. Apply when writing or reviewing code.
globs:
alwaysApply: true
---

# Coding Standards

## Core Principles

- **Readability over cleverness.** Code is read far more often than it is written. Optimize for the next developer (including future you).
- **Explicit over implicit.** Avoid magic. Make dependencies, data flow, and side effects obvious.
- **Minimal surface area.** Only expose what consumers need. Keep internals private.
- **No premature abstractions.** Extract a pattern when it appears the third time, not the first.
- **Delete dead code.** Never comment out code — use version control.

## Naming Conventions

### Universally applicable
- Names should describe *what* something is or does, not *how* it works
- Boolean variables and functions: prefix with `is`, `has`, `can`, `should`
- Functions that return a value: use a noun or noun phrase (`getUserById`)
- Functions with side effects: use a verb (`sendEmail`, `updateRecord`)
- Constants: SCREAMING_SNAKE_CASE (`MAX_RETRY_COUNT`)
- Avoid single-letter names except loop counters (`i`, `j`) and well-known conventions (`e` for error)

## File & Module Organization

- One concept per file; file name matches the primary export
- Group related files in feature/domain folders, not layer folders (prefer `features/auth/` over `controllers/`)
- Index files (`index.ts`) only re-export — no business logic
- Import order: stdlib → third-party → internal (enforced by linter)

## Functions & Methods

- Functions should do one thing. If you need "and" to describe it, split it.
- Aim for ≤ 30 lines per function; ≤ 3 levels of nesting
- Prefer pure functions — no hidden state or side effects
- Max 4 parameters; beyond that, use an options object/struct
- Early returns to reduce nesting — avoid `else` after `return`

```typescript
// Preferred: early return
function processUser(user: User | null): Result {
  if (!user) return err('User not found');
  if (!user.isActive) return err('User is inactive');
  return ok(transform(user));
}
```

## Error Handling

- **Never silently swallow errors.** Log or propagate every error.
- **Use typed errors** for domain errors; use generic errors only at system boundaries
- **Distinguish recoverable vs. fatal errors** — recoverable errors return values, fatal errors throw
- Do not use exceptions for control flow
- Always handle the error path before the happy path

```typescript
// Preferred: typed result
async function getUser(id: string): Promise<Result<User, 'NOT_FOUND' | 'DB_ERROR'>> { ... }
```

## Comments & Documentation

- Write comments to explain **why**, not **what** (the code explains what)
- TODO comments must reference an issue: `// TODO(#123): Remove after migration`
- Public API functions/classes must have doc comments (JSDoc, docstrings, GoDoc)
- Avoid noise comments: `// increment i` above `i++` adds zero value

## Magic Numbers & Strings

- No magic numbers or strings in logic — define named constants
- Configuration belongs in config files or environment variables, not hardcoded

## Async / Concurrency

- Prefer `async/await` over raw Promises/callbacks
- Always `await` Promises — never fire-and-forget unless explicitly intentional (and comment why)
- Handle concurrent operations with `Promise.all` / `Promise.allSettled` where appropriate
