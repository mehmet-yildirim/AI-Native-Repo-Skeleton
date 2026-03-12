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
