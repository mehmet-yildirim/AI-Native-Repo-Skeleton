# Contributing to Initium

This guide is for contributors who want to improve **Initium itself** — the rules, skills, prompts, scripts, and documentation that ship with this template. If you are customizing Initium for your own project, see the [README](README.md) and [docs/ai-workflow.md](docs/ai-workflow.md) instead.

## Who This Is For

- Adding or improving skill files (language, framework, DevOps)
- Updating rules, prompts, or slash commands
- Improving documentation, scripts, or CI configuration
- Fixing bugs or gaps in Initium

## Repo Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/mehmet-yildirim/Initium.git
   cd Initium
   ```

2. Run the setup script for your platform:
   - **macOS / Linux**: `./.initium/scripts/setup.sh`
   - **Windows PowerShell**: `./.initium/scripts/setup.ps1`
   - **Windows (no PowerShell execution policy)**: `.initium\scripts\setup.cmd`

3. Run the init wizard if you want to test the full flow:
   - **macOS / Linux**: `./.initium/scripts/init.sh`
   - **Windows PowerShell**: `./.initium/scripts/init.ps1`
   - **Windows Batch**: `.initium\scripts\init.cmd`

## What Can Be Contributed

| Area | Location | Notes |
|------|----------|------|
| Skills | `.cursor/rules/skills/*.mdc`, `.continue/rules/skills/*.md` | Must maintain parity (see below) |
| Base rules | `.cursor/rules/*.mdc`, `.continue/rules/*.md` | Keep Cursor and Continue in sync |
| Prompts / Commands | `.cursor/prompts/`, `.claude/commands/` | Workflow prompts and slash commands |
| Docs | `docs/` | Architecture, workflows, agent, context |
| Scripts | `scripts/` | setup, init, validate-ai-config (sh, ps1, bat) |
| CI / GitHub | `.github/` | Workflows, PR template, issue templates |

## Skill Parity Rule (Critical)

Every new skill **must** be added to **both** AI tools:

1. **Cursor**: `.cursor/rules/skills/<name>.mdc` — uses YAML frontmatter (`description`, `globs`, `alwaysApply`)
2. **Continue**: `.continue/rules/skills/<name>.md` — no frontmatter; content only
3. **Continue config**: Register the new skill in `.continue/config.yaml` as a commented-out rule under the appropriate section (Language, Frontend, Mobile, Backend, DevOps)

File names must match across tools (e.g., `lang-go.mdc` ↔ `lang-go.md`).

## How to Add a New Skill

1. Create `.cursor/rules/skills/<name>.mdc` with frontmatter and content
2. Create `.continue/rules/skills/<name>.md` with the same content (strip frontmatter)
3. Add `# - .continue/rules/skills/<name>.md` to `.continue/config.yaml` in the correct section
4. Run `.initium/scripts/validate.sh` (or `.ps1` / `.cmd`) — all checks must pass
5. Update `skills/README.md` and `README.md` if the skill table needs a new row

## Naming Conventions

- **Skills**: `lang-<language>`, `fe-<framework>`, `mobile-<platform>`, `be-microservices`, `devops-docker`, `devops-cicd`, `security-sast`
- **Branches**: `feat/`, `fix/`, `docs/`, `chore/` prefix (see [.cursor/rules/04-git-workflow.mdc](.cursor/rules/04-git-workflow.mdc))
- **Commits**: Conventional Commits format — `feat: add X`, `fix: correct Y`, `docs: update Z`

## PR Guidelines

- Use the checklist in [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md)
- Ensure `validate-ai-config.sh` / `.ps1` / `.cmd` passes before opening a PR
- Keep PRs focused — one concern per PR
- Aim for &lt; 400 lines changed when possible

## Validate Before Submitting

Run the validation script for your platform:

```bash
# macOS / Linux
./.initium/scripts/validate.sh

# Windows PowerShell
./.initium/scripts/validate.ps1

# Windows Batch
.initium\scripts\validate.cmd
```

Expected output: `PASS` for all checks. Fix any `FAIL` before opening a PR.
