# Coding Standards

## Core Principles
- Readability over cleverness — optimize for the next developer
- Explicit over implicit — make dependencies, data flow, and side effects obvious
- No premature abstractions — extract when a pattern repeats 3+ times
- Delete dead code — never comment it out

## Naming
- Booleans/predicate functions: prefix with `is`, `has`, `can`, `should`
- Functions returning values: noun or noun phrase
- Functions with side effects: verb phrase
- Constants: SCREAMING_SNAKE_CASE
- No single-letter names except loop counters

## Functions
- One thing per function; ≤ 30 lines; ≤ 3 nesting levels
- Max 4 parameters — beyond that, use an options object
- Early returns to reduce nesting — avoid `else` after `return`
- Prefer pure functions with no hidden side effects

## Error Handling
- Never silently swallow errors
- Use typed errors for domain errors
- Distinguish recoverable errors (return values) from fatal errors (throw)
- Handle the error path before the happy path

## Comments
- Explain *why*, not *what*
- TODO comments require a linked issue: `// TODO(#123): ...`
- Public APIs must have doc comments

## Testing (always generate tests for new logic)
- Unit test every non-trivial function
- Structure: Arrange → Act → Assert
- Test names: `'returns X when Y'` format
- One assertion concept per test
