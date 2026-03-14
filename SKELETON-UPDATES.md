# Skeleton Updates — Migration Guide

This file documents every breaking and notable change to the AI-Native Skeleton
so that projects derived from the skeleton can apply updates selectively.

When the skeleton is updated, add an entry here **before** tagging a new version.
Derived projects reference this file to decide what to apply.

---

## How to Apply Skeleton Updates to Your Project

```bash
# One command — handles classification, diff, and selective application
bash scripts/sync-skeleton.sh
```

See [docs/skeleton-sync.md](docs/skeleton-sync.md) for the full guide.

---

## v1.0.6 — Fix skeleton.json: add 36 missing file ownership entries

**Date:** 2026-03-14
**Commit:** (set by release)
**Severity:** PATCH

### Updated Files (skeleton-owned — auto-applied)
- `skeleton.json` — Added all previously unclassified files to ownership lists:
  - **skeleton_owned**: all `.cursor/prompts/*.md`, Windows scripts (`init/setup/validate-ai-config .ps1/.bat`), `.agent/tasks/.gitkeep` + `TASK-TEMPLATE.md`, `.devcontainer/devcontainer.json`, `CONTRIBUTING.md`, `SKELETON-UPDATES.md`, `docs/skeleton-sync.md`
  - **project_owned**: `README.tr.md`, `docs/ai-workflow.tr.md`

---

## v1.0.5 — Update task status after implementation

**Date:** 2026-03-14
**Commit:** (set by release)
**Severity:** MINOR

### Updated Files (skeleton-owned — auto-applied)
- `.claude/commands/implement.md` — Added Step 6: Update Task Status; after implementation the agent marks the task file `done`, updates `INDEX.md` status, and reports the next unblocked task
- `.cursor/prompts/implement.md` — Same task status update step added for Cursor users

---

## v1.0.4 — Branch check as Step 0 in /implement

**Date:** 2026-03-14
**Commit:** (set by release)
**Severity:** MINOR

### Updated Files (skeleton-owned — auto-applied)
- `.claude/commands/implement.md` — Added Step 0: Branch Check; agent verifies it is on a feature branch and hard-stops if on `main`/`develop` before writing any code
- `.cursor/prompts/implement.md` — Same branch check added for Cursor users

---

## v1.0.3 — Enforce feature branch before implementation

**Date:** 2026-03-14
**Commit:** (set by release)
**Severity:** MINOR

### Updated Files (skeleton-owned — auto-applied)
- `.claude/commands/task.md` — Added Branch Requirement section: agent must create and switch to `feat/<slug>` branch before any implementation; also shown in `/task next` output
- `.cursor/prompts/task.md` — Same branch requirement added for Cursor users

---

## v1.0.2 — Fix sync-skeleton.sh sync logic

**Date:** 2026-03-14
**Commit:** (set by release)
**Severity:** PATCH

### Updated Files (skeleton-owned — auto-applied)
- `scripts/sync-skeleton.sh` — Three bugs fixed:
  - `((APPLIED++))` / `((SKIPPED++))` with `set -e` silently exited after first file; replaced with `APPLIED=$((APPLIED + 1))`
  - File ownership was read from local (potentially stale) `skeleton.json`; now reads from `skeleton/main:skeleton.json` so newly added files are always included
  - First-sync file list used `git show` (single commit diff) instead of `git ls-tree -r` (full tree)
- `skeleton.json` — Added missing `skeleton_owned` entries: `/task`, `/sync-skeleton` commands, `toon.mjs` hook, workflows `06`/`07`, `scripts/init.sh`

---

## v1.0.1 — Fix sync-skeleton.sh bash 3.2 compatibility

**Date:** 2026-03-14
**Commit:** (set by release)
**Severity:** PATCH

### Updated Files (skeleton-owned — auto-applied)
- `scripts/sync-skeleton.sh` — Replaced `mapfile` (bash 4+ only) with `while read` loops
  so the script runs on macOS default bash (3.2) without `command not found: mapfile`

---

## v1.0.0 — Initial Release

**Date:** 2025
**Commit:** Initial

### What's Included
- 20 Claude Code slash commands (full agentic loop)
- 22 Cursor skill rules + 22 Continue skill rules
- Autonomous agent infrastructure (JIRA, webhooks, escalation)
- Security evaluator (/security-audit + security-sast skill)
- Documentation agent (/doc-api, /doc-site, /doc-changelog, /doc-schema)
- On-premise Jira Server setup guide
- Full CI/CD workflow skeleton

**No migration needed** — this is the first version.

---

## Template for Future Entries

```markdown
## vX.Y.Z — Short Description

**Date:** YYYY-MM-DD
**Commit:** <git-sha>
**Severity:** BREAKING | MINOR | PATCH

### Breaking Changes (require manual action)
- **Changed:** `<file>` — what changed and why it matters
  **Action:** <what the developer must do>

### New Features (opt-in)
- **New file:** `.claude/commands/new-command.md`
  **Action:** Run `bash scripts/sync-skeleton.sh` — auto-applied (skeleton_owned)

### Updated Files (skeleton-owned — auto-applied)
- `.cursor/rules/skills/lang-java.mdc` — Updated for Java 22 virtual thread patterns
- `.claude/commands/loop.md` — Added docs-sync phase

### Merge-Required Files (developer must review)
- `.continue/config.yaml` — New skill entries added; merge with your model config
  **How:** Compare skeleton version with yours; add new skill lines only

### Removed Files
- `old-file.md` — removed because...
  **Action:** `rm old-file.md` from your project
```

---

*Add new entries at the top (newest first).*
