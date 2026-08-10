Create and manage implementation task files for a feature before development begins.

Task files are stored in `.agent/tasks/` as individual Markdown files. They are the bridge
between design (output of `/architect`) and execution (input of `/implement` and `/loop`).

Usage:
  /task plan   — Generate task files from a design doc or requirements spec
  /task list   — Show all tasks and their status
  /task next   — Print the next actionable task (lowest dependency, not yet started)
  /task done <TASK-ID>   — Mark a task complete
  /task status — Summary dashboard of all task statuses

---

## Subcommand: plan

Generate individual task files from a design or requirements output.

### Step 1: Locate source material

Look for (in priority order):
1. The design document provided as argument
2. `.agent/outputs/<task-id>-design.json`
3. `.agent/outputs/<task-id>-requirements.json`
4. A pasted implementation checklist or backlog

If none found, produce an error: "No design or requirements source found. Run /architect or /requirements first, or paste the task list."

### Step 2: Parse tasks

Extract every task from the source. Each entry must have:
- **ID**: sequential identifier — `TASK-001`, `TASK-002`, ...
- **Title**: concise action-oriented name
- **Type**: `feat` | `fix` | `chore` | `refactor`
- **Layer**: `backend` | `frontend` | `infra` | `mobile` | `full-stack`
- **Estimate**: `XS` (< 2h) | `S` (< 4h) | `M` (< 1d) | `L` (< 3d)
- **Depends on**: list of TASK-IDs that must be completed first (empty if none)
- **Description**: what exactly needs to be built or changed
- **Acceptance criteria**: specific, testable conditions for "done"
- **Files to change**: known file paths from the design (best-effort)

Flag any task estimated `XL` — it MUST be split before creating its file.

### Step 3: Create the tasks directory

```bash
mkdir -p .agent/tasks
```

### Step 4: Write one file per task

File path: `.agent/tasks/TASK-001-short-slug.md`

File format:

```markdown
---
id: TASK-001
title: <Title>
type: feat | fix | chore | refactor
layer: backend | frontend | infra | mobile | full-stack
estimate: XS | S | M | L
status: todo
depends_on: []
created: <ISO date>
---

## Description

<What needs to be built or changed, in enough detail for an engineer to start without further questions.>

## Acceptance Criteria

- [ ] <Specific, testable criterion>
- [ ] <Specific, testable criterion>
- [ ] Tests written and passing
- [ ] Code reviewed and approved

## Files to Change

- `path/to/file.ts` — <what changes and why>
- `path/to/new-file.ts` — <new file, what it contains>

## Notes

<Any implementation hints, gotchas, or references to design decisions.>
```

### Step 5: Write the task index

After creating all files, write (or overwrite) `.agent/tasks/INDEX.md`:

```markdown
# Task Index

Generated from: <source file or "manual">
Feature: <feature name>
Date: <ISO date>
Total: <N> tasks

| ID | Title | Layer | Est | Status | Depends On |
|----|-------|-------|-----|--------|------------|
| [TASK-001](TASK-001-slug.md) | <title> | backend | S | todo | — |
| [TASK-002](TASK-002-slug.md) | <title> | backend | M | todo | TASK-001 |
...

## Execution Order

<Ordered list respecting dependencies — show the critical path>

1. TASK-001 — <title> (no dependencies)
2. TASK-002 — <title> (after TASK-001)
...
```

### Step 6: Confirm output

Print:
```
Task plan created: .agent/tasks/
  TASK-001  <title>  [S]  todo
  TASK-002  <title>  [M]  todo  (after TASK-001)
  ...

Total: N tasks | Estimated: Xh–Yh
Next: TASK-001 — <title>

Run /task next to get the first task, or /implement TASK-001 to start.
```

---

## Branch Requirement

**Before any implementation begins**, create and switch to a feature branch:

```bash
git checkout -b feat/<feature-slug>
```

- Derive the branch name from the feature name in `INDEX.md` (kebab-case, max 40 chars)
- Use the prefix that matches the task type: `feat/`, `fix/`, `chore/`
- If a branch for this feature already exists, switch to it: `git checkout feat/<feature-slug>`
- Never implement directly on `main` or `develop`

This branch is where all task commits for the feature land.

---

## Subcommand: list

Read all files in `.agent/tasks/*.md` and print their status summary.

Output format:
```
.agent/tasks — N tasks

  ✅ TASK-001  [S]  <title>
  🔄 TASK-002  [M]  <title>  ← in progress
  ⏳ TASK-003  [M]  <title>  (blocked: TASK-002)
  ⬜ TASK-004  [XS] <title>
  ⬜ TASK-005  [S]  <title>

Progress: 1/5 complete | 1 in progress | 1 blocked | 2 todo
```

Status icons:
- `✅` = done
- `🔄` = in_progress
- `⏳` = blocked (dependency not done)
- `⬜` = todo

---

## Subcommand: next

Find and print the next actionable task:
1. Filter to tasks where `status: todo`
2. Exclude tasks with incomplete dependencies (`depends_on` tasks not `done`)
3. Return the first task in dependency-topological order

Output:
```
Next task: TASK-002 — <title>
Layer: backend | Estimate: M

<paste the full task file content>

Branch: feat/<feature-slug>  (create if not yet on it: git checkout -b feat/<feature-slug>)
To start: /implement TASK-002
```

If no tasks remain: "All tasks complete. Run /qa to verify the full feature."
If all remaining tasks are blocked: "All todo tasks are blocked. Complete in-progress tasks first."

---

## Subcommand: done <TASK-ID>

Mark a task file as complete.

1. Find `.agent/tasks/TASK-XXX-*.md`
2. Update frontmatter: `status: done`, add `completed: <ISO date>`
3. Print confirmation:
   ```
   ✅ TASK-002 marked done.
   Next: TASK-003 — <title> (now unblocked)
   ```
4. If this was the last task: "All tasks complete. Run /qa."

---

## Subcommand: status

Print a progress dashboard:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Feature Task Status
  <feature name from INDEX.md>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Total:        8 tasks
  ✅ Done:      3
  🔄 In Progress: 1
  ⏳ Blocked:   1
  ⬜ Todo:      3

  Progress: ███████░░░░░░░░░ 37%

  Current:  TASK-004 — <title>
  Next up:  TASK-005 — <title> (unblocked after TASK-004)
  Blocked:  TASK-007 — <title> (waiting for TASK-005, TASK-006)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Integration with /loop (Autonomous Mode)

When `/loop` processes a task, it should:
1. Check if `.agent/tasks/` exists for the feature
2. If yes, use task files as the source of work items (instead of parsing requirements JSON)
3. After completing each task's implementation: call `/task done <TASK-ID>`
4. After all tasks done: proceed to QA phase

This allows the autonomous loop to resume mid-feature by reading task statuses from files.

---

Arguments: $ARGUMENTS
