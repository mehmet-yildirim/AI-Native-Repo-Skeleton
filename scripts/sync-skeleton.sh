#!/usr/bin/env bash
# =============================================================================
# sync-skeleton.sh — Apply skeleton updates to your derived project
# =============================================================================
# Run this when the AI-Native skeleton has been updated and you want to
# pull in improvements without overwriting your project-specific files.
#
# Usage:
#   bash scripts/sync-skeleton.sh                  # Interactive mode
#   bash scripts/sync-skeleton.sh --auto           # Apply skeleton_owned files without prompting
#   bash scripts/sync-skeleton.sh --dry-run        # Show what would change, apply nothing
#   bash scripts/sync-skeleton.sh --check          # Just report version status, exit
#
# What it does:
#   1. Fetches the skeleton repo (adds as 'skeleton' remote if needed)
#   2. Reads skeleton.json to classify every file by ownership
#   3. For skeleton_owned files  → auto-applies (safe overwrite)
#   4. For merge_required files  → shows diff, asks you to confirm each
#   5. For project_owned files   → skips (never touched)
#   6. Updates skeleton.json with the new version
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
SKELETON_JSON="skeleton.json"
SKELETON_REMOTE="skeleton"

# Colours
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
heading() { echo -e "\n${BOLD}$*${NC}"; echo "$(printf '─%.0s' {1..60})"; }

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
AUTO=false
DRY_RUN=false
CHECK_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --auto)     AUTO=true ;;
    --dry-run)  DRY_RUN=true ;;
    --check)    CHECK_ONLY=true ;;
    --help|-h)
      echo "Usage: bash scripts/sync-skeleton.sh [--auto|--dry-run|--check]"
      echo ""
      echo "  --auto      Apply all skeleton_owned files without prompting"
      echo "  --dry-run   Show what would change; apply nothing"
      echo "  --check     Show version status only; apply nothing"
      exit 0 ;;
    *) warn "Unknown argument: $arg" ;;
  esac
done

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
heading "Pre-flight Checks"

[ -f "$SKELETON_JSON" ] || error "skeleton.json not found. Is this a skeleton-based project?"
command -v git >/dev/null 2>&1 || error "git is required but not found"
command -v jq  >/dev/null 2>&1 || { warn "jq not found — install with: brew install jq / apt install jq"; exit 1; }

# Check working tree is clean
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
  warn "Your working tree has uncommitted changes."
  warn "Stash or commit them before syncing: git stash"
  if [ "$DRY_RUN" = false ] && [ "$CHECK_ONLY" = false ]; then
    read -r -p "Continue anyway? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
  fi
fi

success "Working directory: $(pwd)"

# ---------------------------------------------------------------------------
# Read skeleton.json
# ---------------------------------------------------------------------------
SKELETON_REPO=$(jq -r '.skeleton.repository' "$SKELETON_JSON")
CURRENT_COMMIT=$(jq -r '.skeleton.commit' "$SKELETON_JSON")
CURRENT_SYNCED=$(jq -r '.skeleton.syncedAt' "$SKELETON_JSON")

info "Skeleton repo  : $SKELETON_REPO"
info "Last synced at : $CURRENT_SYNCED"
info "Last sync SHA  : $CURRENT_COMMIT"

# ---------------------------------------------------------------------------
# Set up skeleton remote
# ---------------------------------------------------------------------------
heading "Connecting to Skeleton Repository"

if ! git remote get-url "$SKELETON_REMOTE" &>/dev/null; then
  info "Adding skeleton remote: $SKELETON_REPO"
  git remote add "$SKELETON_REMOTE" "$SKELETON_REPO"
else
  EXISTING_URL=$(git remote get-url "$SKELETON_REMOTE")
  if [ "$EXISTING_URL" != "$SKELETON_REPO" ]; then
    warn "Remote '$SKELETON_REMOTE' points to $EXISTING_URL"
    warn "Expected: $SKELETON_REPO"
    read -r -p "Update remote URL? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      git remote set-url "$SKELETON_REMOTE" "$SKELETON_REPO"
    fi
  fi
fi

info "Fetching skeleton..."
git fetch "$SKELETON_REMOTE" --quiet
LATEST_COMMIT=$(git rev-parse "$SKELETON_REMOTE/main")
LATEST_SHORT=$(git rev-parse --short "$SKELETON_REMOTE/main")

success "Latest skeleton commit: $LATEST_SHORT"

# Compare versions
if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ]; then
  success "Already up to date — skeleton commit matches your last sync."
  [ "$CHECK_ONLY" = true ] && exit 0
  echo ""
  read -r -p "Force re-sync anyway? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { info "Nothing to do."; exit 0; }
else
  info "Updates available since your last sync."
fi

if [ "$CHECK_ONLY" = true ]; then
  echo ""
  echo "Run 'bash scripts/sync-skeleton.sh' to apply updates."
  exit 0
fi

# ---------------------------------------------------------------------------
# Show changelog between versions
# ---------------------------------------------------------------------------
heading "What Changed in the Skeleton"

echo ""
echo "Commits since your last sync:"
git log --oneline "$CURRENT_COMMIT..$SKELETON_REMOTE/main" 2>/dev/null || \
  git log --oneline "$SKELETON_REMOTE/main" --max-count=20

echo ""
info "Full migration notes: $SKELETON_REPO/blob/main/SKELETON-UPDATES.md"
echo ""
if [ "$AUTO" = false ]; then
  read -r -p "Continue with sync? [Y/n] " confirm
  [[ "$confirm" =~ ^[Nn]$ ]] && { info "Sync cancelled."; exit 0; }
fi

# ---------------------------------------------------------------------------
# Read file ownership lists
# ---------------------------------------------------------------------------
SKELETON_OWNED=()
while IFS= read -r line; do SKELETON_OWNED+=("$line"); done < <(jq -r '.fileOwnership.skeleton_owned[]' "$SKELETON_JSON")
PROJECT_OWNED=()
while IFS= read -r line; do PROJECT_OWNED+=("$line"); done < <(jq -r '.fileOwnership.project_owned[]' "$SKELETON_JSON")
MERGE_REQUIRED=()
while IFS= read -r line; do MERGE_REQUIRED+=("$line"); done < <(jq -r '.fileOwnership.merge_required[]' "$SKELETON_JSON")

# ---------------------------------------------------------------------------
# Get list of changed files in skeleton since last sync
# ---------------------------------------------------------------------------
if git cat-file -e "$CURRENT_COMMIT" 2>/dev/null; then
  CHANGED_FILES=$(git diff --name-only "$CURRENT_COMMIT" "$SKELETON_REMOTE/main")
else
  # First sync — treat all skeleton_owned files as changed
  CHANGED_FILES=$(git show "$SKELETON_REMOTE/main" --name-only --format="" | tail -n +2)
fi

APPLIED=0
SKIPPED=0
NEEDS_MERGE=()

# ---------------------------------------------------------------------------
# Apply skeleton_owned files
# ---------------------------------------------------------------------------
heading "Applying Skeleton-Owned Files (safe overwrite)"

for file in $CHANGED_FILES; do
  # Check if this file is skeleton_owned
  is_skeleton_owned=false
  for owned in "${SKELETON_OWNED[@]}"; do
    # Support directory prefix matching (e.g., "docs/agent/schemas/")
    if [[ "$file" == "$owned" ]] || [[ "$file" == "$owned"* && "${owned: -1}" == "/" ]]; then
      is_skeleton_owned=true
      break
    fi
  done

  if [ "$is_skeleton_owned" = false ]; then
    continue
  fi

  # Check if file exists in skeleton
  if ! git show "$SKELETON_REMOTE/main:$file" &>/dev/null; then
    warn "  REMOVED in skeleton: $file"
    if [ "$DRY_RUN" = false ] && [ "$AUTO" = true ]; then
      warn "    Leaving local copy — remove manually if no longer needed"
    fi
    continue
  fi

  if [ "$DRY_RUN" = true ]; then
    echo -e "  ${GREEN}[DRY-RUN WOULD UPDATE]${NC} $file"
    ((APPLIED++))
  else
    # Create parent directory if needed
    mkdir -p "$(dirname "$file")"
    git show "$SKELETON_REMOTE/main:$file" > "$file"
    success "  Updated: $file"
    ((APPLIED++))
  fi
done

# ---------------------------------------------------------------------------
# Identify merge_required files that changed
# ---------------------------------------------------------------------------
heading "Merge-Required Files (manual review needed)"

for file in $CHANGED_FILES; do
  is_merge=false
  for merge in "${MERGE_REQUIRED[@]}"; do
    if [[ "$file" == "$merge" ]] || [[ "$file" == "$merge"* && "${merge: -1}" == "/" ]]; then
      is_merge=true
      break
    fi
  done

  if [ "$is_merge" = false ]; then
    continue
  fi

  if ! git show "$SKELETON_REMOTE/main:$file" &>/dev/null; then
    continue
  fi

  NEEDS_MERGE+=("$file")
done

if [ ${#NEEDS_MERGE[@]} -eq 0 ]; then
  info "No merge-required files changed in this skeleton update."
else
  echo ""
  warn "These files changed in the skeleton but require manual merge"
  warn "because your project has likely customised them:"
  echo ""
  for file in "${NEEDS_MERGE[@]}"; do
    echo -e "  ${YELLOW}→ $file${NC}"
  done
  echo ""
  echo "For each file above:"
  echo "  1. View skeleton version: git show $SKELETON_REMOTE/main:<file>"
  echo "  2. View your version: cat <file>"
  echo "  3. Apply only the relevant new sections from the skeleton"
  echo ""

  if [ "$DRY_RUN" = false ]; then
    for file in "${NEEDS_MERGE[@]}"; do
      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo " MERGE: $file"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
      echo "Diff (skeleton vs your version):"
      git diff "$SKELETON_REMOTE/main:$file" "$file" 2>/dev/null || \
        echo "  [file is new in skeleton — no local version to diff]"
      echo ""

      if [ "$AUTO" = false ]; then
        echo "Options:"
        echo "  a) Overwrite with skeleton version (discards your changes)"
        echo "  s) Skip this file (merge manually later)"
        echo "  o) Open both in diff tool ($VISUAL or vimdiff)"
        read -r -p "Choice [a/S/o]: " choice
        case "$choice" in
          a|A)
            mkdir -p "$(dirname "$file")"
            git show "$SKELETON_REMOTE/main:$file" > "$file"
            success "  Overwritten: $file"
            ((APPLIED++))
            ;;
          o|O)
            SKELETON_TMP=$(mktemp /tmp/skeleton-XXXXXX)
            git show "$SKELETON_REMOTE/main:$file" > "$SKELETON_TMP"
            ${VISUAL:-vimdiff} "$SKELETON_TMP" "$file" || true
            rm -f "$SKELETON_TMP"
            warn "  Review complete — your changes kept. Stage manually if you edited."
            ((SKIPPED++))
            ;;
          *)
            warn "  Skipped: $file — merge manually"
            ((SKIPPED++))
            ;;
        esac
      else
        warn "  Skipped (--auto mode): $file — merge manually"
        ((SKIPPED++))
      fi
    done
  fi
fi

# ---------------------------------------------------------------------------
# Report project_owned files that were changed in skeleton (informational)
# ---------------------------------------------------------------------------
PROJECT_TEMPLATE_CHANGES=()
for file in $CHANGED_FILES; do
  for owned in "${PROJECT_OWNED[@]}"; do
    if [[ "$file" == "$owned" ]] || [[ "$file" == "$owned"* && "${owned: -1}" == "/" ]]; then
      PROJECT_TEMPLATE_CHANGES+=("$file")
      break
    fi
  done
done

if [ ${#PROJECT_TEMPLATE_CHANGES[@]} -gt 0 ]; then
  heading "Skeleton Template Files Changed (for your reference)"
  warn "These project-owned files were updated in the skeleton template."
  warn "Review them to see if new guidance applies to your project:"
  echo ""
  for file in "${PROJECT_TEMPLATE_CHANGES[@]}"; do
    echo -e "  ${CYAN}ℹ  $file${NC}"
    echo "     → Review: git show $SKELETON_REMOTE/main:$file | head -40"
  done
fi

# ---------------------------------------------------------------------------
# Update skeleton.json
# ---------------------------------------------------------------------------
if [ "$DRY_RUN" = false ] && [ "$APPLIED" -gt 0 ]; then
  heading "Updating skeleton.json"
  SKELETON_VERSION=$(git show "$SKELETON_REMOTE/main:SKELETON-UPDATES.md" 2>/dev/null | \
    grep -m1 "^## v" | sed 's/^## v//' | awk '{print $1}' || echo "unknown")
  TODAY=$(date +%Y-%m-%d)

  # Update skeleton.json fields
  TMP=$(mktemp)
  jq --arg commit "$LATEST_COMMIT" \
     --arg date "$TODAY" \
     --arg ver "$SKELETON_VERSION" \
     '.skeleton.commit = $commit | .skeleton.syncedAt = $date | .skeleton.version = $ver' \
     "$SKELETON_JSON" > "$TMP"
  mv "$TMP" "$SKELETON_JSON"
  success "skeleton.json updated (version=$SKELETON_VERSION, commit=$LATEST_SHORT)"
fi

# ---------------------------------------------------------------------------
# Run validator
# ---------------------------------------------------------------------------
if [ "$DRY_RUN" = false ] && [ "$APPLIED" -gt 0 ]; then
  heading "Validating Configuration"
  if [ -f "scripts/validate-ai-config.sh" ]; then
    bash scripts/validate-ai-config.sh || warn "Validator found issues — review above"
  fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
heading "Sync Complete"
echo ""
echo -e "  ${GREEN}Applied (auto)${NC}   : $APPLIED files"
echo -e "  ${YELLOW}Skipped (manual)${NC} : $SKIPPED files — merge these manually"
if [ ${#PROJECT_TEMPLATE_CHANGES[@]} -gt 0 ]; then
  echo -e "  ${CYAN}Template notices${NC} : ${#PROJECT_TEMPLATE_CHANGES[@]} project-owned files changed in skeleton"
fi
echo ""
if [ "$DRY_RUN" = false ] && [ "$APPLIED" -gt 0 ]; then
  echo "Suggested next steps:"
  echo "  1. Review changes: git diff"
  echo "  2. Stage and commit: git add -p && git commit -m 'chore: sync skeleton to $LATEST_SHORT'"
  [ "$SKIPPED" -gt 0 ] && echo "  3. Merge skipped files manually, then commit"
else
  [ "$DRY_RUN" = true ] && echo "  (Dry run — no files changed)"
fi
echo ""
