# AI-Native Repository Skeleton

A production-ready repository skeleton for **AI-Native agentic development** — from interactive
human-guided coding to a fully autonomous agent that pulls work from JIRA, validates domain
relevance, and delivers Pull Requests without manual intervention.

Supports [Cursor](https://cursor.sh), [Continue](https://continue.dev), and [Claude Code](https://claude.ai/code) out of the box.

> **Turkish / Türkçe:** See [README.tr.md](README.tr.md) for the full developer guide in Turkish.

---

## What This Provides

| Layer | Config | Purpose |
|-------|--------|---------|
| **Claude Code** | `CLAUDE.md`, `.claude/` | Project instructions, 16 slash commands, event hooks |
| **Cursor** | `.cursor/rules/`, `.cursor/prompts/` | 18 contextual rule files + 16 workflow prompt files |
| **Continue** | `.continue/` | Multi-model config, inline slash commands, persistent rules |
| **Autonomous Agent** | `agent.config.yaml`, `docs/agent/` | JIRA polling, domain triage, full dev loop, escalation |
| **GitHub** | `.github/` | PR template, issue templates, CI workflow skeleton |
| **All editors** | `.editorconfig` | Consistent formatting across languages |

---

## Quick Start

```bash
# 1. Clone the skeleton into your new project
git clone <this-repo> my-project
cd my-project

# 2. Initialize git, create .env, check config files
./scripts/setup.sh

# 3. Run the interactive wizard — configures name, stack, tracker, keywords
bash scripts/init.sh

# 4. Open Claude Code and let AI populate all remaining files
claude
/init I'm building a <type> called <name> for <users>. Stack: <language, framework, DB>.

# 5. Verify everything is in place
bash scripts/validate-ai-config.sh   # expect 73 PASS, 0 FAIL

# 6. Start coding
/requirements <your first feature>
```

---

## Customization Checklist

### Automated by `scripts/init.sh` + `/init`

Run `bash scripts/init.sh` then `/init <description>` in Claude Code — these populate everything below automatically.

| File | Populated by | Method |
|------|-------------|--------|
| `CLAUDE.md` | `init.sh` + `/init` | wizard fills mechanical fields; AI fills conventions and layout |
| `.cursor/rules/00-project-overview.mdc` | `init.sh` + `/init` | same as CLAUDE.md |
| `docs/context/project-brief.md` | `/init` | AI-generated from your description |
| `docs/context/tech-stack.md` | `/init stack:` | AI-generated with confirmed or inferred choices |
| `docs/context/domain-boundaries.md` | `/init domain:` | AI-generated — **critical for autonomous agent** |
| `docs/context/domain-glossary.md` | `/init` or `/init glossary:` | AI-generated from domain analysis |
| `docs/architecture/overview.md` | `/init` | AI-generated architecture skeleton |
| `agent.config.yaml` (IDs, keys, keywords) | `init.sh` + `/init agent:` | wizard fills IDs; `/init agent:` fills tracker/team keys |
| `.github/workflows/ci.yml` | `/init ci:` | AI-generated per detected stack |

### Still requires manual action
- [ ] `.continue/config.yaml` — add API keys
- [ ] `.env` — fill in credentials
- [ ] `.cursor/mcp.json` — enable MCP servers (GitHub, Jira, Slack, Sentry, etc.)
- [ ] `docs/architecture/decisions/` — create ADRs from `0001-template.md`
- [ ] Review and refine all AI-generated content before first commit

### Recommended
- [ ] `docs/context/domain-glossary.md` — domain-specific terminology
- [ ] `.github/workflows/ci.yml` — adapt to your language and framework
- [ ] `.cursor/mcp.json` — enable MCP servers (GitHub, Jira, Slack, Sentry, etc.)
- [ ] `.continue/config.yaml` skills — uncomment only the rules matching your stack
- [ ] `docs/architecture/decisions/` — create your first ADR from `0001-template.md`

### Manual Steps Not Automated by `setup.sh`

These require explicit action after cloning:

**Pre-commit secret scanning hook** — documented in `docs/workflows/05-security-evaluation.md` but not wired automatically. Install with your preferred tool:
```bash
# Option A — Husky (Node.js projects)
npx husky init
echo "npx secretlint '**/*'" > .husky/pre-commit

# Option B — pre-commit (Python / polyglot)
pip install pre-commit
# add detect-secrets or gitleaks to .pre-commit-config.yaml
pre-commit install
```

**Webhook receiver** — copy the Jira Server webhook template before enabling autonomous mode:
```bash
mkdir -p .agent
cp .agent-templates/webhook-receiver.mjs .agent/webhook-receiver.mjs
# then set JIRA_WEBHOOK_SECRET in .env and start: node .agent/webhook-receiver.mjs
```

**Runtime agent directories** — hooks write to `.agent/audit/` and `.agent/state/` at runtime; they are created on first use and git-ignored. No action needed unless you want to pre-create them:
```bash
mkdir -p .agent/{state,audit,outputs}
```

**PagerDuty escalation** — `agent.config.yaml` routes CRITICAL escalations to PagerDuty, but no PagerDuty MCP server or SDK integration is included. You must implement this integration or reroute CRITICAL events to Slack/email before enabling autonomous mode in production.

---

## Repository Structure

```
.
├── CLAUDE.md                                  # ← CUSTOMIZE — Claude Code instructions
├── agent.config.yaml                          # ← CUSTOMIZE — autonomous agent config
│
├── .cursor/
│   ├── prompts/                               # 17 reusable workflow prompts (invoke via @)
│   │   ├── README.md                         # How to use Cursor prompts
│   │   ├── init.md                           # @init  ← project initialization
│   │   ├── requirements.md  architect.md  implement.md  review.md
│   │   ├── qa.md  test.md  debug.md  deploy.md  migrate.md
│   │   ├── sprint.md  docs.md  standup.md  security-audit.md
│   │   └── triage.md  groom.md  loop.md  escalate.md
│   ├── rules/
│   │   ├── 00-project-overview.mdc           # ← CUSTOMIZE — always loaded by Cursor
│   │   ├── 01-coding-standards.mdc           # General coding standards
│   │   ├── 02-architecture.mdc               # Architecture guidelines & layer rules
│   │   ├── 03-testing.mdc                    # Test pyramid, mocking strategy
│   │   ├── 04-git-workflow.mdc               # Branch naming, commits, PRs
│   │   ├── 05-security.mdc                   # OWASP Top 10 (always loaded)
│   │   └── skills/                           # Auto-activate by file glob
│   │       ├── lang-java.mdc                 # Spring Boot, JPA, JUnit 5, Java 21
│   │       ├── lang-dotnet.mdc               # ASP.NET Core, EF Core, xUnit, C# 12
│   │       ├── lang-python.mdc               # FastAPI, SQLAlchemy, pytest, type hints
│   │       ├── lang-typescript.mdc           # Strict TS, ESM, Bun/Node.js
│   │       ├── lang-go.mdc                   # Idiomatic Go, stdlib, concurrency
│   │       ├── fe-react.mdc                  # Hooks, React Query, RTL, forms
│   │       ├── fe-nextjs.mdc                 # App Router, Server Components, Actions
│   │       ├── fe-vue.mdc                    # Composition API, Pinia, Vue Router
│   │       ├── fe-angular.mdc                # Standalone, Signals, NgRx, RxJS
│   │       ├── mobile-ios.mdc                # Swift, SwiftUI, async/await, SwiftData
│   │       ├── mobile-android.mdc            # Kotlin, Compose, Hilt, Room, Flow
│   │       ├── mobile-flutter.mdc            # Dart 3, Riverpod, GoRouter, Freezed
│   │       ├── mobile-reactnative.mdc        # Expo, TS strict, React Navigation, EAS
│   │       ├── be-microservices.mdc          # Service design, resilience, observability
│   │       ├── devops-docker.mdc             # Dockerfile, Compose, security
│   │       └── devops-cicd.mdc               # GitHub Actions, quality gates, deployment
│   └── mcp.json                               # MCP: GitHub, Jira, Linear, Slack, Sentry…
│
├── .continue/
│   ├── config.yaml                            # ← ADD API KEYS — multi-model setup
│   └── rules/
│       ├── 01-coding-standards.md
│       ├── 02-architecture.md
│       ├── 03-testing.md
│       ├── 04-security.md
│       └── skills/                            # Uncomment in config.yaml to activate
│           ├── lang-java.md
│           ├── lang-dotnet.md
│           ├── lang-python.md
│           ├── fe-react.md
│           ├── fe-nextjs.md
│           ├── fe-vue.md
│           ├── fe-angular.md
│           ├── mobile-ios.md
│           ├── mobile-android.md
│           ├── mobile-flutter.md
│           └── mobile-reactnative.md
│
├── .claude/
│   ├── settings.json                          # Tool permissions + event hooks
│   ├── commands/                              # 17 slash commands
│   │   ├── init.md                           # /init  ← project initialization
│   │   ├── requirements.md                   # /requirements
│   │   ├── architect.md                      # /architect
│   │   ├── implement.md                      # /implement
│   │   ├── review.md                         # /review
│   │   ├── qa.md                             # /qa
│   │   ├── test.md                           # /test
│   │   ├── debug.md                          # /debug
│   │   ├── deploy.md                         # /deploy
│   │   ├── migrate.md                        # /migrate
│   │   ├── sprint.md                         # /sprint
│   │   ├── docs.md                           # /docs
│   │   ├── standup.md                        # /standup
│   │   ├── triage.md                         # /triage  ← autonomous agent
│   │   ├── groom.md                          # /groom   ← autonomous agent
│   │   ├── loop.md                           # /loop    ← autonomous agent
│   │   └── escalate.md                       # /escalate ← autonomous agent
│   └── hooks/                                # Event-driven hooks
│       ├── post-write.mjs                    # Guards protected paths on every file write
│       ├── audit-log.mjs                     # Records every bash command + exit code
│       └── on-stop.mjs                       # Session end: warns about in-flight tasks
│
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── ISSUE_TEMPLATE/
│   └── workflows/ci.yml                       # CI skeleton — adapt for your stack
│
├── docs/
│   ├── ai-workflow.md                         # AI-Native development guide
│   ├── onboarding.md                          # New developer onboarding
│   ├── context/                               # ← CUSTOMIZE ALL
│   │   ├── project-brief.md                  # What the project does and for whom
│   │   ├── tech-stack.md                     # Technology decisions
│   │   ├── domain-glossary.md                # Business terminology
│   │   └── domain-boundaries.md              # ← CUSTOMIZE — agent triage scope
│   ├── architecture/
│   │   ├── overview.md                        # ← CUSTOMIZE — system architecture
│   │   └── decisions/                         # Architecture Decision Records (ADR)
│   ├── agent/                                 # Autonomous agent documentation
│   │   ├── autonomous-workflow.md             # State machine, phases, gates, resume
│   │   ├── escalation-protocol.md            # Triggers, severity, human responses
│   │   ├── decision-log-template.md          # Audit trail schema & examples
│   │   ├── security-evaluator.md             # Security architecture & integration points
│   │   ├── jira-server-setup.md              # On-premise Jira Server setup guide
│   │   └── schemas/                          # JSON schemas for inter-phase contracts
│   │       ├── task-state.json               # Per-task persistent state
│   │       ├── decision.json                 # Structured decision record
│   │       ├── requirement-analysis.json     # /requirements structured output
│   │       ├── qa-report.json                # /qa gate results
│   │       └── security-report.json          # /security-audit output schema
│   └── workflows/                             # Development workflow guides
│       ├── 01-requirements-analysis.md
│       ├── 02-feature-development.md
│       ├── 03-testing-strategy.md
│       ├── 04-deployment.md
│       └── 05-security-evaluation.md         # Security touchpoints & remediation workflow
│
├── skills/
│   └── README.md                              # Skills index & activation guide
│
├── .agent-templates/
│   └── webhook-receiver.mjs                   # Jira Server webhook receiver (copy to .agent/)
│
└── scripts/
    ├── setup.sh                               # Step 1: git init, .env, config check
    ├── init.sh                                # Step 2: interactive wizard (name, stack, tracker, keywords)
    └── validate-ai-config.sh                  # Configuration validator (73 checks, 14 of 16 slash commands)
```

---

## Cursor Prompt Files

Cursor does not have a native slash command registry, but it supports **prompt files** — Markdown
workflow templates that are injected into the chat via `@` references. The `.cursor/prompts/`
directory provides a 1:1 equivalent to the Claude Code slash commands.

### How to invoke

```
@.cursor/prompts/requirements.md

Add JWT-based authentication to the login endpoint.
```

Cursor injects the full prompt into the conversation. Your text after the `@` reference is the
task input — equivalent to `$ARGUMENTS` in the Claude commands.

You can also combine with source files for richer context:

```
@.cursor/prompts/review.md @src/api/orders.ts
```

### Comparison

| Claude Code | Cursor | Same workflow? |
|------------|--------|---------------|
| `/requirements Add auth` | `@.cursor/prompts/requirements.md` + "Add auth" | Yes |
| `/architect` | `@.cursor/prompts/architect.md` | Yes |
| `/qa` | `@.cursor/prompts/qa.md` | Yes |
| `/loop PROJ-42` | `@.cursor/prompts/loop.md` + "PROJ-42" | Yes |

Key differences from the Claude commands:
- Cursor loads project rules (`.cursor/rules/`) automatically — prompt files do not repeat "read CLAUDE.md"
- The `standup.md` prompt asks you to run the git command in your terminal and paste the output
- Bash commands described in prompts must be run manually in Cursor's integrated terminal
- Cursor supports `@file` cross-references directly inside prompts (e.g., `@docs/context/domain-boundaries.md`)

See [`.cursor/prompts/README.md`](.cursor/prompts/README.md) for the full reference.

---

## Slash Commands Reference

### Project Initialization

| Command | Purpose | When to use |
|---------|---------|------------|
| `/init <description>` | Populate all TODO files from a free-form project description | First thing after cloning the skeleton |
| `/init domain: <desc>` | Populate domain boundaries, glossary, and agent keywords only | When refining scope or adding a new service |
| `/init stack: <stack>` | Populate tech stack file and CLAUDE.md commands | When changing or finalizing the technology choices |
| `/init ci: <stack>` | Generate real CI workflow steps for your language and deployment target | After deciding on CI/CD infrastructure |
| `/init agent: <keys>` | Set tracker keys, GitHub owner/repo, escalation recipients in agent.config.yaml | When configuring the autonomous agent |

### Human-Guided Commands
Used interactively — you invoke each step and review the output.

| Command | Purpose | When to use |
|---------|---------|------------|
| `/requirements` | Decompose raw requirements → user stories, acceptance criteria, ordered task backlog, DoD | Before starting any feature |
| `/architect` | Design implementation before writing a single line of code | For any task > 50 lines |
| `/implement` | Bottom-up structured implementation with self-review checklist | During coding |
| `/qa` | Full quality cycle: lint, type check, tests, coverage, security audit | Before opening a PR |
| `/review` | Deep code review against project standards and OWASP | After implementation |
| `/test` | Generate comprehensive tests (happy path, edge cases, error cases) | For any module or function |
| `/debug` | Systematic bug diagnosis: hypotheses → investigation → fix → prevention | When stuck on a bug |
| `/deploy` | Pre-deploy checklist, execution steps, post-deploy monitoring plan | Before every deploy |
| `/migrate` | Safe DB migration: Expand-Contract pattern, batch strategy, rollback plan | For schema changes |
| `/sprint` | Sprint planning: capacity analysis, backlog selection, task breakdown, risk register | Sprint kickoff |
| `/docs` | Generate API docs, architecture docs, or user guides from source | After implementation |
| `/standup` | Daily standup summary from git history | Start of day |

### Autonomous Agent Commands
Run without human involvement for each step — the agent decides and acts.

| Command | Purpose | How it works |
|---------|---------|-------------|
| `/triage <issue>` | Assess if a JIRA/Linear/GitHub issue belongs to this project | Scores confidence across 4 dimensions (entity match, functional area, code ownership, exclusions). Auto-accepts ≥ 0.80, auto-rejects < 0.30, escalates the rest |
| `/groom` | Process a batch of backlog issues through triage + requirements | Polls the configured issue tracker, runs `/triage` on each candidate, then `/requirements` on accepted ones. Respects `max_concurrent_tasks` |
| `/loop <task-id>` | Full autonomous development loop for a single task | Runs: design → create branch → implement (with retry loop) → QA → create PR → monitor CI → deploy → post-deploy monitoring. Saves state for resume-on-crash |
| `/escalate <severity> <trigger> <task-id>` | Raise a structured escalation when the agent cannot proceed | Packages context, sends Slack/GitHub/email notifications, polls for human response commands (`AGENT_RESUME`, `AGENT_SKIP_TASK`, `AGENT_ABANDON`, etc.) |

---

## Autonomous Agent Loop

The full autonomous lifecycle from issue tracker to production:

```
Issue Tracker (JIRA / Linear / GitHub)
         │
         ▼
  /groom — polls on schedule or webhook trigger
         │
         ▼
  /triage — domain relevance check
  ┌────────────────────────────────────────┐
  │  Confidence scoring:                   │
  │    Entity match        up to +0.30     │
  │    Functional area     up to +0.40     │
  │    Code ownership      up to +0.20     │
  │    Hard exclusion      penalty -0.30   │
  └────────────────────────────────────────┘
         │
  ≥ 0.80 ACCEPT    0.30–0.79 ESCALATE    < 0.30 REJECT
         │
         ▼
  /requirements — user stories + ordered task backlog (JSON + Markdown)
         │
  confidence gate ── if low ──▶ /escalate medium requirements_confidence_low
         │
         ▼
  /architect — design doc + risk assessment
         │
  risk = HIGH ──▶ /escalate high design_risk_high ──▶ await AGENT_APPROVE_DESIGN
         │
         ▼
  /loop — implementation loop (per task):
  ┌─────────────────────────────────────────────────────┐
  │  implement task → run tests                         │
  │  FAIL → /debug → fix → re-test  (up to max_retries) │
  │  still FAIL → /escalate high implement_max_retries   │
  └─────────────────────────────────────────────────────┘
         │
         ▼
  /qa — lint + type check + coverage + security
  FAIL → auto-fix attempt → still FAIL → /escalate high qa_gate_failure
         │
         ▼
  Create PR (linked to issue, with QA report + risk level)
  Monitor CI → FAIL → /escalate high ci_pipeline_failure
         │
         ▼
  Await merge (auto-merge if configured, else await human)
         │
         ▼
  /deploy staging (auto) → /deploy production (human approval gate)
         │
         ▼
  Post-deploy monitoring (30 min)
  Error rate spike → auto-rollback + /escalate critical post_deploy_error_spike
         │
         ▼
  Update issue tracker → Done ✓
  Write audit log entry
```

### Agent State & Safety

- **Persistent state**: every task's progress is saved to `.agent/state/<task-id>.json` — the agent resumes from the last checkpoint if interrupted
- **Kill switch**: `touch .agent/STOP` halts the agent before the next phase transition
- **Audit trail**: every decision, command, and cost logged to `.agent/audit/<date>-*.jsonl`
- **Protected paths**: `agent.config.yaml` defines files and commands the agent may never touch

### Escalation Human-Response Commands

When the agent escalates, respond on the GitHub issue or JIRA ticket:

| Comment | Effect |
|---------|--------|
| `AGENT_RESUME` | Resume from current phase |
| `AGENT_RESUME phase=architect` | Restart from a specific phase |
| `AGENT_CLARIFY: <text>` | Provide clarification; agent retries with it |
| `AGENT_APPROVE_DESIGN` | Approve high-risk design; proceed to implement |
| `AGENT_APPROVE_DEPLOY` | Approve production deployment |
| `AGENT_SKIP_TASK` | Skip current sub-task; continue to next |
| `AGENT_REASSIGN` | Remove from agent queue; hand to a human |
| `AGENT_ABANDON` | Stop all work on this ticket |

---

## Language & Framework Skills

Skills provide deep, idiomatic guidance for specific languages and frameworks.
**Cursor** activates them automatically via file glob patterns.
**Continue** activates them by uncommenting in `.continue/config.yaml`.

| Category | Skill | Key Coverage |
|----------|-------|-------------|
| **Backend** | Java / Spring Boot | Constructor injection, JPA N+1, Flyway, JUnit 5, Java 21 records & virtual threads |
| | .NET / C# | Minimal APIs, Clean Architecture, EF Core, xUnit, NSubstitute, C# 12 |
| | Python / FastAPI | Pydantic v2, SQLAlchemy 2 async, pytest, strict type hints, uv |
| | TypeScript / Node.js | Strict mode, discriminated unions, Zod, Bun, Vitest |
| | Go | Idiomatic patterns, interfaces at consumer, error wrapping, table-driven tests |
| **Frontend** | React | Hooks, TanStack Query, React Hook Form + Zod, RTL + MSW |
| | Next.js App Router | Server Components, Server Actions, ISR, streaming |
| | Vue 3 | Composition API, Pinia Setup Stores, composables |
| | Angular 17+ | Standalone components, Signals, NgRx Signal Store, RxJS |
| **Mobile** | iOS (Swift / SwiftUI) | async/await + actors, @Observable, NavigationStack, SwiftData, Swift Testing |
| | Android (Kotlin / Compose) | StateFlow, Hilt, Room + Flow, Compose UDF, Turbine testing |
| | Kotlin Multiplatform (KMP) | Shared logic + Compose Multiplatform UI, Ktor, SQLDelight, Koin, expect/actual, SKIE Swift interop |
| | Flutter / Dart | Riverpod + code-gen, GoRouter, Freezed, drift, EAS / Fastlane |
| | React Native / Expo | Strict TS, FlashList, React Navigation v7, Zustand + TanStack Query, EAS |
| **Infra** | Docker | Multi-stage builds, non-root user, Compose health checks, image scanning |
| | GitHub Actions CI/CD | Quality gates, OIDC auth, canary / blue-green deployment |
| | Microservices | Bounded contexts, circuit breakers, Saga pattern, OpenTelemetry |

See [skills/README.md](skills/README.md) for the full index and instructions for adding new skills.

> **Continue skill parity note:** Cursor includes all 17 skill files. `.continue/rules/skills/` ships with 12 — `lang-typescript`, `lang-go`, `be-microservices`, `devops-docker`, and `devops-cicd` are absent. If your project uses any of those, create the corresponding `.md` file under `.continue/rules/skills/` and add it to `.continue/config.yaml`. Mirror the structure of the existing `.continue` skill files.

---

## MCP Servers

Pre-configured in `.cursor/mcp.json`. Remove `"disabled": true` and set env vars to enable:

| Server | Purpose | Env vars needed |
|--------|---------|----------------|
| `filesystem` | Read/write workspace files | — (auto) |
| `git` | Git history, diffs, blame | — (auto) |
| `github` | Issues, PRs, CI status | `GITHUB_TOKEN` |
| `postgres` | Schema inspection, query testing | `DATABASE_URL` |
| `jira` | Pull issues, update status — used by `/triage`, `/groom` | `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` |
| `linear` | Alternative to Jira | `LINEAR_API_KEY` |
| `slack` | Escalation notifications | `SLACK_BOT_TOKEN`, `SLACK_TEAM_ID` |
| `sentry` | Post-deploy error monitoring | `SENTRY_AUTH_TOKEN`, `SENTRY_ORG` |
| `brave-search` | Web search for docs | `BRAVE_API_KEY` |
| `memory` | Persistent cross-session memory | — |
| `puppeteer` | Browser automation / E2E | — |

---

## Claude Code Hooks

Event-driven hooks run automatically on tool use:

| Hook | File | What it does |
|------|------|-------------|
| `UserPromptSubmit` | `toon.mjs` | Token usage optimization before every prompt |
| `PostToolUse(Write)` | `post-write.mjs` | Warns if a protected path was written; logs to audit trail |
| `PostToolUse(Bash)` | `audit-log.mjs` | Records every command + exit code; flags forbidden patterns |
| `Stop` | `on-stop.mjs` | Session-end summary: lists in-flight tasks, warns if kill switch is active |

---

## AI-Native Development Philosophy

Four principles this skeleton is built on:

1. **Context is everything.** AI tools produce better output when they understand your project's purpose, constraints, and conventions. The `docs/context/` directory and rule files exist to provide this context persistently.

2. **Rules over repetition.** Define standards once in skill files so you never need to repeat "use constructor injection" or "always write tests" in every prompt.

3. **Structured workflows.** Slash commands encode your team's recurring workflows so AI agents execute them consistently — from a raw requirement all the way to a merged PR.

4. **Humans set limits, agents execute.** The agent acts autonomously within its configured thresholds. Every risky decision (high-risk design, production deploy) escalates to a human. The audit trail records everything.

---

## Architecture Decision Records

The skeleton ships with a single ADR template at `docs/architecture/decisions/0001-template.md`. Create real ADRs for every significant design choice in your project:

```bash
# Copy the template for each new decision
cp docs/architecture/decisions/0001-template.md \
   docs/architecture/decisions/0002-database-choice.md
```

Use sequential numbering. Link each ADR from `docs/architecture/overview.md` once it is accepted.

---

## Validation Script Reference

```bash
bash scripts/validate-ai-config.sh
```

Runs 73 checks across all configuration files:

| Result | Meaning |
|--------|---------|
| `PASS` | File exists |
| `WARN` | File exists but contains TODO placeholders (customization expected) |
| `FAIL` | File missing — fix before starting development |

> **Known coverage gap:** The script validates 14 of the 16 slash commands. `standup.md` and `security-audit.md` are present in `.claude/commands/` but are not included in the validation checks. This does not affect functionality — both commands work — but `validate-ai-config.sh` will not detect if they are accidentally deleted.

---

## Contributing

See [docs/ai-workflow.md](docs/ai-workflow.md) for the development workflow used to maintain this skeleton itself.
