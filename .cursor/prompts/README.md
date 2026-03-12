# Cursor Prompt Files

These files are the Cursor equivalent of Claude Code's `.claude/commands/` slash commands.
They encode structured workflows for the full AI-native development lifecycle.

## How to Use

In Cursor Chat or Composer, reference a prompt file with `@` and then add your specific request:

```
@.cursor/prompts/requirements.md

Add JWT-based authentication to the login endpoint.
```

Cursor injects the full prompt template into the conversation. Your text after the `@` reference
becomes the task input — equivalent to Claude Code's `$ARGUMENTS`.

## Available Prompts

### Human-Guided Workflows

| File | Equivalent | When to use |
|------|-----------|------------|
| `requirements.md` | `/requirements` | Before starting any feature — decompose raw requirements |
| `architect.md` | `/architect` | Design before coding — for any task > 50 lines |
| `implement.md` | `/implement` | Structured bottom-up implementation with self-review |
| `qa.md` | `/qa` | Full quality cycle before opening a PR |
| `review.md` | `/review` | Code review against project standards + OWASP |
| `test.md` | `/test` | Generate comprehensive tests for a function or module |
| `debug.md` | `/debug` | Systematic bug diagnosis: hypotheses → fix → prevention |
| `deploy.md` | `/deploy` | Pre-deploy checklist, execution, and monitoring plan |
| `migrate.md` | `/migrate` | Safe DB migration with Expand-Contract pattern |
| `sprint.md` | `/sprint` | Sprint planning: capacity, backlog selection, risk register |
| `docs.md` | `/docs` | Generate API docs, architecture docs, or user guides |
| `standup.md` | `/standup` | Daily standup summary from git history |
| `security-audit.md` | `/security-audit` | Full OWASP + CVE + secret scan |

### Autonomous Agent Workflows

| File | Equivalent | Purpose |
|------|-----------|---------|
| `triage.md` | `/triage` | Domain relevance scoring for an issue |
| `groom.md` | `/groom` | Batch backlog processing through triage + requirements |
| `loop.md` | `/loop` | Full autonomous dev loop for a single task |
| `escalate.md` | `/escalate` | Structured human notification when agent is blocked |

## Difference from Claude Code Commands

| | Claude Code | Cursor |
|-|------------|--------|
| Invocation | `/requirements Add auth` | `@.cursor/prompts/requirements.md` + "Add auth" |
| Input variable | `$ARGUMENTS` | Your message text after the `@` reference |
| Context loading | Explicit "read CLAUDE.md" steps | Automatic via `.cursor/rules/` |
| Tool execution | Runs bash commands directly | Describe commands; run in integrated terminal |

## Tips

- Combine with `@CLAUDE.md` or specific source files for richer context:
  ```
  @.cursor/prompts/review.md @src/api/orders.ts
  ```
- For the `standup.md` prompt, first run the git command in the terminal and paste the output.
- Autonomous agent prompts (`triage`, `groom`, `loop`, `escalate`) require `agent.config.yaml`
  to be configured and MCP servers to be active.
