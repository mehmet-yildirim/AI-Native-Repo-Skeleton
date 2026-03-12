Initialize this project from the skeleton by populating all TODO placeholder files based on the provided description.

This prompt accepts either a **full project description** (populates everything at once) or a
**targeted scope keyword** followed by the relevant details (populates only that section).

---

## Usage

**Full initialization** — describe your project and Cursor populates all TODO files:
```
@.cursor/prompts/init.md

I'm building a multi-tenant inventory management API for e-commerce merchants.
Tech stack: TypeScript, Fastify, PostgreSQL, Drizzle ORM.
GitHub project, Slack for alerts.
```

**Targeted initialization** — populate only a specific section:
```
@.cursor/prompts/init.md

domain: Order management platform handling cart, checkout, payment, and fulfilment for B2C merchants
```

```
@.cursor/prompts/init.md

stack: Go, Gin, PostgreSQL, GitHub Actions, Docker, AWS ECS
```

```
@.cursor/prompts/init.md

agent: JIRA project key ORD, escalation via Slack #dev-alerts, GitHub owner acme/order-service
```

Multiple scopes in one call:
```
@.cursor/prompts/init.md

domain: ... | stack: ... | agent: ...
```

---

## Step 1: Parse Input

Identify the mode:

- If the input starts with a known scope keyword (`domain:`, `stack:`, `ci:`, `agent:`, `glossary:`) →
  **targeted mode**: only populate the matching sections listed below
- Otherwise → **full mode**: populate all TODO files

For **full mode**, extract from the description:
- Project name, type, primary language and framework, database, auth, testing, deployment target
- Issue tracker (JIRA / Linear / GitHub Issues)
- Business domain, core entities, explicit out-of-scope areas

If critical information is missing (name, type, domain, primary language), ask up to 4
clarifying questions before proceeding. Do not ask for what can be reasonably inferred.

---

## Step 2: Generate File Contents

For each file, read the current content via `@` reference, then replace every TODO section
with project-specific content. Preserve all existing structure and comments.

### 2a. `@CLAUDE.md`
- Project name, type, purpose, language, framework, runtime
- Actual commands for the detected stack (install / dev / test / lint / build)
- Repository layout for the detected pattern
- Architecture bullets, naming conventions, domain glossary (top 5–8 terms)

### 2b. `@.cursor/rules/00-project-overview.mdc`
- Name, type, purpose
- Technology stack table (all rows)
- Repository layout
- Key constraints inferred from the description
- Domain glossary

### 2c. `@docs/context/project-brief.md`
- Project description (2–3 sentences)
- User types inferred from domain
- Core features (5–7 capabilities)
- Out-of-scope areas
- Key business invariants (3–5 rules)

### 2d. `@docs/context/domain-boundaries.md` ← **Most critical for the autonomous agent**
- One-sentence domain statement
- In-scope domains (3–6 functional areas with descriptions)
- Plausible API endpoints for the domain
- Owned data tables / collections
- 4–5 ✅ in-scope request examples
- 4–6 out-of-scope domains with team owners
- 3–4 external integrations
- 4–5 ❌ out-of-scope request examples with suggested owners
- 3–5 ambiguous boundary cases
- Domain confidence keywords (8–15 in-domain, 6–10 out-of-domain)
- Core entity names (PascalCase list)
- Set `**Last reviewed:**` to today's date

### 2e. `@docs/context/domain-glossary.md`
- 10–20 domain terms, entities, acronyms, and processes
- Format: `| Term | Definition | Example |`

### 2f. `@docs/context/tech-stack.md`
- Full technology stack table: Language, Framework, Database, ORM, Auth, Testing, CI/CD, Container, Deployment
- For unspecified choices: pick the most idiomatic option, note as "recommended default — confirm with team"

### 2g. `@docs/architecture/overview.md`
- System purpose, architecture pattern (MVC / Hexagonal / Clean / CQRS)
- ASCII block diagram of main components
- Data flow for the primary use case
- 2–4 key design decisions

### 2h. `@agent.config.yaml`
Replace only TODO values:
- `agent.id` → `"<project-slug>-agent"`
- `agent.name` → `"<Project Name> Dev Agent"`
- `issue_tracker.provider` → detected tracker
- `jira.project_key` / `linear.team_id` / `github.owner` / `github.repo` → from `agent:` input
- `domain.strong_include_keywords` → in-domain keywords array
- `domain.hard_exclude_keywords` → out-of-scope keywords array
- `escalation.github.assignees` / `escalation.email.to` → from `agent:` input if provided

### 2i. `@.github/workflows/ci.yml` *(targeted with `ci:` scope or full init with clear deployment target)*
Generate real job steps:
- **lint**: setup action for detected runtime → install → lint command
- **test**: install → test with coverage → upload to Codecov
- **security**: dependency audit + Semgrep or Trivy
- **build**: build command + Docker build/push if containerized deployment detected

---

## Step 3: Write All Files

After generating content, write each file. Report status for every file:

```
✅ CLAUDE.md                               — populated (N TODOs resolved)
✅ .cursor/rules/00-project-overview.mdc  — populated
✅ docs/context/project-brief.md          — populated
✅ docs/context/domain-boundaries.md      — populated (critical for agent triage)
✅ docs/context/domain-glossary.md        — generated (N terms)
✅ docs/context/tech-stack.md             — populated
✅ docs/architecture/overview.md          — generated
⚠️  agent.config.yaml                     — partially populated (N TODOs remain)
⚠️  .github/workflows/ci.yml              — skipped (use `ci:` scope to generate)
```

---

## Step 4: Validation

After writing, check for remaining TODOs:

```bash
grep -rn "^TODO\|: TODO\|= \"TODO\"" \
  CLAUDE.md agent.config.yaml docs/context/ docs/architecture/overview.md \
  .cursor/rules/00-project-overview.mdc \
  2>/dev/null | head -40
```

Report the remaining items grouped by file with one-line descriptions of what is still needed.

---

## Step 5: Summary

```
╔══════════════════════════════════════════════════════════════╗
║  PROJECT INITIALIZED: <Project Name>                        ║
╠══════════════════════════════════════════════════════════════╣
║  Files populated:  N                                        ║
║  TODOs resolved:   N                                        ║
║  TODOs remaining:  N (listed above)                         ║
╠══════════════════════════════════════════════════════════════╣
║  NEXT STEPS:                                                ║
║  1. Review generated content — AI inference is not perfect  ║
║  2. Fill remaining TODOs (listed above)                     ║
║  3. Add API keys to .env and .continue/config.yaml          ║
║  4. Run: bash scripts/validate-ai-config.sh                 ║
║  5. Start coding: @.cursor/prompts/requirements.md          ║
╚══════════════════════════════════════════════════════════════╝
```

---

**Project description or targeted scope** (full description, or `domain:` / `stack:` / `ci:` / `agent:` / `glossary:`):
