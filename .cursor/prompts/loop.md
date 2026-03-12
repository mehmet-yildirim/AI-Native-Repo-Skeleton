Execute the full autonomous development loop for a single task.
Takes a task from requirements output through architecture, implementation, QA, PR creation,
CI monitoring, and post-deploy verification.

This is the core executor. The groom workflow calls it per accepted issue.
It can also be invoked directly for a known task ID.

---

## Safety Pre-checks

Before doing anything:
1. Check for kill switch: if `.agent/STOP` exists → halt and report
2. Load `@agent.config.yaml` and verify all required config is present
3. Check current task count against `max_concurrent_tasks`
4. Read the task state file if it exists (for resume after interruption)

If resuming: skip completed phases, continue from last checkpoint.

---

## Phase 1: Validate Requirements Input

Load `.agent/outputs/<task-id>-requirements.json`.
Verify:
- All tasks are sized ≤ L (XL tasks must be split before proceeding)
- No blocking ambiguities unresolved
- confidence ≥ requirements threshold from agent.config.yaml

If confidence < threshold → escalate using `@.cursor/prompts/escalate.md` with trigger `requirements_confidence_low`

---

## Phase 2: Architecture Design

Apply `@.cursor/prompts/architect.md` for the task, providing:
- Task title and requirements JSON tasks
- Relevant architecture constraints from project rules

Parse the design output for:
- `risk` level (low / medium / high)
- List of files to create and modify
- New dependencies (any new packages?)

**Risk gate:**
- `low` → proceed automatically
- `medium` → escalate with trigger `design_risk_medium` → wait for `AGENT_APPROVE_DESIGN`
- `high` → escalate with trigger `design_risk_high` → BLOCK until approved

Save design to `.agent/outputs/<task-id>-design.json`.
Update task state: phase = `architect`, status = `completed`.

---

## Phase 3: Create Branch

```bash
git checkout main && git pull origin main
git checkout -b <branch-name-from-config-pattern>
```

Branch name pattern from `agent.config.yaml` → `git.branch_pattern`.
Update task state: `branchName = <branch>`.

---

## Phase 4: Implement (Task Loop)

For each task in the requirements output (in dependency order):

### 4a. Implement the task
Apply `@.cursor/prompts/implement.md` for each task with:
- Layer and estimate
- Relevant design context
- Files to change (from design output)

### 4b. Run tests immediately
```bash
<test command from project config>
```

### 4c. Check result

**If tests pass:**
```bash
git add <changed files>
git commit -m "<type>(<scope>): <task title>"
```

**If tests fail (retry loop):**
Apply `@.cursor/prompts/debug.md` with the failing test output.
Apply the fix, re-run tests.

If still failing after max_retries (from agent.config.yaml):
- Escalate using `@.cursor/prompts/escalate.md` with trigger `implement_max_retries_exceeded`
- PAUSE and wait for `AGENT_RESUME` or `AGENT_SKIP_TASK`

**Safety check before each commit:**
- Scan staged files against `safety.forbidden_file_patterns`
- Verify no files in `safety.protected_paths` are modified

---

## Phase 5: Quality Assurance

After all tasks are committed, apply `@.cursor/prompts/qa.md`.

Parse the structured QA report from `.agent/outputs/<task-id>-qa-report.json`.

**If `overallPass: true`** → proceed to PR creation.

**If `overallPass: false`:**
- Lint errors → run format command and commit fix
- Type errors → fix and commit
- Test failures → debug loop (subject to max_retries)
- Security issues → escalate with trigger `security_vulnerability_detected`
- Coverage below threshold → apply `@.cursor/prompts/test.md` for uncovered files

If QA cannot be resolved: escalate with trigger `qa_gate_failure`

---

## Phase 6: Create Pull Request

```bash
gh pr create \
  --title "<conventional-commit-title>" \
  --body "$(generate-pr-body)" \
  --label "ai-generated" \
  --assignee "@me"
```

PR body must include:
- Link to the issue tracker ticket: `Closes <tracker-url>`
- Summary of changes (from implementation output)
- How to test manually
- QA report summary
- Risk level from design phase
- Checklist from PULL_REQUEST_TEMPLATE.md

Update task state: phase = `pr`, `prUrl = <url>`.

---

## Phase 7: Monitor CI

```bash
gh pr checks <pr-number> --watch
```

**If all checks pass** → proceed to merge gate.

**If any check fails:**
- Diagnose from CI logs
- If fixable (lint, formatter): auto-fix, push, re-watch
- If not fixable: escalate with trigger `ci_pipeline_failure`

---

## Phase 8: Merge Gate

Check `agent.config.yaml` → `git.auto_merge`:
- `enabled: false` → post comment "CI passed. Ready for review." → wait for human merge
- `enabled: true` → verify approval count and merge:
  ```bash
  gh pr merge <pr-number> --squash --delete-branch
  ```

---

## Phase 9: Post-Merge Deploy

After merge:
1. If `staging_auto_deploy: true` — wait for staging CI to complete
2. Run smoke tests on staging URL
3. If smoke tests pass → update issue tracker: status = "In Review"
4. If `require_human_approval: true` for production → escalate LOW: "PR merged, staging healthy, awaiting production approval"

---

## Phase 10: Post-Deploy Monitoring

Monitor for 30 minutes:
- Check error rate vs. baseline
- Check p99 latency vs. baseline
- Check for new alerts

**If metrics stable:** mark task DONE
- Update issue tracker: status = Done
- Write final audit entry
- Update task state: `phase = done, status = completed`

**If metrics degrade:**
- Escalate with trigger `post_deploy_error_spike`
- Trigger auto-rollback per deploy runbook

---

## Final Output

```
╔══════════════════════════════════════════════════════╗
║  TASK COMPLETE: <task-id> — <title>                 ║
╠══════════════════════════════════════════════════════╣
║  Total time:  Xh Ym                                  ║
║  Phases:      triage ✓ → reqs ✓ → design ✓ →        ║
║               implement ✓ → qa ✓ → pr ✓ → deploy ✓  ║
║  PR:          <pr-url>                               ║
║  Escalations: N (all resolved)                       ║
╚══════════════════════════════════════════════════════╝
```

---

**Task to execute** (task-id or "resume <task-id>"):
