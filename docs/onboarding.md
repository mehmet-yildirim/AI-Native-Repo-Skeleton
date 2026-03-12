# Developer Onboarding Guide

Welcome to the project. This guide gets you from zero to productive as quickly as possible.

---

## Prerequisites

Before you start, make sure you have:

- [ ] TODO: List required tools (e.g., Node.js 22+, Docker, etc.)
- [ ] TODO: Access to required services (e.g., AWS account, database, secrets)
- [ ] Git configured with your work email
- [ ] An AI coding tool set up (Cursor, VS Code with Continue, or Claude Code)

---

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

---

## Understanding the Project

Read these documents in order:

1. **`docs/context/project-brief.md`** — What this project does and for whom
2. **`docs/context/tech-stack.md`** — Technology choices and why
3. **`docs/architecture/overview.md`** — How the system is structured
4. **`CLAUDE.md`** — Coding conventions and key commands
5. **`docs/context/domain-glossary.md`** — Business terminology
6. **`docs/context/domain-boundaries.md`** — Scope definition for the autonomous agent

---

## Setting Up AI Tools

### Claude Code

```bash
# Install Claude Code (if not already installed)
npm install -g @anthropic-ai/claude-code

# In the project directory, Claude Code automatically loads CLAUDE.md
claude

# All 20 custom commands (type / to see them):
# --- Human-guided ---
# /init          — populate all TODO files from a project description
# /requirements  — analyze requirements → user stories, tasks, DoD
# /architect     — design a feature before implementing
# /implement     — structured bottom-up implementation with tests
# /security-audit — OWASP + CVE + secret scan (run before every PR)
# /qa            — full quality gates: lint, types, tests, coverage
# /review        — code review against project standards
# /test          — generate comprehensive tests
# /debug         — systematic bug diagnosis
# /deploy        — pre-deploy checklist + monitoring plan
# /infra         — scaffold deployment infrastructure (AWS/GCP/on-prem)
# /migrate       — safe database migration planning
# /db            — database lifecycle: init, create, dml, seed, audit
# /sprint        — sprint planning from backlog
# /docs          — generate documentation
# /standup       — daily standup from git history
# --- Autonomous agent ---
# /triage        — assess if a JIRA issue belongs to this project
# /groom         — process backlog through triage + requirements
# /loop          — run the full autonomous development loop for a task
# /escalate      — raise a structured escalation when blocked
```

### Cursor

1. Open the project folder in Cursor
2. Rules in `.cursor/rules/` are loaded automatically by file type
3. Enable MCP servers in `.cursor/mcp.json` if desired (see README.md → MCP Servers)
4. Add your `ANTHROPIC_API_KEY` to Cursor settings

### Continue (VS Code / JetBrains)

1. Install the Continue extension
2. Continue will detect `.continue/config.yaml` automatically
3. Add your `ANTHROPIC_API_KEY` to the config or environment
4. Uncomment the skill rules relevant to your stack in `.continue/config.yaml`
5. Custom slash commands are available in the chat (`/requirements`, `/architect`, etc.)

---

## Setting Up the Autonomous Agent (Optional)

If you will be using the autonomous agent (JIRA backlog → automated development), complete
this additional setup:

### 1. Configure the issue tracker connection

Edit `agent.config.yaml`:
```yaml
agent:
  mode: semi-autonomous        # Start here before moving to autonomous
issue_tracker:
  provider: jira               # or: linear, github, azure-devops
  jira:
    server_url: "${JIRA_URL}"
    project_key: "YOUR_KEY"
```

For on-premise Jira Server setup, see `docs/agent/jira-server-setup.md`.

### 2. Define the project domain

Fill in `docs/context/domain-boundaries.md` — this file controls which JIRA issues
the agent accepts or rejects. Be specific:

```markdown
## In-Scope Examples
✅ "Add retry logic to payment webhook handler"
✅ "Fix order status not updating after payment"

## Out-of-Scope Examples
❌ "Update marketing landing page"  → Frontend/Marketing team
❌ "Add SSO login"                 → Auth service team
```

### 3. Set environment variables

Add to your `.env`:
```env
JIRA_URL=https://jira.yourcompany.com
JIRA_EMAIL=your-username
JIRA_API_TOKEN=your-pat-token
SLACK_WEBHOOK_URL=https://hooks.slack.com/...
```

### 4. Test the connection

```bash
# Verify Jira API access from the agent host
curl -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_URL/rest/api/2/myself" | jq .displayName

# Run a triage test on a known issue
/triage YOUR-PROJECT-1
```

### 5. Run the full loop on a test issue

```bash
/loop YOUR-PROJECT-1
```

The agent will:
- Design the implementation (`/architect`)
- Create a git branch
- Implement with a retry loop on test failures
- Run `/security-audit` on the changes
- Run `/qa` quality gates
- Create a Pull Request
- Monitor CI and deployment

Full documentation: `docs/agent/autonomous-workflow.md`

---

## Development Workflow

```bash
# Start a new feature
git checkout main && git pull
git checkout -b feat/PROJ-42-feature-name

# Develop (with AI assistance — see docs/ai-workflow.md)
/requirements Add payment retry logic   # 1. Analyze requirements
/architect                              # 2. Design (for large tasks)
/implement TASK-001: ...                # 3. Implement step by step
/security-audit diff                   # 4. Security check (ALWAYS)
/qa                                    # 5. Quality gates
/review                                # 6. Final review

# Commit
git commit -m "feat(scope): description"

# Open PR
gh pr create --fill
```

Full workflow details: **`docs/ai-workflow.md`** | **`docs/ai-workflow.tr.md`** (Turkish)

---

## Security Checklist (Before Every PR)

Run `/security-audit diff` and verify:
- [ ] No CRITICAL or HIGH findings
- [ ] No committed secrets or credentials
- [ ] All user inputs validated at entry point
- [ ] Authorization checked before data access
- [ ] No dependency CVEs with CVSS ≥ 7.0

---

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

---

## Getting Help

- **Project questions**: Ask in `#<channel>` on Slack / Teams
- **AI tool questions**: See `docs/ai-workflow.md`
- **Autonomous agent issues**: See `docs/agent/escalation-protocol.md`
- **Bug in this skeleton**: Open an issue in the skeleton repository

---

## First Task

Once setup is complete, your first task should be:

1. Pick up a `good-first-issue` ticket from the backlog
2. Run `/requirements <issue description>` to analyze and decompose it
3. Run `/architect <issue description>` to design the implementation
4. Implement following the checklist — one task per commit
5. Run `/security-audit diff` — fix any CRITICAL/HIGH findings
6. Run `/qa` — fix any blocking issues
7. Run `/review` — address any feedback
8. Open a PR using the template

Good luck, and don't hesitate to ask for help!
