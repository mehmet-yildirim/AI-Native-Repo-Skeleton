Generate a concise standup update based on recent git activity.

Read the git log for the last working day and any open PRs, then produce a standup summary.

```bash
git log --oneline --since="yesterday" --author="$(git config user.email)"
```

## Format

**Yesterday / Last session:**
- [bullet list of completed work based on commits and closed PRs]

**Today:**
- [bullet list of planned work — infer from open PRs, recent branch names, and in-progress items]

**Blockers:**
- [any TODOs, unresolved issues, or explicit blockers found in recent commits]

---
Keep it concise — 3–7 bullets per section. Use plain language, not technical jargon.

$ARGUMENTS
