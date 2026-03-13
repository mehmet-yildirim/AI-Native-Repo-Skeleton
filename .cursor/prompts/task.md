# /task — Implementation Task Planning

Create and manage implementation task files before development begins.

Task files live in `.agent/tasks/` as individual Markdown files, bridging the gap between
a design document (from `/architect` or `/requirements`) and actual coding (in `/implement`).

---

## How to Use This Prompt

Reference this file in Cursor chat:

```
@.cursor/prompts/task.md

plan  [paste your architect/requirements output or task list here]
```

Or for other subcommands:
```
@.cursor/prompts/task.md  list
@.cursor/prompts/task.md  next
@.cursor/prompts/task.md  done TASK-003
@.cursor/prompts/task.md  status
```

---

## Subcommand: plan

Generate individual task files from a design or requirements output.

**Step 1: Locate source material**

Look for (in priority order):
1. Pasted design doc or architect output in this prompt
2. `.agent/outputs/<task-id>-design.json`
3. `.agent/outputs/<task-id>-requirements.json`

If nothing found: "No source found. Run `/architect` or `/requirements` first, or paste your task list."

**Step 2: Parse tasks**

Each task must have:
- **ID**: `TASK-001`, `TASK-002`, ...
- **Title**: concise action phrase
- **Type**: `feat` | `fix` | `chore` | `refactor`
- **Layer**: `backend` | `frontend` | `infra` | `mobile` | `full-stack`
- **Estimate**: `XS` (< 2h) | `S` (< 4h) | `M` (< 1d) | `L` (< 3d)
- **Depends on**: other TASK-IDs (empty if none)
- **Description**: what to build, in enough detail to start without further questions
- **Acceptance criteria**: specific, testable "done" conditions
- **Files to change**: file paths from the design (best-effort)

Split any `XL` task before writing its file.

**Step 3: Create task files**

```bash
mkdir -p .agent/tasks
```

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

<Detail of what needs to be built or changed.>

## Acceptance Criteria

- [ ] <Specific, testable criterion>
- [ ] Tests written and passing
- [ ] Code reviewed and approved

## Files to Change

- `path/to/file.ts` — <what changes>

## Notes

<Implementation hints, gotchas, design references.>
```

**Step 4: Write `.agent/tasks/INDEX.md`**

```markdown
# Task Index

Feature: <name>
Date: <ISO date>
Total: N tasks

| ID | Title | Layer | Est | Status | Depends On |
|----|-------|-------|-----|--------|------------|
| [TASK-001](TASK-001-slug.md) | ... | backend | S | todo | — |
...

## Execution Order

1. TASK-001 — (no dependencies)
2. TASK-002 — (after TASK-001)
...
```

**Step 5: Confirm output**

```
Task plan created: .agent/tasks/
  TASK-001  <title>  [S]  todo
  TASK-002  <title>  [M]  todo (after TASK-001)
  ...

Total: N tasks | Estimated: Xh–Yh
Next: TASK-001 — <title>
```

---

## Subcommand: list

Read all files in `.agent/tasks/*.md` and print status summary.

```
.agent/tasks — N tasks

  ✅ TASK-001  [S]  <title>
  🔄 TASK-002  [M]  <title>  ← in progress
  ⏳ TASK-003  [M]  <title>  (blocked: TASK-002)
  ⬜ TASK-004  [XS] <title>

Progress: 1/4 complete | 1 in progress | 1 blocked | 1 todo
```

---

## Subcommand: next

Find the next actionable task:
1. Filter to `status: todo`
2. Exclude tasks whose `depends_on` tasks are not `done`
3. Return the first in dependency-topological order

Output:
```
Next task: TASK-002 — <title>
Layer: backend | Estimate: M

<full task file content>

To start: implement TASK-002 using @.cursor/prompts/implement.md
```

---

## Subcommand: done <TASK-ID>

Mark task as complete:
1. Find `.agent/tasks/TASK-XXX-*.md`
2. Set `status: done`, add `completed: <ISO date>`
3. Print: `✅ TASK-002 done. Next: TASK-003 (now unblocked)`

---

## Subcommand: status

Print progress dashboard with counts, percentage bar, current/next/blocked tasks.

---

## Integration Notes

- Use **after** `@.cursor/prompts/architect.md` and **before** `@.cursor/prompts/implement.md`
- Each task file maps to one implementation session and one PR
- In autonomous workflows: task files allow the agent to resume mid-feature by checking status
