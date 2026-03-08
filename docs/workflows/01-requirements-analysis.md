# Workflow: Requirements Analysis

This workflow transforms raw requirements (feature requests, user stories, bug reports, product specs)
into a structured, implementation-ready specification using AI assistance.

## When to Use This Workflow

- New feature development (any size)
- Significant refactoring with behavior changes
- Ambiguous or complex bug fixes
- Technical spike / proof of concept

Skip for: trivial bug fixes, config changes, documentation-only updates.

## The Workflow

```
Input: Raw requirement (ticket, Slack message, doc, verbal description)
  │
  ├─ Step 1: Clarify & Gather Context
  ├─ Step 2: AI-Assisted Analysis (/requirements)
  ├─ Step 3: Human Review & Refinement
  ├─ Step 4: Technical Spike (if unknown territory)
  └─ Output: Approved spec → ready for /sprint or /architect
```

## Step 1: Clarify & Gather Context

Before running AI analysis, collect:

**From the requester:**
- Who are the users affected?
- What problem does this solve? (not just what it should do)
- What is the success metric?
- What is the priority / urgency?
- Are there designs, mockups, or reference examples?

**From the codebase:**
- Which existing components are relevant?
- Are there similar features already implemented?
- Are there known constraints (performance, security, backward compat)?

## Step 2: AI-Assisted Requirements Analysis

```bash
# In Claude Code, Cursor, or Continue:
/requirements <paste the raw requirement here>
```

The `/requirements` command produces:
- Clarifying questions (answer these before proceeding)
- User stories with acceptance criteria
- Technical requirements (functional + non-functional)
- Architecture impact assessment
- Implementation backlog (prioritized tasks)
- Testing strategy
- Definition of Done

## Step 3: Human Review

Review the AI output critically. Check:

**Correctness**
- Does the specification match the original intent?
- Are business rules captured accurately?
- Are the user stories testable?

**Completeness**
- Are all user types covered?
- Are error cases and edge cases specified?
- Is the "out of scope" section accurate?

**Feasibility**
- Are effort estimates realistic?
- Are any tasks too large (XL)? Split them.
- Are dependencies identified?

**Gaps**
- What did the AI miss or misunderstand?
- Correct the spec and re-run if significantly wrong.

## Step 4: Technical Spike (if needed)

If the implementation approach is uncertain, run a time-boxed spike (max 2 days):

```
/architect <specific unknown aspect>
```

Goal of spike: answer a specific technical question (e.g., "Can we integrate with X API?",
"What's the performance characteristic of approach Y?").
Spike output: a documented decision, NOT production code.

## Output: Approved Specification

The approved specification should contain:

```markdown
# Feature: [Name]

## Status: Approved / Draft / Needs Review

## Sprint: [Sprint number or "Backlog"]

## User Stories
[From /requirements output]

## Acceptance Criteria
[From /requirements output]

## Technical Notes
[Architecture decisions, constraints, risks]

## Implementation Tasks
[Ordered task list from /requirements output]

## Definition of Done
[Checklist]
```

Store approved specs in: `docs/features/<feature-name>.md`

## Common Pitfalls

- **"I'll figure it out as I code"** — skipping requirements analysis leads to rework. The `/requirements` command takes 5 minutes; rework takes days.
- **AI takes the requirement too literally** — always review the user story section for missing implied behavior.
- **Scope creep in specs** — the AI may include nice-to-haves. Keep the "Out of scope" section rigorous.
- **Missing non-functional requirements** — performance, security, and accessibility are easy to overlook. Explicitly prompt for them.

## Time Estimates

- Simple feature: 15–30 minutes for requirements analysis
- Medium feature: 30–60 minutes (including stakeholder clarification)
- Complex feature: 2–4 hours (may include spike)

The time saved in implementation and rework far exceeds this investment.
