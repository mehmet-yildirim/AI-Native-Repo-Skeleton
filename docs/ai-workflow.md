# AI-Native Development Workflow

This document describes how to work effectively with AI tools in this project.
Following this workflow produces faster, higher-quality results.

## The AI-Native Loop

```
1. CONTEXT  → Give AI the right information before asking for code
2. DESIGN   → Have AI design before it codes (/architect)
3. IMPLEMENT → Implement with AI assistance in small steps
4. REVIEW   → Review AI output critically (/review)
5. TEST     → Generate and run tests (/test)
6. DOCUMENT → Update docs while context is fresh (/docs)
```

## Tool Overview

| Tool | Best for | Key config |
|------|----------|-----------|
| **Claude Code** | Complex agentic tasks, multi-file edits, CLI | `CLAUDE.md`, `.claude/commands/` |
| **Cursor** | In-editor generation, chat, autocomplete | `.cursor/rules/` |
| **Continue** | Inline edits, chat, autocomplete in any IDE | `.continue/config.yaml` |

## Step 1: Provide Context First

AI tools work best when they understand your project. This skeleton provides context via:

- **`CLAUDE.md`** — Project overview, commands, conventions (loaded automatically by Claude Code)
- **`.cursor/rules/`** — Persistent rules loaded for every Cursor interaction
- **`.continue/rules/`** — Rules included in every Continue request
- **`docs/context/`** — Deeper project context you can reference with `@docs`

**Before starting any significant task**, verify the AI has context by asking:
> "What do you know about this project's architecture and coding standards?"

## Step 2: Design Before Coding

For any feature larger than ~50 lines of code, run `/architect` first:

```
/architect Add a password reset flow with email verification
```

Review the design output critically:
- Does the approach fit our architecture?
- Are all edge cases identified?
- Does the implementation checklist make sense?

Only proceed to implementation after approving the design.

## Step 3: Implement in Small Steps

**Divide the implementation checklist into individual steps**, each producing a single, testable commit.

Do NOT ask AI to implement an entire feature in one message. Instead:

```
Step 1: "Create the PasswordReset entity and repository interface"
Step 2: "Implement the RequestPasswordReset use case"
Step 3: "Add the POST /auth/password-reset endpoint"
Step 4: "Write unit tests for the RequestPasswordReset use case"
Step 5: "Write integration tests for the endpoint"
```

After each step: **read and understand the generated code**. Do not accept code you don't understand.

## Step 4: Review AI Output

After AI generates code, use `/review` to check it:

```
/review
```

Or review a specific file:
```
/review src/auth/password-reset.service.ts
```

**Never commit AI-generated code without:**
1. Reading every line of the diff
2. Running the linter and type checker
3. Running the tests

## Step 5: Generate Tests

If tests weren't generated during implementation:

```
/test src/auth/password-reset.service.ts
```

Verify the generated tests:
- Cover happy path, edge cases, and error cases
- Are not trivial or testing implementation details
- Actually fail when you introduce a bug

## Step 6: Update Documentation

After completing a feature:

```
/docs src/auth/password-reset.service.ts
```

Also update:
- `CLAUDE.md` if new commands, conventions, or architectural patterns were introduced
- `docs/architecture/decisions/` if a significant design decision was made
- `docs/context/` if new domain concepts were added

## Effective Prompt Patterns

### Providing context
```
Given that we use hexagonal architecture with a domain layer that has no dependencies on
infrastructure, and we use Drizzle ORM for database access — implement X.
```

### Asking for options
```
What are three different approaches to implementing X? For each, describe the trade-offs
in terms of complexity, performance, and testability. Recommend one with justification.
```

### Requesting minimal changes
```
Make the smallest possible change to fix the failing test. Do not refactor surrounding code.
```

### Debugging with context
```
This test is failing with error: [paste error]. The function under test is [paste code].
What is the root cause? Show me the minimal fix.
```

### Keeping AI on track
```
We decided in the design step to use [approach]. Stick to that approach.
Do not introduce [pattern we rejected].
```

## Red Flags to Watch For

Stop and review carefully when AI-generated code:

- Introduces a new dependency you didn't discuss
- Adds an abstraction layer that seems unnecessary
- Uses a pattern inconsistent with the rest of the codebase
- Skips error handling for a code path
- Adds complexity "for future extensibility"
- Modifies files you didn't ask it to touch
- Has TODO comments that weren't discussed

## Effective Use of Custom Commands

| Command | When to use |
|---------|------------|
| `/architect <feature>` | Before implementing anything > 50 lines |
| `/review` | After every significant implementation |
| `/test <file>` | After implementing a module, before committing |
| `/debug <issue>` | When a bug isn't immediately obvious |
| `/docs <file>` | After completing a module |
| `/standup` | At start of day to summarize yesterday's work |

## Context Window Management

For long sessions, AI tools may lose context. Signs of this:
- AI suggests solutions inconsistent with your architecture
- AI contradicts earlier decisions
- AI asks for information it already has

**Reset strategy:**
1. Start a new session
2. Reference key files: `@CLAUDE.md`, `@docs/architecture/overview.md`
3. Briefly summarize the current task
4. Continue from where you left off

## Team Workflow

### Code Review
- PRs should note which parts of the code were AI-generated
- Reviewers should apply the same standards to AI-generated code as human-written code
- Reviewers run `/review` on substantial AI-generated sections

### Knowledge Sharing
- When you discover an effective prompt pattern for this project, document it here
- When AI makes a systematic mistake, add a rule to the relevant `.cursor/rules/` or `.continue/rules/` file
- When a new domain concept is introduced, update `docs/context/domain-glossary.md`
