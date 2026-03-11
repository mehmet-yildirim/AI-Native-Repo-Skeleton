# Autonomous Agent Workflow

This document defines the complete state machine, phase gates, and decision logic
for the autonomous AI development agent.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                     AUTONOMOUS AGENT ORCHESTRATOR                    │
│                                                                      │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────────────┐ │
│  │  POLLER  │──▶│ TRIAGER  │──▶│PLANNER   │──▶│  EXECUTOR LOOP   │ │
│  │          │   │          │   │          │   │                  │ │
│  │Pull from │   │Domain    │   │Require-  │   │Architect →       │ │
│  │JIRA/     │   │relevance │   │ments →   │   │Implement →       │ │
│  │Linear/GH │   │check     │   │Sprint    │   │QA → PR → Monitor │ │
│  └──────────┘   └──────────┘   └──────────┘   └──────────────────┘ │
│        │               │              │                  │          │
│        ▼               ▼              ▼                  ▼          │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │                    ESCALATION MANAGER                           ││
│  │   Confidence < threshold │ Risk = HIGH │ Retry limit exceeded   ││
│  │   → Slack / GitHub / Email / PagerDuty                         ││
│  └─────────────────────────────────────────────────────────────────┘│
│        │               │              │                  │          │
│        ▼               ▼              ▼                  ▼          │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │                    STATE STORE & AUDIT LOG                      ││
│  │   .agent/state/<task-id>.json   |   .agent/audit/<date>.jsonl  ││
│  └─────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────┘
```

## Full State Machine

```
                    [NEW ISSUE DETECTED]
                            │
                            ▼
                    ┌───────────────┐
                    │    TRIAGE     │ ◀── Read domain-boundaries.md
                    │ Domain check  │     Confidence scoring
                    └───────────────┘
                     │           │
              conf≥0.80       conf<0.30
                 │                │
                 ▼                ▼
           [ACCEPTED]        [REJECTED] ──▶ Comment on ticket + close
                 │
          0.30≤conf<0.80
                 │
                 ▼
          [ESCALATE_TRIAGE] ──▶ Human decides → ACCEPT or REJECT
                 │
           (if ACCEPT)
                 │
                 ▼
         ┌───────────────┐
         │  REQUIREMENTS │ ◀── /requirements command
         │  Analysis     │     Produces: user stories, tasks, DoD (JSON+MD)
         └───────────────┘
                 │
          conf≥threshold?
           Yes │    No │
               │       ▼
               │  [ESCALATE_REQUIREMENTS] ──▶ Human clarifies → retry or skip
               │
               ▼
         ┌───────────────┐
         │   ARCHITECT   │ ◀── /architect command
         │   Design      │     Produces: design doc, risk level (JSON+MD)
         └───────────────┘
                 │
          risk level check
       LOW/MED─────────HIGH
           │                │
           ▼                ▼
    [GATE: auto]    [ESCALATE_DESIGN] ──▶ Human approves or modifies
           │                │
           │         (if approved)
           └────────────────┘
                    │
                    ▼
         ┌───────────────────┐
         │    IMPLEMENT      │ ◀── /implement command (per task, bottom-up)
         │    (per task)     │     With retry loop (max N attempts)
         └───────────────────┘
                 │
           tests pass?
          Yes │    No (retry≤N)
              │       │
              │  [FIX_ATTEMPT] ──▶ /debug → fix → re-test
              │       │
              │  No (retry>N)
              │       │
              │  [ESCALATE_IMPL] ──▶ Human assists → agent resumes
              │
              ▼
         ┌───────────────┐
         │      QA       │ ◀── /qa command
         │  Full gates   │     lint + types + coverage + security
         └───────────────┘
                 │
             All PASS?
          Yes │    No │
              │       ▼
              │  [ESCALATE_QA] ──▶ Human reviews QA failures
              │
              ▼
         ┌───────────────┐
         │   CREATE PR   │ ◀── gh pr create with structured metadata
         │               │     Links to issue tracker ticket
         └───────────────┘
                 │
                 ▼
         ┌───────────────┐
         │  MONITOR CI   │ ◀── Poll GitHub Actions status
         │               │     Wait for all checks to pass
         └───────────────┘
                 │
             CI PASS?
          Yes │    No │
              │       ▼
              │  [ESCALATE_CI] ──▶ Human fixes CI issue
              │
              ▼
         ┌───────────────┐
         │  AWAIT MERGE  │ ◀── Wait for PR approval & merge
         │               │     (auto-merge if configured)
         └───────────────┘
                 │
                 ▼
         ┌───────────────┐
         │    DEPLOY     │ ◀── /deploy command
         │  Staging auto │     Production requires human gate
         │  Prod → gate  │
         └───────────────┘
                 │
           Deploy OK?
          Yes │    No │
              │       ▼
              │  [ROLLBACK + ESCALATE_DEPLOY]
              │
              ▼
         ┌───────────────┐
         │    MONITOR    │ ◀── Watch error rate + latency for 30 min
         │  Post-deploy  │
         └───────────────┘
                 │
          Metrics stable?
          Yes │    No │
              │       ▼
              │  [AUTO_ROLLBACK + ESCALATE_PRODUCTION]
              │
              ▼
         ┌───────────────┐
         │     DONE      │ ◀── Update issue tracker: status = Done
         │               │     Write audit log entry
         └───────────────┘
```

## Task State Schema

Every task in flight has a state file at `.agent/state/<task-id>.json`:

```json
{
  "taskId": "PROJ-42",
  "title": "Add discount code to checkout",
  "source": { "tracker": "jira", "url": "https://..." },
  "phase": "implement",
  "status": "in_progress",
  "startedAt": "2024-03-09T10:00:00Z",
  "lastUpdatedAt": "2024-03-09T11:30:00Z",
  "timeoutAt": "2024-03-10T10:00:00Z",
  "branchName": "feat/PROJ-42-discount-codes",
  "prUrl": null,
  "retries": { "implement": 1 },
  "escalations": [],
  "phaseOutputs": {
    "triage":        { "confidence": 0.92, "accepted": true },
    "requirements":  { "outputFile": ".agent/outputs/PROJ-42-requirements.json" },
    "architect":     { "outputFile": ".agent/outputs/PROJ-42-design.json", "risk": "low" },
    "implement":     { "tasksCompleted": 3, "tasksTotal": 5 },
    "qa":            null,
    "deploy":        null
  },
  "auditTrail": [
    { "at": "2024-03-09T10:00:00Z", "action": "triage_accepted",  "note": "conf=0.92" },
    { "at": "2024-03-09T10:05:00Z", "action": "requirements_done","note": "5 tasks identified" },
    { "at": "2024-03-09T10:30:00Z", "action": "design_done",      "note": "risk=low" },
    { "at": "2024-03-09T11:00:00Z", "action": "implement_started", "note": "task 1/5" }
  ]
}
```

## Phase Gate Contracts

Each phase gate checks these conditions before proceeding automatically:

| Phase Gate | Auto-proceed if... | Escalate if... |
|-----------|-------------------|----------------|
| After TRIAGE | confidence ≥ 0.80 | 0.30 ≤ conf < 0.80 |
| After REQUIREMENTS | confidence ≥ 0.75 AND all tasks sized ≤ L | ambiguities > 2 |
| After ARCHITECT | risk = low | risk = medium or high |
| After each IMPLEMENT task | all tests pass | tests fail after N retries |
| After QA | all gates PASS | any gate FAIL |
| After CI | all checks green | any check red |
| Before PROD DEPLOY | always escalate for human approval | — |
| After POST-DEPLOY MONITOR | metrics stable for 30 min | error rate spike |

## Resume After Interruption

If the agent crashes or is stopped, it resumes from the last checkpoint:

```bash
# Check in-flight tasks
ls .agent/state/

# Resume a specific task
/loop resume PROJ-42

# Resume all in-flight tasks
/loop resume-all
```

The agent reads the state file, determines the last completed phase, and continues from there.
It never re-runs completed phases unless explicitly requested.

## Concurrency Model

By default (`max_concurrent_tasks: 1`), the agent works on one task at a time.
To enable parallel development:

1. Set `max_concurrent_tasks: N` in `agent.config.yaml`
2. Each task gets its own git branch and state file
3. Tasks with dependencies wait for their dependencies' PRs to merge first
4. Dependency is inferred from the `depends_on` field in the requirements output

## Kill Switch

To stop the agent immediately (emergency):
```bash
touch .agent/STOP
```
The agent checks for this file before each phase transition and exits cleanly if found.
Remove the file to re-enable the agent.
