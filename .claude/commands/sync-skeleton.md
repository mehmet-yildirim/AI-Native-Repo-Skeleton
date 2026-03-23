Check for and apply updates from the AI-Native skeleton into this derived project.
Preserves all project-specific customizations while pulling in improved AI rules,
new slash commands, updated skill files, and bug fixes from the upstream skeleton.

This command orchestrates the full sync: fetch → classify → apply → validate.

---

## Step 1: Read Current Sync State

Read `initium.json` from the project root:
- `skeleton.repository` — the upstream skeleton URL
- `skeleton.commit` — the commit this project last synced from
- `skeleton.syncedAt` — when the last sync ran
- `skeleton.version` — skeleton version string

If `initium.json` doesn't exist, this project was not initialized from the skeleton
with proper tracking. Add it manually (see `docs/skeleton-sync.md`).

---

## Step 2: Fetch Skeleton Updates

```bash
# Add skeleton remote if not present
git remote get-url skeleton 2>/dev/null || \
  git remote add skeleton "$(jq -r '.skeleton.repository' initium.json)"

# Fetch latest
git fetch skeleton --quiet

LATEST_COMMIT=$(git rev-parse skeleton/main)
CURRENT_COMMIT=$(jq -r '.skeleton.commit' initium.json)
```

If `LATEST_COMMIT == CURRENT_COMMIT`, report "Already up to date" and stop.

Otherwise, show the changes:
```bash
git log --oneline "$CURRENT_COMMIT..skeleton/main"
```

And point to `INITIUM-UPDATES.md` on the skeleton repo for the full migration guide.

---

## Step 3: Classify Changed Files

Read the ownership lists from `initium.json`:

| Category | Behaviour |
|----------|-----------|
| `skeleton_owned` | Auto-apply — safe to overwrite, no project content |
| `merge_required` | Show diff — project has customised these |
| `project_owned` | Skip and report — never modify |

Get files changed since last sync:
```bash
git diff --name-only "$CURRENT_COMMIT" skeleton/main
```

For each changed file, determine its category from `initium.json`.

---

## Step 4: Apply skeleton_owned Files

For every file in `skeleton_owned` that changed:
```bash
# Extract from skeleton remote and overwrite local copy
git show skeleton/main:<file> > <file>
```

These files are safe to overwrite because they contain no project-specific content:
- All `.claude/commands/` slash commands
- All `.cursor/rules/skills/` and `.continue/rules/skills/` files
- All `docs/agent/` documentation
- All `scripts/` utility scripts

**Exception:** Check if any file in `skeleton_owned` was deleted in the skeleton.
If so, warn the developer and ask if they want to remove it locally too.

---

## Step 5: Handle merge_required Files

For each merge-required file that changed, produce a side-by-side diff:

```bash
git diff skeleton/main:<file> <file>
```

For each, present three options:
1. **Overwrite** — take the skeleton version entirely (use when you haven't customized the file)
2. **Diff tool** — open in your configured diff editor to cherry-pick changes
3. **Skip** — leave as is; developer merges manually later

**Key merge_required files and what to look for:**

### `.continue/config.yaml`
Skeleton adds new skill sections and slash commands. Merge strategy:
- Keep your API keys and model configuration
- Add any new `# --- X skills ---` comment blocks from the skeleton
- Add any new slash command entries from the skeleton
- Don't remove your existing uncommented skill activations

### `.cursor/mcp.json`
Skeleton may add new MCP server entries. Merge strategy:
- Keep any servers you've enabled (removed `"disabled": true`)
- Add new skeleton server entries (they ship with `"disabled": true`)

### `.claude/settings.json`
Skeleton adds new hook definitions. Merge strategy:
- Keep your existing permission allow/deny rules
- Add any new hook entries from the skeleton

### `.github/workflows/ci.yml`
Skeleton may fix or add CI steps. Merge strategy:
- Keep your project-specific job configurations
- Adopt skeleton improvements to existing job structure

### `docs/ai-workflow.md` and `docs/onboarding.md`
Skeleton adds new command references. Merge strategy:
- Keep your project-specific workflows and examples
- Add new command rows to the reference tables
- Don't overwrite project-specific notes you've added

---

## Step 6: Report project_owned Changes (Informational)

If any `project_owned` files changed in the skeleton (e.g., `CLAUDE.md` template was
improved), report them as informational notices:

```
ℹ  CLAUDE.md — skeleton template improved
   Review: git show skeleton/main:CLAUDE.md
   Action: Manually adopt any new guidance that applies to your project
```

Do NOT apply these files automatically.

---

## Step 7: Update initium.json

After applying changes, update the tracking fields:

```bash
jq --arg commit "$LATEST_COMMIT" \
   --arg date "$(date +%Y-%m-%d)" \
   --arg ver "$NEW_VERSION" \
   '.skeleton.commit = $commit | .skeleton.syncedAt = $date | .skeleton.version = $ver' \
   initium.json > tmp && mv tmp initium.json
```

---

## Step 8: Run Validator

```bash
bash scripts/validate-ai-config.sh
```

All PASS counts should be ≥ what they were before the sync. Any new FAILs indicate
a file that was expected by the skeleton but not applied (e.g., due to merge conflicts).

---

## Step 9: Summary and Next Steps

Report:
```
Sync Summary
  Applied (auto)   : N files (skeleton_owned)
  Merged manually  : N files
  Skipped          : N files — merge these manually
  Notices          : N project-owned template changes to review

Suggested commit:
  git add -p
  git commit -m "chore: sync skeleton to vX.Y.Z (<short-sha>)"
```

---

## What This Command Does NOT Do

- Modify your application source code
- Change `CLAUDE.md`, `agent.config.yaml`, or any project context files
- Affect the `.agent/` runtime directory
- Push to any remote (you decide when to commit and push)

---

Options (pass as arguments): `--auto` | `--dry-run` | `--check`
