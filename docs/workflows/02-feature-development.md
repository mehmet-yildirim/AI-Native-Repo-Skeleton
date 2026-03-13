# Workflow: Feature Development

The end-to-end AI-assisted workflow for implementing a feature from approved specification to merged PR.

## Prerequisites

Before starting development:
- [ ] Approved specification exists (see `01-requirements-analysis.md`)
- [ ] Task is sized S or M (L tasks need to be split into multiple PRs)
- [ ] Branch created: `git checkout -b feat/PROJ-42-feature-name`
- [ ] Local environment running and tests passing on main

## The Workflow

```
Approved Spec
    │
    ├─ Step 1: Design          /architect → design doc
    ├─ Step 2: Task Planning   /task plan → .agent/tasks/*.md
    ├─ Step 3: Implement       /implement per task → code + tests
    ├─ Step 4: QA              /qa → quality gates
    ├─ Step 5: Self-Review     /review → final check
    └─ Step 6: PR & Merge      → deployed to staging
```

## Step 1: Design (/architect)

For any implementation > 50 lines of net-new code:

```
/architect <paste task description from approved spec>
```

Review the design output. Approve before coding:
- Does the approach fit our architecture (layer boundaries, patterns)?
- Are all edge cases in the spec covered by the design?
- Is the implementation checklist complete and correctly ordered?
- Are there risks that need escalation?

**Rule**: Do not write production code until the design is approved.

## Step 2: Task Planning (/task plan)

After the design is approved, materialize the implementation checklist into individual task files:

```
/task plan <paste the design output or provide the design file path>
```

This creates `.agent/tasks/TASK-001-*.md` files — one file per task — each with:
- Status (`todo` / `in_progress` / `done`)
- Acceptance criteria
- Files to change
- Dependencies (which tasks must be done first)

**Why this step matters:**
- Gives you a clear, trackable work breakdown before touching code
- Enables bit-by-bit implementation — complete one task, commit, then move to the next
- Allows resuming mid-feature: check `status` to see where you left off
- In autonomous mode, the `/loop` command reads task files to drive execution

```bash
# After planning, inspect what was created
/task list

# Get the first task to work on
/task next
```

**Rule**: For features with ≥ 3 tasks, always create task files before implementing.
Single-task fixes may skip this step.

## Step 3: Implement (/implement) — Per Task

Work through tasks one at a time in dependency order:

```
/task next                          # find the next actionable task
/implement TASK-001: <task title>   # implement that specific task
/task done TASK-001                 # mark it complete
/task next                          # get the next one
```

### Implementation discipline
- Implement bottom-up: types → domain logic → data access → service → API/UI
- Work task by task — do not start the next task until the current one compiles and its tests pass
- Write tests for each layer as you implement it — do not defer testing
- Keep each step small enough to compile and run tests
- Commit each completed task: `git commit -m "feat(users): add CreateUser use case"`
- After each commit: `/task done TASK-XXX`

### Working with AI during implementation
- Give AI one task at a time — not the entire feature at once
- After each generated file, read every line. Do not merge code you don't understand.
- If AI goes off-track (wrong pattern, unnecessary abstraction): stop and correct immediately
- Use `@filename` in Cursor / Continue to provide context from related files

### When AI output needs correction
```
"That approach doesn't match our architecture. We use repository pattern, not direct DB calls
in the service. Re-implement the UserService using the UserRepository interface."
```

## Step 4: QA (/qa)

Before creating a PR, run the full QA cycle:

```
/qa
```

This checks: lint, type safety, test coverage, security, code quality, API contract.

**Block yourself from opening a PR if:**
- Any test fails
- Lint errors exist
- Type errors exist
- Coverage dropped below threshold
- Any CRITICAL security finding

## Step 5: Self-Review (/review)

```
/review
```

Read the review output and address each issue before opening the PR.
Also run a personal diff review:

```bash
git diff origin/main...HEAD
```

Ask yourself for each change:
- Do I understand why this line exists?
- Would I be comfortable explaining this in a code review?
- Is this the simplest solution?

## Step 6: PR Creation

```bash
gh pr create --fill
```

The PR template will prompt for: summary, type of change, test instructions, checklist.

**PR description must include:**
- Link to the spec or ticket
- Summary of what was built
- How to test it manually
- Any deployment notes (migrations, config changes, feature flags)

### PR Size Rules
- Aim for < 400 lines changed
- If larger: split into stacked PRs (infrastructure PR first, then feature PR)
- Large PRs slow down review and increase merge conflict risk

## Parallel Development Patterns

### Stacked PRs (feature → depends on → infrastructure)
```
main
  └─ feat/users-repo          # PR 1: repository + DB migration
       └─ feat/users-service  # PR 2: service layer (depends on PR 1)
            └─ feat/users-api # PR 3: API endpoint (depends on PR 2)
```

### Feature flags for long-running features
- Merge incomplete features behind a flag to keep branches short-lived
- Enable flag in dev; only enable in production when ready to release

## Handling Blockers

If blocked during implementation:
1. Use `/debug` for technical issues
2. Use `/architect` to reconsider the approach
3. Document the blocker and ask for help — do not keep trying the same thing
4. Timebox spikes: if blocked for > 2 hours, escalate

## Definition of "Implementation Complete"

- [ ] All acceptance criteria from the spec are implemented
- [ ] All tests pass (`bun test` / `pytest` / `go test ./...`)
- [ ] No lint or type errors
- [ ] /qa report: no CRITICAL or MAJOR issues
- [ ] /review report: no blockers
- [ ] PR created with complete description
- [ ] Deployed to staging (automatic after merge to main)
- [ ] Smoke-tested on staging
