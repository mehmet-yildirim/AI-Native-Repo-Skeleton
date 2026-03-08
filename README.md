# AI-Native Repository Skeleton

A production-ready repository skeleton for **AI-Native agentic development**, providing pre-configured rules, guidelines, and tooling for [Cursor](https://cursor.sh), [Continue](https://continue.dev), and [Claude Code](https://claude.ai/code).

## What This Provides

| Tool | Config Location | Purpose |
|------|----------------|---------|
| **Claude Code** | `CLAUDE.md`, `.claude/` | Project instructions, custom slash commands |
| **Cursor** | `.cursor/rules/` | Contextual rules (`.mdc` format) |
| **Continue** | `.continue/` | Model config, inline rules |
| **GitHub** | `.github/` | PR templates, issue templates, CI |
| **All editors** | `.editorconfig` | Consistent formatting |

## Quick Start

```bash
# 1. Clone the skeleton
git clone <this-repo> my-project
cd my-project

# 2. Run setup (initializes git, removes skeleton remote)
./scripts/setup.sh

# 3. Customize for your project
#    - Edit CLAUDE.md with your project context
#    - Update .cursor/rules/00-project-overview.mdc
#    - Update .continue/config.yaml with your models
#    - Update docs/context/ with project details
#    - Edit .github/workflows/ci.yml for your stack

# 4. Start coding with AI assistance
```

## Repository Structure

```
.
├── CLAUDE.md                               # Claude Code instructions (CUSTOMIZE THIS)
├── .cursor/
│   ├── rules/
│   │   ├── 00-project-overview.mdc        # Project context (CUSTOMIZE THIS)
│   │   ├── 01-coding-standards.mdc        # Coding standards
│   │   ├── 02-architecture.mdc            # Architecture guidelines
│   │   ├── 03-testing.mdc                 # Testing guidelines
│   │   ├── 04-git-workflow.mdc            # Git & PR workflow
│   │   ├── 05-security.mdc               # Security guidelines (OWASP)
│   │   └── skills/                        # Language & framework skills
│   │       ├── lang-java.mdc             # Java / Spring Boot
│   │       ├── lang-dotnet.mdc           # .NET / ASP.NET Core
│   │       ├── lang-python.mdc           # Python / FastAPI
│   │       ├── lang-typescript.mdc       # TypeScript / Node.js
│   │       ├── lang-go.mdc               # Go
│   │       ├── fe-react.mdc              # React
│   │       ├── fe-nextjs.mdc             # Next.js App Router
│   │       ├── fe-vue.mdc                # Vue 3
│   │       ├── fe-angular.mdc            # Angular 17+
│   │       ├── be-microservices.mdc      # Microservices patterns
│   │       ├── devops-docker.mdc         # Docker & containers
│   │       └── devops-cicd.mdc           # CI/CD pipelines
│   └── mcp.json                           # MCP server configuration
├── .continue/
│   ├── config.yaml                        # Continue plugin config (CUSTOMIZE MODELS)
│   └── rules/
│       ├── 01-coding-standards.md
│       ├── 02-architecture.md
│       ├── 03-testing.md
│       ├── 04-security.md
│       └── skills/                        # Language/framework rules for Continue
│           ├── lang-java.md
│           ├── lang-dotnet.md
│           ├── lang-python.md
│           ├── fe-react.md
│           ├── fe-nextjs.md
│           ├── fe-vue.md
│           └── fe-angular.md
├── .claude/
│   └── commands/                          # Custom Claude Code slash commands
│       ├── requirements.md               # /requirements - analyze & decompose
│       ├── architect.md                  # /architect - design before coding
│       ├── implement.md                  # /implement - structured implementation
│       ├── review.md                     # /review - code review
│       ├── qa.md                         # /qa - full quality assurance cycle
│       ├── test.md                       # /test - generate tests
│       ├── debug.md                      # /debug - systematic debugging
│       ├── deploy.md                     # /deploy - deployment preparation
│       ├── migrate.md                    # /migrate - database migration
│       ├── sprint.md                     # /sprint - sprint planning
│       ├── docs.md                       # /docs - generate documentation
│       └── standup.md                    # /standup - daily summary
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── ISSUE_TEMPLATE/
│   └── workflows/ci.yml
├── docs/
│   ├── ai-workflow.md                     # AI-Native development guide
│   ├── onboarding.md                      # Team onboarding
│   ├── context/                           # AI context documents (CUSTOMIZE)
│   ├── architecture/
│   │   ├── overview.md
│   │   └── decisions/                     # Architecture Decision Records
│   └── workflows/                         # Agentic workflow guides
│       ├── 01-requirements-analysis.md
│       ├── 02-feature-development.md
│       ├── 03-testing-strategy.md
│       └── 04-deployment.md
├── skills/
│   └── README.md                          # Skills index & activation guide
└── scripts/
    ├── setup.sh                           # One-time project setup
    └── validate-ai-config.sh              # Validate AI tool configurations
```

## Customization Checklist

After checkout, complete these steps before writing code:

### Required
- [ ] `CLAUDE.md` — fill in project name, stack, key commands, conventions
- [ ] `.cursor/rules/00-project-overview.mdc` — project context for Cursor
- [ ] `.continue/config.yaml` — add your API keys / model preferences
- [ ] `docs/context/project-brief.md` — describe what the project does
- [ ] `docs/context/tech-stack.md` — list your technology choices
- [ ] `docs/architecture/overview.md` — high-level architecture

### Recommended
- [ ] `docs/context/domain-glossary.md` — domain-specific terminology
- [ ] `.github/workflows/ci.yml` — adapt to your language/framework
- [ ] `.cursor/rules/01-coding-standards.mdc` — language-specific standards
- [ ] `.cursor/mcp.json` — enable MCP servers you use

## Agentic Development Workflow

The skeleton encodes a complete **requirements → code → test → deploy** agentic loop:

```
/requirements  →  /architect  →  /implement  →  /qa  →  /review  →  /deploy
     │                │               │            │         │            │
  User stories    Design doc      Code + tests   Quality   PR review   Prod deploy
  Task backlog    before code     bottom-up      gates     checklist   checklist
```

### Slash Commands Reference

| Command | Purpose | When to use |
|---------|---------|------------|
| `/requirements` | Decompose requirements into stories, tasks, DoD | Before starting any feature |
| `/architect` | Design implementation before writing code | For tasks > 50 lines |
| `/implement` | Structured implementation with built-in review | During coding |
| `/qa` | Full QA: lint, tests, coverage, security audit | Before opening PR |
| `/review` | Deep code review against project standards | After implementation |
| `/test` | Generate comprehensive test suite | For any module |
| `/debug` | Systematic bug diagnosis | When stuck on a bug |
| `/deploy` | Pre-deploy checklist + monitoring plan | Before every deploy |
| `/migrate` | Safe database migration planning | For schema changes |
| `/sprint` | Sprint planning from backlog | Sprint kickoff |
| `/docs` | Generate API/module documentation | After implementation |
| `/standup` | Summarize recent work from git history | Daily standup |

## Language & Framework Skills

Skills provide deep, language-specific guidance. They activate automatically in Cursor
(via file globs) and are manually enabled in Continue (via `config.yaml`).

| Skill | Languages / Frameworks |
|-------|----------------------|
| Backend | Java/Spring Boot, .NET/ASP.NET Core, Python/FastAPI, TypeScript/Node.js, Go |
| Frontend | React, Next.js (App Router), Vue 3, Angular 17+ |
| Infrastructure | Docker, CI/CD (GitHub Actions), Microservices |

See `skills/README.md` for the full index and activation instructions.

## AI-Native Development Philosophy

This skeleton is built on four principles:

1. **Context is everything.** AI tools produce better output when they understand your project's purpose, constraints, and conventions. The `docs/context/` directory and rules files exist to provide this context.

2. **Rules over repetition.** Define standards once in skill files so you never repeat "use Spring Boot constructor injection" or "always write tests" in every prompt.

3. **Structured workflows.** Custom slash commands encode your team's recurring workflows (requirements → design → implement → QA → deploy) so AI agents execute them consistently.

4. **Humans review, machines execute.** AI generates; developers verify. Every AI output is reviewed before merging. The quality gates (`/qa`, `/review`) exist to catch what AI misses.

## Contributing

See [docs/ai-workflow.md](docs/ai-workflow.md) for the AI-Native development workflow used to maintain this skeleton.
