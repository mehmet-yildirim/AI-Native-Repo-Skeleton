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

## v1.0.20 — sync-skeleton.cmd no longer requires bash or WSL

**Date:** 2026-03-23
**Commit:** (set by release)
**Severity:** MINOR

### What Changed
`sync-skeleton.cmd` now delegates directly to `sync-skeleton.ps1` via
`pwsh` (PowerShell 7) or `powershell.exe` (Windows PowerShell 5.1).
Both are built into Windows — no bash, Git Bash, WSL, or `jq` required.

`sync-skeleton.ps1` already contained the full sync implementation, so
no functionality was removed or added. The `.cmd` file is now just a thin
PowerShell launcher (identical pattern to `setup.cmd`, `init.cmd`, etc.).

Also fixed a first-sync bug in `sync-skeleton.ps1`: when the stored
commit SHA is not in the local repository (first-ever sync), the file
list is now obtained with `git ls-tree -r --name-only` instead of
`git show --name-only`.

### Updated Files (skeleton-owned — auto-applied)
- `scripts/sync-skeleton.cmd` — rewritten to call `sync-skeleton.ps1` directly
- `scripts/sync-skeleton.ps1` — fixed first-sync `git ls-tree` call
- `docs/skeleton-sync.md` — updated Windows CMD section

### Migration
No action needed. Run `scripts/sync-skeleton.cmd` as before — it now
works on any Windows machine without installing bash or WSL.

---

## v1.0.19 — Rename Windows batch scripts from .bat to .cmd

**Date:** 2026-03-23
**Commit:** (set by release)
**Severity:** MINOR

### What Changed
All four Windows batch scripts have been renamed from `.bat` to `.cmd`.
`.cmd` is the modern Windows script extension — it runs in CMD.EXE with
the same behaviour as `.bat` but signals more clearly that the file is a
Windows command script rather than a legacy DOS batch file.

### Updated Files (skeleton-owned — auto-applied)
- `scripts/setup.cmd` (was `setup.bat`)
- `scripts/init.cmd` (was `init.bat`)
- `scripts/validate-ai-config.cmd` (was `validate-ai-config.bat`)
- `scripts/sync-skeleton.cmd` (was `sync-skeleton.bat`)
- `scripts/validate-ai-config.ps1` — updated internal path references
- `scripts/validate-ai-config.sh` — updated path checks
- `skeleton.json` — ownership entries updated + version bumped to 1.0.19
- All documentation files updated.

### Migration
If you already have the old `.bat` files in your derived project:
1. Rename them to `.cmd` (or re-run `scripts/sync-skeleton.cmd` after
   adding the new files from the skeleton).
2. Update any scripts or CI steps that invoke the old `.bat` names.

---

## v1.0.18 — Remove jq dependency from sync-skeleton.sh

**Date:** 2026-03-23
**Commit:** (set by release)
**Severity:** MINOR

### What Changed
`scripts/sync-skeleton.sh` no longer requires `jq`. All JSON parsing is now
done with `grep`, `sed`, and `awk`, which are available in Git Bash for Windows
without any extra tooling.

### Updated Files (skeleton-owned — auto-applied)
- `scripts/sync-skeleton.sh` — replaced all four `jq` call-sites with a
  `_json_array` awk helper and `grep`/`sed` one-liners. No behavioural change.
- `skeleton.json` — version bumped to 1.0.18.

### Migration
No action needed. The script behaviour is identical; `jq` is simply no longer
required. If you had a local workaround that pre-installs `jq` in CI, it can
safely be removed.

---

## v1.0.17 — Compress always-loaded context files

**Date:** 2026-03-23
**Commit:** (set by release)
**Severity:** MINOR

### Updated Files (skeleton-owned — auto-applied)
- `CLAUDE.md` — 167 → 124 lines (−43). Compressed Essential Commands to a single compact block, collapsed Architecture bullets, trimmed branch workflow section, merged Coding Conventions sub-items.
- `.cursor/rules/01-coding-standards.mdc` — 103 → 80 lines (−23). Removed language-specific naming TODO, import alias TODO, concurrency TODO, and the TypeScript/Python template sections (these belong in `lang-typescript.mdc` / `lang-python.mdc` skill files, not in an always-loaded rule).
- `.cursor/rules/00-project-overview.mdc` — 47 → 41 lines (−6). Compressed Key Constraints and Domain Glossary TODO sections.

### Net savings
**−72 lines from always-loaded context** (loaded on every Claude Code turn and every Cursor session).

---

## v1.0.16 — Remove .cursor/prompts/ — Cursor reads slash commands from .claude/commands/ directly

**Date:** 2026-03-23
**Commit:** (set by release)
**Severity:** MINOR

### Removed Files (skeleton-owned — auto-removed on sync)
All 22 files under `.cursor/prompts/` (excluding `README.md`) have been deleted. Cursor reads slash commands directly from `.claude/commands/`, making the prompt files redundant duplicates. **~2,900 lines of duplicated content eliminated.**

### Updated Files (merge-required — review before applying)
- `.cursor/prompts/README.md` — Rewritten to explain that Cursor uses `.claude/commands/` directly.
- `README.md` — Updated Cursor row in the tool table; updated `/help` tip.
- `README.tr.md` — Same in Turkish.
- `docs/onboarding.md` — Updated Cursor setup step 4; updated `/help` references.
- `docs/onboarding.tr.md` — Same in Turkish.

### Migration notes
- **Derived projects:** Delete all files in `.cursor/prompts/` except `README.md`. No functionality is lost — `/implement`, `/debug`, `/qa`, etc. continue to work in Cursor via `.claude/commands/`.
- If you have customized any `.cursor/prompts/*.md` files, migrate those customizations to the corresponding `.claude/commands/*.md` file instead.

---

## v1.0.15 — Reduce token usage across CLAUDE.md and command files

**Date:** 2026-03-23
**Commit:** (set by release)
**Severity:** MINOR

### Updated Files (skeleton-owned — auto-applied)
- `CLAUDE.md` — Removed redundant architecture constraints block (now a 3-line summary referencing `.cursor/rules/02-architecture.mdc`). Compressed verbose TODO placeholder examples. Removed empty glossary table row. **216 → 167 lines; saves ~49 tokens on every conversation turn.**
- `.claude/commands/implement.md` — Compressed 14-line branch check block to 2 lines (CLAUDE.md already carries the full rule in context).
- `.claude/commands/debug.md` — Same branch check compression.
- `.cursor/prompts/implement.md` — Same branch check compression (rule is in `04-git-workflow.mdc`).
- `.cursor/prompts/debug.md` — Same branch check compression.

### Migration notes
- **Derived projects:** Apply `CLAUDE.md` changes carefully — your filled-in project-specific content must be preserved. The architecture constraints block can be removed; replace it with the 3-line summary pointing to `.cursor/rules/02-architecture.mdc`.
- **No behavioral change** — all rules still apply; they are now stored in one canonical location instead of being repeated in every file.

---

## v1.0.14 — Add Turkish translation of team formation guide

**Date:** 2026-03-15
**Commit:** (set by release)
**Severity:** MINOR

### New Files (skeleton-owned — auto-applied)
- `docs/team.tr.md` — Full Turkish translation of the team formation guide covering all roles, decision authority matrix, team size recommendations, and anti-patterns.

### Updated Files (merge-required — review before applying)
- `docs/onboarding.md` — Added `docs/team.tr.md` cross-reference.
- `docs/onboarding.tr.md` — Updated team.md reference to point to Turkish version.
- `README.md` — Added `docs/team.tr.md` to Further Reading.
- `README.tr.md` — Same in Turkish.

---

## v1.0.13 — Add team formation guide for AI-native development

**Date:** 2026-03-15
**Commit:** (set by release)
**Severity:** MINOR

### New Files (skeleton-owned — auto-applied)
- `docs/team.md` — Comprehensive team formation guide covering: roles (Tech Lead, Domain Owner, Developer, AI Workflow Coordinator, Security Champion), decision authority matrix, team size recommendations (1–3 / 3–6 / 7–15 people), new member onboarding steps, and common anti-patterns.

### Updated Files (merge-required — review before applying)
- `docs/onboarding.md` — Added `docs/team.md` to the "Understanding the Project" reading list.
- `docs/onboarding.tr.md` — Same addition in Turkish.
- `README.md` — Added `docs/team.md` to Further Reading.
- `README.tr.md` — Same in Turkish.

---

## v1.0.12 — Add hexagonal architecture preference and design pattern guidance

**Date:** 2026-03-15
**Commit:** (set by release)
**Severity:** MINOR

### Updated Files (project-owned — review and merge manually)
- `CLAUDE.md` — Added "Architectural Constraints" subsection to the Architecture section: hexagonal preference, adapter pattern requirement for external integrations, and a design pattern reference table.

### Updated Files (skeleton-owned — auto-applied)
- `.cursor/rules/02-architecture.mdc` — Added "Standing Rules" block at the top (before the existing project-specific section): hexagonal default, adapter pattern for all external integrations, and design pattern reference table.
- `.continue/rules/02-architecture.md` — Same standing rules added.

---

## v1.0.11 — Enforce branch-before-change rule across all entry points

**Date:** 2026-03-15
**Commit:** (set by release)
**Severity:** MINOR

### Updated Files (project-owned — review and apply manually)
- `CLAUDE.md` — Added "Branch Before Any Code Change" subsection to "Git & PR Workflow". Rule explicitly covers slash commands, direct chat instructions, and inline edit requests — not just structured commands.

### Updated Files (skeleton-owned — auto-applied)
- `.claude/commands/debug.md` — Added Step 0: Branch Check before diagnosis begins, matching the pattern already in `/implement`.
- `.cursor/prompts/debug.md` — Same Step 0 added for Cursor.
- `.cursor/rules/04-git-workflow.mdc` — Added "Branch Before Any Code Change" section at the top of the rule file so it loads as a standing constraint in every Cursor session.

---

## v1.0.10 — Add Turkish onboarding documentation

**Date:** 2026-03-14
**Commit:** (set by release)
**Severity:** MINOR

### New Files (skeleton-owned — auto-applied)
- `docs/onboarding.tr.md` — Full Turkish translation of `docs/onboarding.md`. Covers prerequisites, initial setup (macOS/Linux/Windows), understanding the project, all 27 AI commands with Turkish descriptions, development workflow, autonomous agent setup, security checklist, and getting help with `/help`.

### Updated Files (merge-required — review before applying)
- `docs/onboarding.md` — Turkish cross-reference updated to point to new `onboarding.tr.md`.
- `README.md` — Added `docs/onboarding.tr.md` to Further Reading table.
- `README.tr.md` — Added `docs/onboarding.tr.md` to Further Reading table with both language labels.

---

## v1.0.9 — Surface /help in README, onboarding, and agent redirect behavior

**Date:** 2026-03-14
**Commit:** (set by release)
**Severity:** MINOR

### Updated Files (merge-required — review before applying)
- `README.md` — Added "Help & Navigation" section to Slash Commands Reference, `/help` tip after Quick Start, updated command count to 27, added `help.md` to repo tree.
- `docs/onboarding.md` — Added `/help` as first entry in Claude Code commands list, added prominent "Getting Help" block with examples, added tip callout at top of "Setting Up AI Tools".

### Updated Files (skeleton-owned — auto-applied)
- `.claude/commands/help.md` — Added redirect guidance: when a developer asks a general "what should I do?" question outside of `/help`, the agent responds by directing them to run `/help` instead of answering inline.
- `.cursor/prompts/help.md` — Same redirect guidance for Cursor.

---

## v1.0.8 — Add /help command for developer guidance

**Date:** 2026-03-14
**Commit:** (set by release)
**Severity:** MINOR

### New Files (skeleton-owned — auto-applied)
- `.claude/commands/help.md` — `/help` command for Claude Code. When invoked with no arguments it prints the full command reference. When given a question or topic it maps the developer to the right command(s) and workflow stage. Never writes code.
- `.cursor/prompts/help.md` — Cursor equivalent of `/help`. Same logic: full reference, phase guidance, topic mapping, and recovery advice. Never writes code.

---

## v1.0.7 — sync-skeleton.sh: add missing skeleton-owned files

**Date:** 2026-03-14
**Commit:** (set by release)
**Severity:** MINOR

### Updated Files (skeleton-owned — auto-applied)
- `scripts/sync-skeleton.sh` — Added "Adding Missing Skeleton-Owned Files" pass after the normal update loop. For each file in `skeleton_owned`, if it does not exist locally it is fetched and created. This handles new files added to the skeleton whose content hasn't changed since the last sync commit (so they wouldn't appear in `git diff --name-only`), as well as files accidentally deleted from the derived project.

---

## v1.0.6 — Fix skeleton.json: add 36 missing file ownership entries

**Date:** 2026-03-14
**Commit:** (set by release)
**Severity:** PATCH

### Updated Files (skeleton-owned — auto-applied)
- `skeleton.json` — Added all previously unclassified files to ownership lists:
  - **skeleton_owned**: all `.cursor/prompts/*.md`, Windows scripts (`init/setup/validate-ai-config .ps1/.cmd`), `.agent/tasks/.gitkeep` + `TASK-TEMPLATE.md`, `.devcontainer/devcontainer.json`, `CONTRIBUTING.md`, `SKELETON-UPDATES.md`, `docs/skeleton-sync.md`
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
