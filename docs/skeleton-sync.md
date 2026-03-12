# Skeleton Sync Guide

This guide explains how to keep a project that was derived from the AI-Native skeleton
in sync as the skeleton itself evolves — without overwriting your project-specific work.

---

## The Problem

When you clone the skeleton and start a project, you immediately diverge:

```
Skeleton repo ──────────────────── v1.0 ──── v1.1 ──── v1.2 ──── v2.0
                    │
                    └──── Your Project (from v1.0)
                              (customised CLAUDE.md, docs/context, etc.)
```

Over time the skeleton gains new slash commands, improved skill rules, security patches,
and new agent capabilities. Your project would benefit from these — but a naive `git pull`
would overwrite everything you've customised.

---

## File Ownership Model

Every file in the skeleton is classified into one of three categories, defined in `skeleton.json`:

### `skeleton_owned` — Safe to overwrite

These files contain **no project-specific content**. The skeleton owns them completely.
Updates are applied automatically by `sync-skeleton.sh`.

Examples:
- All `.claude/commands/*.md` — slash command definitions
- All `.cursor/rules/skills/*.mdc` — language/framework skill rules
- All `.continue/rules/skills/*.md` — Continue skill rules
- `docs/agent/` — autonomous agent documentation and schemas
- `scripts/validate-ai-config.sh` — configuration validator
- `.agent-templates/` — runtime templates

**You can still extend these in your project** — just know they will be overwritten on sync.
If you have project-specific additions, keep them in a separate file.

### `merge_required` — Review and cherry-pick

These files are a **mix of skeleton base content and your customizations**.
The sync script shows you a diff and lets you decide what to adopt.

| File | Why merge is needed |
|------|---------------------|
| `.continue/config.yaml` | You've added API keys and activated skills; skeleton adds new skills/commands |
| `.cursor/mcp.json` | You've enabled servers; skeleton adds new server entries |
| `.claude/settings.json` | You may have added permissions; skeleton adds hook entries |
| `.github/workflows/ci.yml` | Your stack's CI steps; skeleton fixes or adds generic steps |
| `docs/ai-workflow.md` | Your project workflow notes; skeleton adds new command references |
| `docs/onboarding.md` | Your project-specific setup; skeleton adds new sections |
| `.gitignore` | Your project ignores; skeleton adds new generated-file patterns |

### `project_owned` — Never overwrite

These files are **entirely yours**. The sync script skips them and only reports
if the skeleton template was updated (so you can read the new guidance):

- `CLAUDE.md` — your project's coding conventions and architecture
- `agent.config.yaml` — your JIRA connection, team settings
- `.cursor/rules/00-project-overview.mdc` — your project context for Cursor
- `docs/context/` — your project brief, tech stack, domain glossary
- `docs/architecture/` — your system architecture and ADRs
- `.env`, `.env.example` — your environment variables
- `skeleton.json` — version tracking (updated by sync script only)

---

## How to Sync

### Option 1: Automated script (recommended)

**macOS / Linux / Git Bash (WSL):**
```bash
bash scripts/sync-skeleton.sh           # Interactive
bash scripts/sync-skeleton.sh --auto    # Auto-apply skeleton-owned files
bash scripts/sync-skeleton.sh --dry-run # Preview only
bash scripts/sync-skeleton.sh --check   # Check for updates
```

**Windows — PowerShell (recommended on Windows):**
```powershell
# One-time: allow script execution if not already set
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

.\scripts\sync-skeleton.ps1            # Interactive
.\scripts\sync-skeleton.ps1 -Auto     # Auto-apply
.\scripts\sync-skeleton.ps1 -DryRun   # Preview only
.\scripts\sync-skeleton.ps1 -Check    # Check for updates
```

> **PowerShell advantage on Windows:** No `jq` required — uses built-in
> `ConvertFrom-Json`. For merge-required files, opens VS Code diff (if
> available) instead of vimdiff. Fully equivalent to the bash version.

**Windows — Batch (delegates to PowerShell automatically):**
```bat
scripts\sync-skeleton.bat
scripts\sync-skeleton.bat --auto
scripts\sync-skeleton.bat --dry-run
scripts\sync-skeleton.bat --check
```

### Option 2: Claude Code command

```
/sync-skeleton
/sync-skeleton --auto
/sync-skeleton --dry-run
```

### Option 3: Manual (when you need full control)

```bash
# 1. Add skeleton as a remote (first time only)
git remote add skeleton https://github.com/org/ai-native-skeleton.git

# 2. Fetch latest
git fetch skeleton

# 3. Apply a specific file from the skeleton
git show skeleton/main:.claude/commands/loop.md > .claude/commands/loop.md

# 4. Apply an entire directory of skeleton-owned files
for file in $(git show skeleton/main --name-only --format="" | grep "^\.cursor/rules/skills/"); do
  mkdir -p "$(dirname "$file")"
  git show "skeleton/main:$file" > "$file"
done

# 5. Review a merge-required file
git diff skeleton/main:.continue/config.yaml .continue/config.yaml

# 6. Update skeleton.json manually
# Edit skeleton.commit and skeleton.syncedAt fields
```

---

## When to Sync

| Trigger | Frequency | Priority |
|---------|-----------|----------|
| Skeleton releases a new version | Within one sprint of release | High |
| New skill added (language/framework your team uses) | When you start using that tech | Medium |
| Security patch in skill rules | Within a week | High |
| New slash command added | As convenient | Low |
| Check for updates | Every sprint | — |

Subscribe to the skeleton repository to get notified of new releases:
`GitHub → Watch → Custom → Releases`

---

## Merge Guide for Each merge_required File

### `.continue/config.yaml`

The skeleton adds new skill sections. Your version has API keys and activated skills.

**What to take from skeleton:**
```yaml
# Look for new section blocks like:
# --- Documentation skills ---
# - .continue/rules/skills/docs-generation.md

# --- Security SAST ---
# - .continue/rules/skills/security-sast.md
```

**What to keep from your version:**
- Your `models:` section with API keys
- Any skills you've uncommented (activated)
- Any custom slash commands you've added

**Merge command:**
```bash
# Open side-by-side
vimdiff .continue/config.yaml <(git show skeleton/main:.continue/config.yaml)
```

### `.cursor/mcp.json`

The skeleton adds new MCP server entries (always disabled by default).

**What to take from skeleton:**
- New server entries like `jira`, `linear`, `slack`, `sentry`
- Updated configurations for existing servers

**What to keep:**
- Any servers you've enabled (removed `"disabled": true` from)
- Your environment variable references

### `.github/workflows/ci.yml`

The skeleton improves the generic CI skeleton. Your version has stack-specific steps.

**What to take from skeleton:**
- New generic job patterns
- Fixed concurrency or caching configurations

**What to keep:**
- Your language-specific build, test, and deploy steps
- Your environment secrets and service configurations

---

## Tracking Which Skeleton Version You're On

After each sync, `skeleton.json` is updated:

```json
{
  "skeleton": {
    "repository": "https://github.com/org/ai-native-skeleton",
    "version": "1.2.0",
    "commit": "abc1234def567",
    "syncedAt": "2024-06-15"
  }
}
```

Commit `skeleton.json` after every sync so your team can see when the project was last
updated and from which skeleton version.

---

## Handling Conflicts

### When skeleton changes a file your team also changed

This can happen with `merge_required` files. Resolution order:

1. **Use skeleton version** if your changes are minor or the skeleton's improvement is significant
2. **Keep your version** if the file is heavily customised and the skeleton change is minor
3. **Cherry-pick** specific lines using a diff tool if both have valuable changes

### When a skeleton_owned file was customised locally

If you added content to a `skeleton_owned` file (e.g., added a project-specific section
to a skill rule), the sync will overwrite it. Solutions:

**Option A — Create a separate override file**
```
.cursor/rules/skills/lang-java.mdc        ← skeleton-owned (will be synced)
.cursor/rules/skills/lang-java-extra.mdc  ← project-owned (your additions)
```

**Option B — Move to merge_required**
Edit `skeleton.json` → `fileOwnership.merge_required` to add your file.
The sync script will then prompt before overwriting.

### When a skeleton file is removed

The sync script warns you: "REMOVED in skeleton: `<file>`"
Review whether to also remove it from your project (usually yes).

---

## Keeping Your Own Skeleton Fork

If your organization maintains a private fork of this skeleton with company-wide defaults:

1. Fork the skeleton repo into your org
2. Apply your company-wide customizations to the fork
3. In each project, set `skeleton.repository` to your fork URL
4. The sync script will pull from your fork, not the public skeleton

This lets you add company standards (internal tools, compliance rules, house style)
to the skeleton while still pulling upstream improvements via your fork.

---

## FAQ

**Q: Will sync break my running application?**
No. The sync only touches AI configuration files (`.claude/`, `.cursor/`, `.continue/`,
`docs/`, `scripts/`). It never modifies your application source code, tests, or data.

**Q: What if I've modified a skeleton_owned file?**
Your modification will be overwritten. Either move your additions to a separate file,
or reclassify the file as `merge_required` in `skeleton.json`.

**Q: Can I sync a specific file only?**
Yes: `git show skeleton/main:.claude/commands/loop.md > .claude/commands/loop.md`

**Q: How do I roll back a bad sync?**
`git diff HEAD` shows what changed. `git checkout HEAD -- <files>` restores any file.
Or `git stash` before sync to have a quick escape hatch.

**Q: What if the skeleton validator count increases after sync?**
New files were added to the skeleton. The updated validator checks for them.
Run `bash scripts/validate-ai-config.sh` — any FAILs indicate missing new files.
The sync should have applied them; if not, apply manually.
