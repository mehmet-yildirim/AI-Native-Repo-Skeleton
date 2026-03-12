Process a batch of backlog issues through triage and requirements analysis.
This is the autonomous agent's entry point for working through a JIRA/Linear backlog.

---

## Step 1: Load Configuration

Read `@agent.config.yaml` to understand:
- Which issue tracker to query and with what filters
- Domain confidence thresholds
- Safety limits (max_concurrent_tasks, protected_paths, forbidden_commands)
- Escalation channels

Check for the kill switch file: `.agent/STOP`. If it exists, halt immediately and report.

---

## Step 2: Fetch Candidate Issues

Query the configured issue tracker for new work items using the configured JQL/filter.

If using JIRA (via MCP):
```
tool: mcp_jira_search
query: <backlog_jql from agent.config.yaml>
maxResults: 10
```

If using GitHub Issues (via MCP):
```
tool: mcp_github_list_issues
labels: ["ready-for-dev", "ai-agent"]
state: open
```

For each candidate issue, extract:
- ID, title, description, type, priority, labels
- Any existing `ai-agent-*` labels (skip if already processed)

---

## Step 3: Triage Each Issue

For each candidate issue (in priority order), apply the triage workflow from `@.cursor/prompts/triage.md`.

Collect the structured JSON output from each triage.
Record results in `.agent/state/groom-<date>.json`.

---

## Step 4: Classify the Batch

After triaging all candidates:

```
GROOMING BATCH RESULTS
═══════════════════════════════════════════════════════

ACCEPTED (will proceed to /requirements):
  ✅ PROJ-42 (conf: 0.92) — Add discount code to checkout
  ✅ PROJ-45 (conf: 0.87) — Fix order status sync after payment

ESCALATED (human triage needed):
  ⚠️  PROJ-43 (conf: 0.61) — Add user preference center
     Question: Does this affect our user profile data or is it a separate Auth service concern?

REJECTED (out of domain):
  ❌ PROJ-44 (conf: 0.18) — Update marketing landing page
     Redirected to: Marketing / CMS team

═══════════════════════════════════════════════════════
Accepted: N | Escalated: N | Rejected: N
Estimated capacity needed: <XL / L / M>
```

---

## Step 5: Respect Capacity Limits

Check `agent.config.yaml` → `autonomy.max_concurrent_tasks`.

If currently processing N tasks already at the limit:
- Queue accepted issues but do not start them yet
- Report: "Queue updated. N tasks accepted but deferred — at capacity limit."

Otherwise, proceed to requirements for each accepted issue.

---

## Step 6: Requirements Analysis for Accepted Issues

For each ACCEPTED issue (up to capacity limit), apply the requirements workflow from `@.cursor/prompts/requirements.md`.

Save the JSON output to `.agent/outputs/<task-id>-requirements.json`.
Update the task state file with the requirements output.

---

## Step 7: Grooming Summary

Produce a final grooming report:

```json
{
  "groomingSessionId": "groom-<ISO-timestamp>",
  "issuesFetched": 10,
  "accepted": 2,
  "escalated": 1,
  "rejected": 7,
  "proceededToRequirements": 2,
  "queuedForLater": 0,
  "estimatedCapacity": "L",
  "nextGroomAt": "<ISO-timestamp>",
  "issues": [...]
}
```

Post this to the configured Slack channel or create a GitHub summary issue.

---

## Step 8: Schedule Next Run

If operating in autonomous mode with polling enabled:
- Log next poll time based on `poll_interval_minutes` from agent.config.yaml
- The agent scheduler (external cron or CI workflow) is responsible for re-invoking this workflow

---

**Batch to groom** (optional — leave empty to use agent.config.yaml filter, or paste a list of issue IDs/descriptions):
