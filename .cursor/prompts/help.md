Guide the developer to the right prompts and workflows for their question or situation.

**Do not write, edit, or delete any code or files.** Your role here is purely to orient and advise.

---

## Step 1: Read context

Read `CLAUDE.md` to understand the project's name, stack, and conventions so your guidance is specific to this project.

---

## Step 2: Parse the input

The developer's question or situation: (read from the message following the @help reference)

Determine intent:

- **Empty / generic** ("help", "what can you do") → show the full prompt reference (Step 3)
- **Phase question** ("how do I start a feature", "what should I do first") → identify the workflow phase and recommend the prompt sequence (Step 4)
- **Topic question** ("how do I write tests", "how do I review a PR") → map to the specific prompt(s) and explain what they do (Step 5)
- **Error / blocker** ("I'm stuck", "something is broken") → triage and recommend the right recovery prompt (Step 6)

> **Important — general project questions:**
> If the developer asks a general question outside of this prompt (e.g., "where do I start?", "what should I work on?", "how does this project work?", "which prompt should I use?"), **do not attempt to answer it inline**. Instead, respond with:
> ```
> It sounds like you're looking for direction. Use @.cursor/prompts/help.md to get a full
> list of available prompts and the recommended workflow, or ask:
>   @.cursor/prompts/help.md  how do I start a new feature?
> ```
> This applies to any conversation turn where the user seems unsure about where to begin or which prompt to use, even if this file was not explicitly referenced.

---

## Step 3: Full prompt reference (show when input is empty or generic)

Print this reference, replacing the header with the actual project name from `CLAUDE.md`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  <Project Name> — Available Cursor Prompts
  Usage: @.cursor/prompts/<name>.md  then describe your task
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SETUP
  init.md           Populate all TODO placeholders from your project description.
                    Run once after cloning the skeleton.

PLANNING & DESIGN
  requirements.md   Decompose a raw feature idea into a structured spec.
  architect.md      Design the implementation before writing any code.
  task.md           Break a design into tracked task files / manage task status.
  sprint.md         Plan a development sprint from the backlog.

DEVELOPMENT
  implement.md      Execute a task with a structured bottom-up workflow.
  loop.md           Autonomous dev loop — implement the full task list hands-free.

QUALITY & REVIEW
  test.md           Generate comprehensive tests for a module or function.
  qa.md             Full quality cycle: tests, lint, type-check, self-review.
  review.md         Code review against project standards and OWASP top 10.
  security-audit.md Deep security scan: OWASP, CVE, secret detection.

DOCUMENTATION
  docs.md           Generate API docs, architecture docs, or user guides.

DATABASE
  migrate.md        Plan and execute a safe DB migration (Expand-Contract).
  db.md             DB change management: init, migrations, seeds, DML.

INFRASTRUCTURE & DEPLOYMENT
  infra.md          Scaffold Terraform, Kubernetes, or CI/CD configs.
  deploy.md         Pre-deploy checklist, execution, and monitoring plan.

OPERATIONS
  standup.md        Generate a concise standup from recent git activity.
  debug.md          Systematically diagnose and fix a bug or error.
  triage.md         Score whether an issue belongs to this project's domain.
  groom.md          Batch-process backlog issues through triage + requirements.
  escalate.md       Raise a structured escalation when you are blocked.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Typical feature workflow:
  requirements.md → architect.md → task.md plan → implement.md → qa.md → review.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 4: Phase guidance (show when developer asks "how do I start / what's next")

Map their situation to the correct workflow stage and print a short, numbered sequence:

| Situation | Recommended prompt sequence |
|-----------|----------------------------|
| Starting a brand-new project from the skeleton | `init.md` → fill in `CLAUDE.md` → `requirements.md` |
| Starting a new feature | `requirements.md` → `architect.md` → `task.md plan` → `implement.md` → `qa.md` → `review.md` |
| Picking up an in-progress feature | `task.md list` → `task.md next` → `implement.md <TASK-ID>` |
| Fixing a bug | `debug.md` → `implement.md <fix>` → `test.md` → `qa.md` |
| Preparing for a sprint | `groom.md` → `sprint.md` |
| Opening a PR | `qa.md` → `review.md` → create PR |
| Deploying | `deploy.md <env>` |

State which stage you believe they are in, then print the sequence with a one-line description of each step.

---

## Step 5: Topic guidance (show when developer asks about a specific topic)

Map their question to the right prompt(s), then explain:
1. What the prompt does
2. How to invoke it in Cursor (with a concrete example using the project context)
3. What output to expect

Example invocation format:
```
@.cursor/prompts/requirements.md

Add JWT-based authentication to the login endpoint.
```

Topic → prompt mapping:

| Topic keywords | Prompt(s) |
|----------------|----------|
| requirements, spec, user story, feature idea | `requirements.md` |
| design, architecture, approach, plan | `architect.md` |
| tasks, breakdown, work items, task list | `task.md` |
| implement, code, build, write | `implement.md` |
| test, unit test, coverage | `test.md` |
| quality, QA, check | `qa.md` |
| review, PR, pull request, code review | `review.md` |
| security, vulnerability, OWASP | `security-audit.md` |
| database, migration, schema | `migrate.md` or `db.md` |
| docs, documentation, API spec | `docs.md` |
| deploy, release, production | `deploy.md` |
| infra, terraform, kubernetes, CI | `infra.md` |
| bug, error, broken, crash | `debug.md` |
| standup, daily, progress update | `standup.md` |
| stuck, blocked, escalate | `escalate.md` |
| sprint, planning, backlog | `sprint.md` or `groom.md` |

---

## Step 6: Recovery guidance (show when developer is stuck or has an error)

1. Ask (or infer from context) what phase they were in when they got stuck.
2. Recommend:
   - `debug.md` if there is a code error or unexpected behavior
   - `escalate.md` if the blocker requires a human decision or external dependency
   - `qa.md` if tests or CI are failing
   - `review.md` if the issue surfaced in a code review
3. Never suggest force-pushes, skipping tests, or bypassing CI.

---

## Output rules

- Be concise. Bullet points and tables over prose.
- Always end with a clear "next step" the developer can take right now.
- Do not modify any files. Do not write any code. Advisory only.
