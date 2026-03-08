# Developer Onboarding Guide

Welcome to the project. This guide gets you from zero to productive as quickly as possible.

## Prerequisites

Before you start, make sure you have:

- [ ] TODO: List required tools (e.g., Node.js 22+, Docker, etc.)
- [ ] TODO: Access to required services (e.g., AWS account, database, secrets)
- [ ] Git configured with your work email
- [ ] An AI coding tool set up (Cursor, VS Code with Continue, or Claude Code)

## Initial Setup

```bash
# 1. Clone the repository
git clone <repo-url>
cd <project-name>

# 2. Run the setup script
./scripts/setup.sh

# 3. Copy environment file and fill in values
cp .env.example .env
# Edit .env with your local values

# 4. TODO: Start local dependencies
# e.g., docker compose up -d

# 5. TODO: Install dependencies
# e.g., bun install

# 6. TODO: Run database migrations
# e.g., bun db:migrate

# 7. Verify everything works
# TODO: e.g., bun test
# TODO: e.g., bun dev → open http://localhost:3000
```

## Understanding the Project

Read these documents in order:

1. **`docs/context/project-brief.md`** — What this project does and for whom
2. **`docs/context/tech-stack.md`** — Technology choices and why
3. **`docs/architecture/overview.md`** — How the system is structured
4. **`CLAUDE.md`** — Coding conventions and key commands
5. **`docs/context/domain-glossary.md`** — Business terminology

## Setting Up AI Tools

### Claude Code
```bash
# Install Claude Code (if not already installed)
npm install -g @anthropic-ai/claude-code

# In the project directory, Claude Code automatically loads CLAUDE.md
claude

# Available custom commands (type /):
# /architect — design a feature before implementing
# /review    — review code changes
# /test      — generate tests
# /debug     — systematic debugging
# /docs      — generate documentation
# /standup   — summarize recent work
```

### Cursor
1. Open the project folder in Cursor
2. Rules in `.cursor/rules/` are loaded automatically
3. Enable MCP servers in `.cursor/mcp.json` if desired
4. Add your `ANTHROPIC_API_KEY` to Cursor settings

### Continue (VS Code / JetBrains)
1. Install the Continue extension
2. Continue will detect `.continue/config.yaml` automatically
3. Add your `ANTHROPIC_API_KEY` to the config or environment
4. Custom slash commands are available in the chat

## Development Workflow

```bash
# Start a new feature
git checkout main && git pull
git checkout -b feat/PROJ-42-feature-name

# Develop (with AI assistance — see docs/ai-workflow.md)

# Before committing
bun lint && bun typecheck && bun test  # TODO: adjust for your stack

# Commit
git commit -m "feat(scope): description"

# Open PR
gh pr create --fill
```

Full workflow details: **`docs/ai-workflow.md`**

## Key Commands

```bash
# TODO: Fill these in with actual project commands

# Development
bun dev          # Start dev server

# Testing
bun test         # Run all tests
bun test --watch # Watch mode

# Code quality
bun lint         # Lint
bun typecheck    # Type check
bun format       # Format

# Database
bun db:migrate   # Run migrations
bun db:seed      # Seed data

# Other
bun build        # Production build
```

## Getting Help

- **Project questions**: Ask in `#<channel>` on Slack / Teams
- **AI tool questions**: See `docs/ai-workflow.md`
- **Bug in this skeleton**: Open an issue in the skeleton repository

## First Task

Once setup is complete, your first task should be:

1. Pick up a `good-first-issue` ticket from the backlog
2. Run `/architect <issue description>` in Claude Code or Cursor to design the implementation
3. Implement following the checklist from the design
4. Run `/review` and address any issues
5. Open a PR using the template

Good luck, and don't hesitate to ask for help!
