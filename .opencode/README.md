# OpenCode integration

Initium slash commands live in [`.claude/commands/`](../.claude/commands/). The same prompt
files are mirrored here for [OpenCode](https://opencode.ai/) (`/.opencode/commands/`).

## Usage

In the OpenCode TUI, run any Initium command by name, for example:

- `/help` — command reference and workflow guidance
- `/goal <primary objective>` — pursue one goal until Definition of Done is met
- `/requirements`, `/architect`, `/implement`, `/qa`, … — full agentic workflow

Project instructions are loaded from [`opencode.json`](../opencode.json) (`CLAUDE.md` and
`.cursor/rules/`).

## Keeping commands in sync

After editing `.claude/commands/*.md`, refresh OpenCode copies:

```bash
bash .initium/scripts/sync-opencode-commands.sh
```

CI and `validate.sh` can use `--check` to ensure mirrors are up to date.
