# Cursor Slash Commands

Cursor reads slash commands directly from `.claude/commands/` — no separate Cursor prompt files are needed. All commands (`/implement`, `/debug`, `/qa`, etc.) are defined once and work in both Claude Code and Cursor.

## How to use

Type `/` in Cursor Chat or Composer to see the full command list, or invoke directly:

```
/implement Add JWT authentication to the login endpoint
/debug     NullPointerException in OrderService.checkout()
/qa        Run full quality cycle before opening PR
```

## Available commands

See [`.claude/commands/`](../../.claude/commands/) for the full list. All commands available in Claude Code are equally available in Cursor.

## Context loading

Cursor loads project context through `.cursor/rules/` (always-on and on-demand rules). Commands reference `CLAUDE.md` for project conventions — ensure it is filled in before running any command.
