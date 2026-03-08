#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# AI-Native Repo Skeleton — Project Setup Script
# =============================================================================
# Run this once after cloning the skeleton to initialize your project.
# =============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

echo ""
echo "========================================"
echo "  AI-Native Project Setup"
echo "========================================"
echo ""

# ---------------------------------------------------------------------------
# 1. Initialize git repository (if not already a repo)
# ---------------------------------------------------------------------------
if [ ! -d ".git" ]; then
  info "Initializing git repository..."
  git init
  success "Git repository initialized."
else
  info "Git repository already exists, skipping init."
fi

# ---------------------------------------------------------------------------
# 2. Remove skeleton remote origin (if inherited from clone)
# ---------------------------------------------------------------------------
if git remote get-url origin &>/dev/null 2>&1; then
  REMOTE=$(git remote get-url origin)
  if [[ "$REMOTE" == *"AI-Native-Repo-Skeleton"* ]]; then
    warn "Removing skeleton remote origin: $REMOTE"
    git remote remove origin
    success "Removed skeleton remote. Add your own with: git remote add origin <url>"
  fi
fi

# ---------------------------------------------------------------------------
# 3. Create .env from .env.example if it doesn't exist
# ---------------------------------------------------------------------------
if [ -f ".env.example" ] && [ ! -f ".env" ]; then
  info "Creating .env from .env.example..."
  cp .env.example .env
  success "Created .env — fill in your values before starting development."
elif [ ! -f ".env.example" ]; then
  warn "No .env.example found. Create one with your required environment variables."
else
  info ".env already exists, skipping."
fi

# ---------------------------------------------------------------------------
# 4. Validate required AI tool configurations
# ---------------------------------------------------------------------------
info "Checking AI tool configuration files..."

MISSING_CONFIG=false

check_file() {
  local file="$1"
  local label="$2"
  if [ -f "$file" ]; then
    success "$label: $file"
  else
    warn "$label not found: $file"
    MISSING_CONFIG=true
  fi
}

check_file "CLAUDE.md"                    "Claude Code config"
check_file ".cursor/rules/00-project-overview.mdc" "Cursor project overview"
check_file ".continue/config.yaml"        "Continue config"

if [ "$MISSING_CONFIG" = true ]; then
  warn "Some AI config files are missing. Run: bash scripts/validate-ai-config.sh"
fi

# ---------------------------------------------------------------------------
# 5. Remind about customization
# ---------------------------------------------------------------------------
echo ""
echo "========================================"
echo "  Next Steps"
echo "========================================"
echo ""
echo "  REQUIRED — customize before coding:"
echo "  1. Edit CLAUDE.md with project name, stack, and commands"
echo "  2. Edit .cursor/rules/00-project-overview.mdc"
echo "  3. Edit .continue/config.yaml (add API keys)"
echo "  4. Fill in docs/context/project-brief.md"
echo "  5. Fill in docs/context/tech-stack.md"
echo "  6. Fill in docs/architecture/overview.md"
echo ""
echo "  THEN:"
echo "  7. Add your git remote:  git remote add origin <url>"
echo "  8. Install dependencies: [your install command]"
echo "  9. Read the AI workflow: docs/ai-workflow.md"
echo ""
echo "  AI commands available in Claude Code (type / to invoke):"
echo "  /architect  — design a feature before implementing"
echo "  /review     — review code for issues"
echo "  /test       — generate tests"
echo "  /debug      — systematic debugging"
echo "  /docs       — generate documentation"
echo "  /standup    — summarize recent work"
echo ""

success "Setup complete!"
