Generate a concise standup update based on recent git activity.

## Setup

Run the following command in your terminal first, then paste the output below:

```bash
git log --oneline --since="yesterday" --author="$(git config user.email)"
```

Also include any open PR URLs or branch names you are currently working on.

---

## Format

**Yesterday / Last session:**
- [bullet list of completed work based on commits and closed PRs]

**Today:**
- [bullet list of planned work — inferred from open PRs, recent branch names, and in-progress items]

**Blockers:**
- [any TODOs, unresolved issues, or explicit blockers found in recent commits]

---
Keep it concise — 3–7 bullets per section. Use plain language, not technical jargon.

---

**Paste your git log output and any context here:**
