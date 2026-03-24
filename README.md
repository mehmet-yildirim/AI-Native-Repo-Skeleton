# Initium

A production-ready starter for **AI-Native agentic development** — from interactive human-guided coding all the way to a fully autonomous agent that pulls work from JIRA, validates domain relevance, and delivers Pull Requests without manual intervention.

Supports [Cursor](https://cursor.sh), [Continue](https://continue.dev), and [Claude Code](https://claude.ai/code) out of the box.

> **Turkish / Türkçe:** [README.tr.md](README.tr.md) · **AI Workflow:** [docs/guides/ai-workflow.md](docs/guides/ai-workflow.md)

---

## What This Provides

| Layer | Config | Purpose |
|-------|--------|---------|
| **Claude Code** | `CLAUDE.md`, `.claude/` | Project instructions, 28 slash commands, event hooks |
| **Cursor** | `.cursor/rules/`, `.claude/commands/` | 6 base rules + 22 skill rules (auto-activate by file type) + shared slash commands |
| **Continue** | `.continue/` | Multi-model setup, 22 skill rules, persistent guidelines |
| **Autonomous Agent** | `agent.config.yaml`, `docs/guides/agent/` | JIRA polling, domain triage, full dev loop, escalation system |
| **GitHub** | `.github/` | PR template, issue templates, CI workflow template |
| **Initium sync** | `.initium/initium.json`, `.initium/scripts/sync.{sh,ps1,cmd}` | Pull improvements from upstream Initium without overwriting customizations |

---

## Quick Start

```bash
# 1. Clone
git clone <this-repo> my-project && cd my-project

# 2. Initialize (git, .env, checks)
./.initium/scripts/setup.sh          # macOS/Linux
# .initium\scripts\setup.cmd         # Windows (Batch)
# .\.initium\scripts\setup.ps1       # Windows (PowerShell)

# 3. Run interactive wizard — fills project name, stack, tracker keys
bash .initium/scripts/init.sh

# 4. Let AI populate all remaining TODO files
claude
/init I'm building a <type> called <name> for <users>. Stack: <language, framework, DB>.

# 5. Verify
bash .initium/scripts/validate.sh   # expect: all PASS, no FAIL
```

After setup, code with the AI loop:
```
/requirements <your first feature>   →  /architect  →  /task plan  →  /implement  →  /qa  →  /deploy
```

> **New to the project or unsure what to do?** Type `/help` in Claude Code or Cursor — the AI will guide you to the right command for your situation.

---

## Customization Checklist

### Automated by `.initium/scripts/init.sh` + `/init`

| File | How it's populated |
|------|--------------------|
| `CLAUDE.md` | Wizard fills mechanical fields; AI fills conventions |
| `.cursor/rules/00-project-overview.mdc` | Same as CLAUDE.md |
| `docs/context/project-brief.md` | AI-generated from your description |
| `docs/context/tech-stack.md` | AI-generated from confirmed stack |
| `docs/context/domain-boundaries.md` | AI-generated — **critical for autonomous agent** |
| `docs/context/domain-glossary.md` | AI-generated from domain analysis |
| `docs/architecture/overview.md` | AI-generated architecture template |
| `agent.config.yaml` | Wizard fills IDs; `/init agent:` fills tracker keys |
| `.github/workflows/ci.yml` | `/init ci:` generates per detected stack |

### Requires manual action
- [ ] `.continue/config.yaml` — add API key(s); uncomment your stack's skill rules
- [ ] `.env` — fill in credentials (copy from `.env.example`)
- [ ] `.cursor/mcp.json` — enable MCP servers by removing `"disabled": true`
- [ ] Review and refine all AI-generated content before first commit

---

## Repository Structure

```
.
├── CLAUDE.md                           # ← CUSTOMIZE — project instructions for Claude Code
├── agent.config.yaml                   # ← CUSTOMIZE — autonomous agent configuration
├── .initium/
│   ├── initium.json                   # Tracks which Initium version this project is based on
│   ├── scripts/                       # Initium lifecycle scripts (setup, sync, validate)
│   └── docs/                          # Initium documentation (sync guide, update notes)
│
├── .claude/
│   ├── settings.json                   # Tool permissions + event hooks
│   ├── commands/                       # 28 slash commands (type / in Claude Code)
│   │   ├── help.md                     # /help — guide to commands and workflows
│   │   ├── init.md                     # /init — project setup wizard
│   │   ├── requirements.md             # /requirements
│   │   ├── architect.md                # /architect
│   │   ├── implement.md                # /implement
│   │   ├── task.md                     # /task — task planning + tracking
│   │   ├── review.md                   # /review
│   │   ├── qa.md                       # /qa
│   │   ├── security-audit.md           # /security-audit
│   │   ├── test.md                     # /test
│   │   ├── debug.md                    # /debug
│   │   ├── deploy.md                   # /deploy
│   │   ├── infra.md                    # /infra
│   │   ├── migrate.md                  # /migrate
│   │   ├── db.md                       # /db
│   │   ├── sprint.md                   # /sprint
│   │   ├── docs.md                     # /docs
│   │   ├── doc-api.md                  # /doc-api — OpenAPI spec generation
│   │   ├── doc-diagrams.md             # /doc-diagrams — sequence diagrams for API & business flows
│   │   ├── doc-site.md                 # /doc-site — documentation website
│   │   ├── doc-changelog.md            # /doc-changelog — CHANGELOG from git history
│   │   ├── doc-schema.md               # /doc-schema — database ERD + table reference
│   │   ├── standup.md                  # /standup
│   │   ├── sync-initium.md             # /sync-initium — apply upstream Initium updates
│   │   ├── triage.md                   # /triage        ← autonomous agent
│   │   ├── groom.md                    # /groom         ← autonomous agent
│   │   ├── loop.md                     # /loop          ← autonomous agent
│   │   └── escalate.md                 # /escalate      ← autonomous agent
│   └── hooks/
│       ├── post-write.mjs              # Guards protected paths on every file write
│       ├── audit-log.mjs               # Records every bash command + exit code
│       └── on-stop.mjs                 # Session-end: warns about in-flight agent tasks
│
├── .cursor/
│   ├── prompts/                        # Cursor prompt files — mirror of Claude commands
│   ├── rules/
│   │   ├── 00-project-overview.mdc    # ← CUSTOMIZE — always loaded by Cursor
│   │   ├── 01-coding-standards.mdc
│   │   ├── 02-architecture.mdc
│   │   ├── 03-testing.mdc
│   │   ├── 04-git-workflow.mdc
│   │   ├── 05-security.mdc            # OWASP Top 10 — always loaded
│   │   └── skills/                    # Auto-activate by file glob (22 files)
│   │       ├── lang-*.mdc             # Java, .NET, Python, TypeScript, Go
│   │       ├── fe-*.mdc               # React, Next.js, Vue, Angular
│   │       ├── mobile-*.mdc           # iOS, Android, Flutter, React Native, KMP
│   │       ├── devops-*.mdc           # Docker, CI/CD, AWS, GCP, On-Prem
│   │       ├── db-migrations.mdc
│   │       ├── be-microservices.mdc
│   │       ├── docs-generation.mdc
│   │       └── security-sast.mdc
│   └── mcp.json                       # MCP servers: GitHub, Jira, Linear, Slack, Sentry…
│
├── .continue/
│   ├── config.yaml                    # ← ADD API KEYS + uncomment your skills
│   └── rules/
│       ├── 01-coding-standards.md … 04-security.md
│       └── skills/                    # 22 files — mirror of .cursor/rules/skills/
│
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── ISSUE_TEMPLATE/
│   └── workflows/ci.yml               # CI template — adapt for your stack
│
├── docs/
│   ├── guides/                        # Initium-provided guidance — customize freely
│   │   ├── ai-workflow.md             # AI-Native development workflow (English)
│   │   ├── ai-workflow.tr.md          # AI-Native development workflow (Turkish)
│   │   ├── onboarding.md              # New developer onboarding guide
│   │   ├── team.md                    # Team roles and AI-native optimization
│   │   ├── agent/                     # Autonomous agent documentation
│   │   │   ├── autonomous-workflow.md    # State machine, phases, gates, resume
│   │   │   ├── escalation-protocol.md    # Triggers, severity levels, human responses
│   │   │   ├── security-evaluator.md     # Security integration in the agent loop
│   │   │   ├── documentation-agent.md    # Documentation generation architecture
│   │   │   ├── jira-server-setup.md      # On-premise Jira Server operator guide
│   │   │   ├── decision-log-template.md  # Audit trail schema
│   │   │   └── schemas/                  # JSON schemas: task-state, qa-report, security-report…
│   │   └── workflows/                 # Detailed workflow guides (7 files)
│   │       ├── 01 … 04               # Requirements, feature dev, testing, deployment
│   │       ├── 05-security-evaluation.md
│   │       ├── 06-database-migrations.md
│   │       └── 07-deployment-platforms.md
│   ├── context/                       # ← CUSTOMIZE — AI context for tools and agent
│   │   ├── project-brief.md
│   │   ├── tech-stack.md
│   │   ├── domain-glossary.md
│   │   └── domain-boundaries.md      # ← CRITICAL for autonomous agent triage
│   └── architecture/
│       ├── overview.md               # ← CUSTOMIZE — system architecture
│       └── decisions/                # Architecture Decision Records (ADR)
│
├── skills/
│   └── README.md                     # Skills index, activation guide, how to add new skills
│
├── .agent/
│   ├── tasks/                        # ← Per-feature task files created by /task plan
│   │   ├── TASK-001-*.md             #   One file per task: status, AC, dependencies
│   │   └── INDEX.md                  #   Execution order and progress summary
│   ├── outputs/                      # Agent pipeline artifacts (requirements, design, QA JSONs)
│   └── audit/                        # JSONL audit trail of all agent actions
│
├── .agent-templates/
│   └── webhook-receiver.mjs          # Jira Server webhook receiver (copy to .agent/)
│
└── .initium/
    ├── initium.json                 # Tracks which Initium version this project is based on
    ├── scripts/
    │   ├── setup.{sh,cmd,ps1}       # Step 1 — initialize project
    │   ├── init.{sh,cmd,ps1}        # Step 2 — interactive configuration wizard
    │   ├── validate.{sh,cmd,ps1}    # 128-point configuration validator
    │   └── sync.{sh,ps1,cmd}        # Pull upstream Initium improvements
    └── docs/
        ├── sync-guide.md            # Sync guide and merge strategies
        └── UPDATES.md               # Migration notes for each Initium version
```

---

## Slash Commands Reference

### Help & Navigation

| Command | Purpose |
|---------|---------|
| `/help` | Show all available commands and the typical workflow |
| `/help <question>` | Get directed to the right command for your specific situation |
| `/help <phase>` | "how do I start a feature?" — prints the step-by-step command sequence for that phase |

> **Tip for newcomers:** `/help` is always your first command when you're unsure what to do next. Describe your situation in plain language and the AI will point you to the right workflow and commands.

### Initialization

| Command | Purpose |
|---------|---------|
| `/init <description>` | Populate all TODO files from a free-form project description |
| `/init domain: <desc>` | Generate domain boundaries, glossary, and agent scope keywords |
| `/init stack: <stack>` | Generate tech stack doc and CLAUDE.md commands section |
| `/init ci: <stack>` | Generate real CI workflow steps for your language and deploy target |
| `/init agent: <keys>` | Configure tracker keys, GitHub owner/repo, escalation channels |

### Human-Guided Development

| Command | Purpose | When |
|---------|---------|------|
| `/requirements` | → user stories + acceptance criteria + ordered task backlog + DoD | Before any feature |
| `/architect` | Design before a single line of code | Tasks > 50 lines |
| `/task plan` | Break design output into tracked `.agent/tasks/*.md` files | After architect, before coding |
| `/task next` | Get the next actionable task respecting dependencies | During implementation |
| `/task done <id>` | Mark a task complete and unblock dependents | After each commit |
| `/task list` | Show all tasks and their status | Anytime |
| `/task status` | Progress dashboard with percentage and critical path | Anytime |
| `/implement` | Bottom-up implementation with self-review | During coding |
| `/qa` | Lint + types + tests + coverage + security | Before opening PR |
| `/security-audit [target]` | OWASP Top 10 + CVE + secret scan | Before every PR |
| `/review` | Code review against standards and OWASP | After implementation |
| `/test` | Generate comprehensive tests (happy path + edges + errors) | Any module |
| `/debug` | Systematic diagnosis: hypotheses → fix → prevention | When stuck |
| `/deploy` | Pre-deploy checklist + execution steps + monitoring plan | Before every deploy |
| `/infra <platform>` | Scaffold Terraform / K8s / CI for AWS, GCP, or on-prem | New deployment target |
| `/migrate` | Safe DB migration: Expand-Contract + batch + rollback | Schema changes |
| `/db <subcommand>` | Database lifecycle: `init`, `create`, `dml`, `seed`, `status`, `diff` | DB management |
| `/sprint` | Sprint planning: capacity + backlog + tasks + risk register | Sprint kickoff |
| `/standup` | Daily summary from git history | Start of day |
| `/docs <file>` | Generate code-level documentation (JSDoc, docstrings, GoDoc…) | After implementation |

### Documentation Generation

| Command | Purpose | Output |
|---------|---------|--------|
| `/doc-api` | Generate OpenAPI 3.x spec + validate + ReDoc HTML | `openapi.json` + `docs/api/` |
| `/doc-diagrams` | Generate Mermaid sequence diagrams for API calls and business flows | `docs/diagrams/` |
| `/doc-site` | Scaffold or rebuild docs website (Docusaurus / MkDocs) | Deployable static site |
| `/doc-changelog` | Generate `CHANGELOG.md` from git history (git-cliff) | `CHANGELOG.md` + stakeholder summary |
| `/doc-schema` | Database ERD + table reference + index analysis | `docs/database/` |

### Autonomous Agent

| Command | Purpose |
|---------|---------|
| `/triage <issue>` | Domain relevance check: auto-accept ≥ 0.80, escalate 0.30–0.79, reject < 0.30 |
| `/groom` | Batch-process backlog: triage + requirements for each accepted issue |
| `/loop <task-id>` | Full autonomous loop: design → implement → docs → QA → security → PR → deploy |
| `/escalate <sev> <trigger> <id>` | Structured human notification with Slack/GitHub/email routing |

### Initium Maintenance

| Command | Purpose |
|---------|---------|
| `/sync-initium` | Pull improvements from upstream Initium into this project |
| `/sync-initium --dry-run` | Preview what would change without applying anything |
| `/sync-initium --check` | Check if an Initium update is available |

---

## Autonomous Agent Loop

```
JIRA / Linear / GitHub Issues
    │
    ▼ /groom (scheduled or webhook)
    ▼ /triage — confidence scoring
    │   Entity match +0.30 · Functional area +0.40 · Code ownership +0.20
    │   ≥ 0.80 → ACCEPT   0.30–0.79 → ESCALATE   < 0.30 → REJECT
    ▼
    ▼ /requirements — user stories + task backlog (JSON + Markdown)
    ▼ /architect — design doc + risk level
    │   risk=HIGH → human approval gate (AGENT_APPROVE_DESIGN)
    ▼ /task plan — materialize tasks into .agent/tasks/*.md files
    │   each file: status, acceptance criteria, dependencies
    ▼
    ▼ /loop per task (reads .agent/tasks/ if present):
    │   /task next → implement → /docs → test → /task done → next task
    │   fail? → /debug (max retries) → escalate
    ▼ docs sync (conditional):
    │   apiChanges → /doc-api diff · schemaChanges → /doc-schema migrations
    ▼ /qa — lint + types + coverage + security
    ▼ /security-audit diff — OWASP + CVE check
    ▼ PR created (linked to issue, QA report, risk level)
    ▼ CI monitored → merge (auto or human)
    ▼ /deploy staging (auto) → production (human gate)
    ▼ 30-min post-deploy monitoring
    │   metric spike → auto-rollback + critical escalation
    ▼ Issue tracker: Done ✓ · Audit log written
```

**Safety:** persistent state (resume on crash) · kill switch (`touch .agent/STOP`) · protected paths · JSONL audit trail

**Human response commands** (post on GitHub issue or JIRA ticket):
`AGENT_RESUME` · `AGENT_APPROVE_DESIGN` · `AGENT_APPROVE_DEPLOY` · `AGENT_CLARIFY: <text>` · `AGENT_SKIP_TASK` · `AGENT_REASSIGN` · `AGENT_ABANDON`

---

## Language & Framework Skills

Skills provide deep, idiomatic guidance. Cursor auto-activates by file glob; Continue requires uncommenting in `.continue/config.yaml`.

| Category | Skills |
|----------|--------|
| **Backend** | Java/Spring Boot · .NET/ASP.NET Core · Python/FastAPI · TypeScript/Node.js · Go |
| **Frontend** | React · Next.js App Router · Vue 3 · Angular 17+ |
| **Mobile** | iOS/Swift · Android/Kotlin · Kotlin Multiplatform · Flutter/Dart · React Native/Expo |
| **Infrastructure** | Docker · GitHub Actions CI/CD · AWS · GCP · On-Premise (k3s/Vault/Ansible) |
| **Cross-cutting** | Database Migrations · Microservices · Security SAST · Documentation Generation |

See [skills/README.md](skills/README.md) for the full index, activation guide, and how to add new skills.

---

## MCP Servers

Configured in `.cursor/mcp.json`. Enable a server: remove `"disabled": true` and set its env vars.

| Server | Purpose | Env vars |
|--------|---------|---------|
| `filesystem` · `git` | Workspace files, git history | — (auto) |
| `github` | Issues, PRs, CI status | `GITHUB_TOKEN` |
| `jira` | Pull/update issues — used by `/triage`, `/groom` | `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` |
| `linear` | Alternative to Jira | `LINEAR_API_KEY` |
| `slack` | Escalation notifications | `SLACK_BOT_TOKEN`, `SLACK_TEAM_ID` |
| `sentry` | Post-deploy error monitoring | `SENTRY_AUTH_TOKEN`, `SENTRY_ORG` |
| `postgres` · `brave-search` · `memory` · `puppeteer` | DB inspection, web search, memory, browser automation | see `.cursor/mcp.json` |

---

## Keeping Your Project Up to Date

When Initium receives improvements (new commands, updated skill rules, security fixes):

```bash
# macOS / Linux / Git Bash
bash .initium/scripts/sync.sh          # interactive: shows diff, auto-applies safe files
bash .initium/scripts/sync.sh --auto   # non-interactive: apply all skeleton-owned files
bash .initium/scripts/sync.sh --check  # just check if an update is available
```

```powershell
# Windows (PowerShell — recommended)
.\.initium\scripts\sync.ps1            # interactive
.\.initium\scripts\sync.ps1 -Auto     # non-interactive
.\.initium\scripts\sync.ps1 -Check    # check only
```

```bat
:: Windows (Batch — delegates to PowerShell automatically)
.initium\scripts\sync.cmd
.initium\scripts\sync.cmd --auto
.initium\scripts\sync.cmd --check
```

The sync script uses `.initium/initium.json` to classify every file:
- **Initium-owned** (commands, skill rules, agent docs) → auto-applied safely
- **merge-required** (`.continue/config.yaml`, `mcp.json`, `ci.yml`) → shown as diff, you decide
- **project-owned** (`CLAUDE.md`, `docs/context/`, `agent.config.yaml`) → never touched

See [.initium/docs/sync-guide.md](.initium/docs/sync-guide.md) for the full guide, including merge strategies for each file type and how to maintain an organizational fork.

---

## Core Principles

1. **Context is everything.** AI produces better output when it understands your project's purpose and constraints. The `docs/context/` files and skill rules exist to provide this context persistently — no need to repeat it in every prompt.

2. **Rules over repetition.** Define standards once in skill files. "Use constructor injection", "always write tests", "parameterize all queries" — say it once, every session enforces it.

3. **Structured workflows.** Slash commands encode recurring workflows so AI executes them consistently — from a raw requirement to a merged, deployed, documented PR.

4. **Humans set limits, agents execute.** The agent acts autonomously within configured thresholds. Every risky decision (high-risk design, production deploy) requires human approval. Every action is logged.

---

## Further Reading

| Document | Contents |
|----------|---------|
| [docs/guides/ai-workflow.md](docs/guides/ai-workflow.md) | Full AI-Native development workflow reference |
| [docs/guides/team.md](docs/guides/team.md) | Team roles, structure, and optimization for AI-native development |
| [docs/guides/team.tr.md](docs/guides/team.tr.md) | Ekip rolleri ve optimizasyon kılavuzu (Türkçe) |
| [docs/guides/onboarding.md](docs/guides/onboarding.md) | New developer setup guide |
| [docs/guides/onboarding.tr.md](docs/guides/onboarding.tr.md) | Yeni geliştirici kurulum kılavuzu (Türkçe) |
| [.initium/docs/sync-guide.md](.initium/docs/sync-guide.md) | How to apply Initium updates to your project |
| [docs/guides/agent/autonomous-workflow.md](docs/guides/agent/autonomous-workflow.md) | Agent state machine, phases, gates |
| [docs/guides/agent/jira-server-setup.md](docs/guides/agent/jira-server-setup.md) | On-premise Jira Server operator guide |
| [docs/guides/agent/security-evaluator.md](docs/guides/agent/security-evaluator.md) | Security evaluation architecture |
| [docs/guides/agent/documentation-agent.md](docs/guides/agent/documentation-agent.md) | Documentation generation tools and pipeline |
| [skills/README.md](skills/README.md) | Complete skills index and activation guide |
| [.initium/docs/UPDATES.md](.initium/docs/UPDATES.md) | Changelog for Initium versions |
