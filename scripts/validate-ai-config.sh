#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# AI Configuration Validator
# Checks that all AI tool config files are present and customized.
# =============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PASS=0
WARN=0
FAIL=0

pass() { echo -e "  ${GREEN}PASS${NC} $*"; PASS=$((PASS + 1)); }
warn() { echo -e "  ${YELLOW}WARN${NC} $*"; WARN=$((WARN + 1)); }
fail() { echo -e "  ${RED}FAIL${NC} $*"; FAIL=$((FAIL + 1)); }

echo ""
echo "========================================"
echo "  AI Configuration Validator"
echo "========================================"

# ---------------------------------------------------------------------------
# File existence checks
# ---------------------------------------------------------------------------
echo ""
echo "--- File Presence ---"

check_exists() {
  local file="$1"
  if [ -f "$file" ]; then
    pass "Found: $file"
    return 0
  else
    fail "Missing: $file"
    return 1
  fi
}

check_exists "CLAUDE.md"
check_exists ".cursor/rules/00-project-overview.mdc"
check_exists ".cursor/rules/01-coding-standards.mdc"
check_exists ".cursor/rules/02-architecture.mdc"
check_exists ".cursor/rules/03-testing.mdc"
check_exists ".cursor/rules/04-git-workflow.mdc"
check_exists ".cursor/rules/05-security.mdc"
check_exists ".cursor/mcp.json"
check_exists ".continue/config.yaml"
check_exists ".continue/rules/01-coding-standards.md"
check_exists ".continue/rules/02-architecture.md"
check_exists ".continue/rules/03-testing.md"
check_exists ".continue/rules/04-security.md"
check_exists ".claude/commands/init.md"
check_exists ".claude/commands/requirements.md"
check_exists ".claude/commands/architect.md"
check_exists ".claude/commands/implement.md"
check_exists ".claude/commands/review.md"
check_exists ".claude/commands/qa.md"
check_exists ".claude/commands/test.md"
check_exists ".claude/commands/debug.md"
check_exists ".claude/commands/deploy.md"
check_exists ".claude/commands/migrate.md"
check_exists ".claude/commands/infra.md"
check_exists ".claude/commands/db.md"
check_exists ".claude/commands/sprint.md"
check_exists ".claude/commands/docs.md"
check_exists ".claude/commands/standup.md"
check_exists ".claude/commands/security-audit.md"
check_exists ".claude/commands/triage.md"
check_exists ".claude/commands/groom.md"
check_exists ".claude/commands/loop.md"
check_exists ".claude/commands/escalate.md"

# --- Autonomous agent config & docs ---
check_exists "agent.config.yaml"
check_exists "docs/context/domain-boundaries.md"
check_exists "docs/agent/autonomous-workflow.md"
check_exists "docs/agent/escalation-protocol.md"
check_exists "docs/agent/decision-log-template.md"
check_exists "docs/agent/jira-server-setup.md"
check_exists "docs/agent/documentation-agent.md"
check_exists ".claude/commands/doc-api.md"
check_exists ".claude/commands/doc-site.md"
check_exists ".claude/commands/doc-changelog.md"
check_exists ".claude/commands/doc-schema.md"
check_exists ".agent-templates/webhook-receiver.mjs"
check_exists "docs/agent/schemas/task-state.json"
check_exists "docs/agent/schemas/decision.json"
check_exists "docs/agent/schemas/requirement-analysis.json"
check_exists "docs/agent/schemas/qa-report.json"
check_exists ".claude/hooks/post-write.mjs"
check_exists ".claude/hooks/audit-log.mjs"
check_exists ".claude/hooks/on-stop.mjs"

# --- Skill rules ---
check_exists ".cursor/rules/skills/lang-java.mdc"
check_exists ".cursor/rules/skills/lang-dotnet.mdc"
check_exists ".cursor/rules/skills/lang-python.mdc"
check_exists ".cursor/rules/skills/lang-typescript.mdc"
check_exists ".cursor/rules/skills/lang-go.mdc"
check_exists ".cursor/rules/skills/fe-react.mdc"
check_exists ".cursor/rules/skills/fe-nextjs.mdc"
check_exists ".cursor/rules/skills/fe-vue.mdc"
check_exists ".cursor/rules/skills/fe-angular.mdc"
check_exists ".cursor/rules/skills/be-microservices.mdc"
check_exists ".cursor/rules/skills/devops-docker.mdc"
check_exists ".cursor/rules/skills/devops-cicd.mdc"
check_exists ".cursor/rules/skills/security-sast.mdc"
check_exists ".cursor/rules/skills/docs-generation.mdc"
check_exists ".cursor/rules/skills/db-migrations.mdc"
check_exists ".cursor/rules/skills/devops-aws.mdc"
check_exists ".cursor/rules/skills/devops-gcp.mdc"
check_exists ".cursor/rules/skills/devops-onprem.mdc"
check_exists ".cursor/rules/skills/mobile-ios.mdc"
check_exists ".cursor/rules/skills/mobile-android.mdc"
check_exists ".cursor/rules/skills/mobile-kmp.mdc"
check_exists ".cursor/rules/skills/mobile-flutter.mdc"
check_exists ".cursor/rules/skills/mobile-reactnative.mdc"

# --- Continue skill rules ---
check_exists ".continue/rules/skills/lang-java.md"
check_exists ".continue/rules/skills/lang-dotnet.md"
check_exists ".continue/rules/skills/lang-python.md"
check_exists ".continue/rules/skills/fe-react.md"
check_exists ".continue/rules/skills/fe-nextjs.md"
check_exists ".continue/rules/skills/fe-vue.md"
check_exists ".continue/rules/skills/fe-angular.md"
check_exists ".continue/rules/skills/mobile-ios.md"
check_exists ".continue/rules/skills/mobile-android.md"
check_exists ".continue/rules/skills/mobile-kmp.md"
check_exists ".continue/rules/skills/mobile-flutter.md"
check_exists ".continue/rules/skills/mobile-reactnative.md"
check_exists ".continue/rules/skills/lang-typescript.md"
check_exists ".continue/rules/skills/lang-go.md"
check_exists ".continue/rules/skills/be-microservices.md"
check_exists ".continue/rules/skills/devops-docker.md"
check_exists ".continue/rules/skills/devops-cicd.md"
check_exists ".continue/rules/skills/security-sast.md"
check_exists ".continue/rules/skills/docs-generation.md"
check_exists ".continue/rules/skills/db-migrations.md"
check_exists ".continue/rules/skills/devops-aws.md"
check_exists ".continue/rules/skills/devops-gcp.md"
check_exists ".continue/rules/skills/devops-onprem.md"

# --- Workflow docs ---
check_exists "docs/workflows/01-requirements-analysis.md"
check_exists "docs/workflows/02-feature-development.md"
check_exists "docs/workflows/03-testing-strategy.md"
check_exists "docs/workflows/04-deployment.md"
check_exists "docs/workflows/05-security-evaluation.md"
check_exists "docs/workflows/06-database-migrations.md"
check_exists "docs/workflows/07-deployment-platforms.md"
check_exists "skills/README.md"
check_exists "docs/agent/security-evaluator.md"
check_exists "docs/agent/schemas/security-report.json"

check_exists "docs/context/project-brief.md"
check_exists "docs/context/tech-stack.md"
check_exists "docs/context/domain-boundaries.md"
check_exists "docs/context/domain-glossary.md"
check_exists "docs/architecture/overview.md"

# --- Skeleton sync ---
check_exists "skeleton.json"
check_exists "SKELETON-UPDATES.md"
check_exists "scripts/sync-skeleton.sh"
check_exists "scripts/sync-skeleton.ps1"
check_exists "scripts/sync-skeleton.cmd"
check_exists "docs/skeleton-sync.md"
check_exists ".claude/commands/sync-skeleton.md"

# --- Scripts ---
check_exists "scripts/setup.sh"
check_exists "scripts/setup.ps1"
check_exists "scripts/setup.cmd"
check_exists "scripts/init.sh"
check_exists "scripts/init.ps1"
check_exists "scripts/init.cmd"

# ---------------------------------------------------------------------------
# Customization checks (look for TODO placeholders)
# ---------------------------------------------------------------------------
echo ""
echo "--- Customization (TODO placeholders remaining) ---"

check_customized() {
  local file="$1"
  if [ ! -f "$file" ]; then
    return
  fi
  local todo_count
  todo_count=$(grep -c "^TODO\|: TODO\|TODO:" "$file" 2>/dev/null || true)
  if [ "$todo_count" -eq 0 ]; then
    pass "Customized: $file"
  else
    warn "$file has $todo_count TODO(s) remaining"
  fi
}

check_customized "CLAUDE.md"
check_customized "skeleton.json"
check_customized ".cursor/rules/00-project-overview.mdc"
check_customized "docs/context/project-brief.md"
check_customized "docs/context/tech-stack.md"
check_customized "docs/context/domain-boundaries.md"
check_customized "docs/architecture/overview.md"
check_customized "agent.config.yaml"

# ---------------------------------------------------------------------------
# Environment check
# ---------------------------------------------------------------------------
echo ""
echo "--- Environment ---"

if [ -f ".env" ]; then
  pass "Found: .env"
else
  warn "Missing .env — copy from .env.example and fill in values"
fi

if [ -f ".env.example" ]; then
  pass "Found: .env.example"
else
  warn "Missing .env.example — create one to document required variables"
fi

# ---------------------------------------------------------------------------
# Git check
# ---------------------------------------------------------------------------
echo ""
echo "--- Git ---"

if [ -d ".git" ]; then
  pass "Git repository initialized"
else
  fail "No git repository — run: git init"
fi

if git remote get-url origin &>/dev/null 2>&1; then
  REMOTE=$(git remote get-url origin)
  pass "Remote origin: $REMOTE"
else
  warn "No remote origin set — run: git remote add origin <url>"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "========================================"
echo "  Results"
echo "========================================"
echo -e "  ${GREEN}PASS${NC}: $PASS"
echo -e "  ${YELLOW}WARN${NC}: $WARN"
echo -e "  ${RED}FAIL${NC}: $FAIL"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}Action required: fix FAIL items before starting development.${NC}"
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo -e "${YELLOW}Warnings present: review WARN items and customize as needed.${NC}"
  exit 0
else
  echo -e "${GREEN}All checks passed! You're ready to code.${NC}"
  exit 0
fi
