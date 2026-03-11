# Escalation Protocol

Defines when the autonomous agent escalates to a human, what information it provides,
and what actions are available to the human responder.

---

## Escalation Severity Levels

| Level | Meaning | Response Time | Channels |
|-------|---------|--------------|---------|
| **CRITICAL** | Production broken, data at risk, security issue | Immediate | Slack @here + PagerDuty |
| **HIGH** | Task blocked, repeated failures, risky change | < 2 hours | Slack + GitHub issue |
| **MEDIUM** | Ambiguous requirement, design question, confidence gap | < 8 hours | GitHub issue |
| **LOW** | Informational, soft blocker, FYI | Next working day | GitHub issue |

---

## Escalation Triggers

### CRITICAL Escalations

| Trigger | Description |
|---------|-------------|
| `post_deploy_error_spike` | Error rate > 5× baseline after deployment |
| `post_deploy_data_corruption` | Data integrity check failed after deploy |
| `security_vulnerability_detected` | /qa found CRITICAL CVE or injection risk in new code |
| `destructive_operation_attempted` | Agent tried to run forbidden command (DROP TABLE, rm -rf) |
| `budget_exceeded` | Daily/monthly token/cost budget exceeded |

### HIGH Escalations

| Trigger | Description |
|---------|-------------|
| `implement_max_retries_exceeded` | Failing tests not fixed after N attempts |
| `task_timeout` | Task exceeded max_hours_per_task from agent.config.yaml |
| `ci_pipeline_failure` | CI failed after PR creation and auto-fix attempts failed |
| `design_risk_high` | /architect classified change as HIGH risk |
| `consecutive_failures` | N consecutive tasks failed; agent may be in a bad state |

### MEDIUM Escalations

| Trigger | Description |
|---------|-------------|
| `triage_confidence_ambiguous` | Domain confidence between rejection and acceptance thresholds |
| `requirements_confidence_low` | Requirement too ambiguous to produce reliable user stories |
| `design_risk_medium` | /architect classified change as MEDIUM risk; review requested |
| `out_of_scope_dependency` | Implementing this task requires changing an out-of-scope system |
| `breaking_change_detected` | /review found backward-incompatible API or schema change |

### LOW Escalations

| Trigger | Description |
|---------|-------------|
| `triage_rejected` | Issue determined to be out of domain (informational) |
| `pr_awaiting_review` | PR created, waiting for human code review |
| `task_completed` | Task completed successfully (daily digest) |
| `stale_domain_boundaries` | `domain-boundaries.md` not updated in > 30 days |

---

## Escalation Message Format

Every escalation notification follows this structured format:

```json
{
  "id": "esc-20240309-001",
  "severity": "HIGH",
  "trigger": "implement_max_retries_exceeded",
  "taskId": "PROJ-42",
  "taskTitle": "Add discount code to checkout",
  "taskUrl": "https://jira.company.com/browse/PROJ-42",
  "phase": "implement",
  "summary": "Failed to fix failing test UserService.applyDiscount after 3 attempts.",
  "context": {
    "failingTest": "src/checkout/checkout.service.test.ts:87",
    "errorMessage": "TypeError: Cannot read properties of undefined (reading 'code')",
    "attemptsLog": [
      "Attempt 1: Added null check — still fails",
      "Attempt 2: Changed data fetch order — still fails",
      "Attempt 3: Refactored discount lookup — still fails"
    ],
    "hypothesis": "The test fixture may be missing required discount data. Possible test setup issue.",
    "branchName": "feat/PROJ-42-discount-codes",
    "prUrl": null
  },
  "availableActions": [
    { "action": "approve_and_continue", "description": "Fix the test manually and comment AGENT_RESUME on the task" },
    { "action": "reassign",             "description": "Remove the ai-agent label and assign to a human developer" },
    { "action": "skip_task",            "description": "Comment AGENT_SKIP_TASK to skip this sub-task and continue" },
    { "action": "abandon",              "description": "Comment AGENT_ABANDON to stop work on this ticket entirely" }
  ],
  "escalatedAt": "2024-03-09T14:35:00Z",
  "agentId": "my-project-agent"
}
```

---

## Human Response Actions

Humans respond to escalations by posting comments on the GitHub issue or JIRA ticket.
The agent polls for these comments and responds accordingly.

| Comment Command | Effect |
|----------------|--------|
| `AGENT_RESUME` | Agent retakes the task from current phase |
| `AGENT_RESUME phase=architect` | Agent restarts from a specific phase |
| `AGENT_SKIP_TASK` | Skip current sub-task, continue to next |
| `AGENT_REASSIGN` | Remove task from agent queue; hand to human |
| `AGENT_ABANDON` | Stop all work on this ticket; close the agent branch |
| `AGENT_APPROVE_DESIGN` | Approve the design phase output; proceed to implement |
| `AGENT_APPROVE_DEPLOY` | Approve production deployment |
| `AGENT_REJECT` | Reject and close the issue as out of scope |
| `AGENT_CLARIFY: <text>` | Provide clarification; agent incorporates it and retries |

---

## Escalation Runbook by Trigger

### `implement_max_retries_exceeded`

1. Read the agent's hypothesis in the escalation message
2. Check the failing test: `git checkout <branch> && <test command>`
3. Determine if it's a test setup issue or a real logic bug
4. Either:
   - Fix the test fixture and comment `AGENT_RESUME`
   - Provide a clarification hint and comment `AGENT_CLARIFY: <hint>`
   - Assign to a human developer: `AGENT_REASSIGN`

### `design_risk_high`

1. Read the design document linked in the escalation
2. Review the risk assessment: what specifically is high-risk?
3. Either:
   - Approve with conditions: `AGENT_APPROVE_DESIGN` + `AGENT_CLARIFY: <constraints>`
   - Modify the scope to reduce risk and `AGENT_CLARIFY: <new scope>`
   - Reject as too risky for autonomous implementation: `AGENT_REASSIGN`

### `post_deploy_error_spike` (CRITICAL)

1. **Immediately**: Check the monitoring dashboard
2. **If user impact confirmed**: Trigger rollback manually
   ```bash
   kubectl rollout undo deployment/app  # or equivalent
   ```
3. The agent will automatically attempt rollback — verify it succeeded
4. Create a post-incident issue in the tracker
5. Investigate root cause before re-enabling the agent for this type of change

### `triage_confidence_ambiguous`

1. Read the triage report in the GitHub issue
2. Review the original JIRA ticket
3. Decide: is this in our domain?
4. Comment `AGENT_RESUME` (agent will accept) or `AGENT_REJECT` (agent will decline)

---

## Escalation SLA

The agent will re-escalate (escalation reminder) if not responded to within:

| Severity | First reminder | Second reminder | Auto-action |
|----------|---------------|----------------|-------------|
| CRITICAL | 15 minutes | 30 minutes | Page on-call rotation |
| HIGH | 2 hours | 4 hours | Assign to team lead |
| MEDIUM | 8 hours | 24 hours | None |
| LOW | 48 hours | 72 hours | Auto-close escalation, task stays queued |
