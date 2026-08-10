Generate or update the project's CHANGELOG.md from git history using conventional commits.
Produces a well-structured, audience-appropriate changelog for the specified range.

---

## Step 1: Verify Prerequisites

Check that `cliff.toml` exists at the repo root. If missing, generate a default one:

```toml
# cliff.toml — git-cliff configuration
[changelog]
header = """
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
"""

body = """
{% if version %}\
    ## [{{ version | trim_start_matches(pat="v") }}] - {{ timestamp | date(format="%Y-%m-%d") }}
{% else %}\
    ## [Unreleased]
{% endif %}\
{% for group, commits in commits | group_by(attribute="group") %}
    ### {{ group | upper_first }}
    {% for commit in commits %}
        - {% if commit.breaking %}**[BREAKING]** {% endif %}\
          {{ commit.message | upper_first }} \
          ([`{{ commit.id | truncate(length=7, end="") }}`]({{ commit.id }}))\
          {%- if commit.author %} by @{{ commit.author }}{%- endif %}\
    {% endfor %}
{% endfor %}\n
"""

trim = true

[git]
conventional_commits = true
filter_unconventional = true
split_commits = false
commit_parsers = [
  { message = "^feat", group = "Features" },
  { message = "^fix", group = "Bug Fixes" },
  { message = "^perf", group = "Performance" },
  { message = "^refactor", group = "Refactoring" },
  { message = "^test", group = "Testing" },
  { message = "^docs", group = "Documentation" },
  { message = "^ci", group = "CI/CD" },
  { message = "^chore\\(deps\\)", group = "Dependencies" },
  { message = "^chore", skip = true },
  { body = ".*security", group = "Security" },
]
protect_breaking_commits = false
filter_commits = false
tag_pattern = "v[0-9].*"
skip_tags = "v0.1.0-beta.1"
ignore_tags = ""
sort_commits = "oldest"
```

---

## Step 2: Determine Scope

Parse `$ARGUMENTS` to determine what range to generate:

| Argument | Behaviour |
|----------|-----------|
| (empty) | Full changelog from all tags |
| `unreleased` | Only commits since the last tag |
| `v1.2.0..HEAD` | Commits in a specific range |
| `--tag v2.0.0` | Generate changelog for a specific release |
| `--since 2024-01-01` | Commits since a date |

---

## Step 3: Verify Commit Convention Quality

Before generating, scan recent commits for quality:

```bash
git log --oneline -50
```

Report:
- Percentage of commits following conventional format
- Any commits that will be filtered out (`chore`, non-conventional)
- Breaking changes detected (commits with `!` or `BREAKING CHANGE:` footer)
- New features (`feat:`) that need to be highlighted

If more than 30% of commits are non-conventional, warn:
> "Many commits do not follow conventional commit format. Consider using
> `git-cliff --unreleased --tag vX.Y.Z` to generate a summary and manually
> curate it before publishing."

---

## Step 4: Generate the Changelog

```bash
# Install git-cliff (if not available)
# macOS:  brew install git-cliff
# Linux:  cargo install git-cliff
# Docker: docker run orhunp/git-cliff

# Full changelog
git-cliff --output CHANGELOG.md

# Unreleased only (append to existing CHANGELOG.md)
git-cliff --unreleased --prepend CHANGELOG.md

# For a specific version release
git-cliff --tag vX.Y.Z --output CHANGELOG.md

# Since a date
git-cliff --since "2024-01-01" --output CHANGELOG.md
```

---

## Step 5: Generate a Stakeholder-Friendly Release Summary

In addition to the developer changelog, produce a non-technical summary
suitable for product announcements, release notes, and executive communications:

For each `feat:` commit, extract:
- User-facing impact (what can users now do that they couldn't before?)
- Business value statement
- Affected user type (developer, admin, end user)

For each `fix:` commit:
- What was broken and how it affected users
- Severity (critical, major, minor)

Example stakeholder format:
```markdown
## Release v2.1.0 — What's New

### New Features
- **Payment Retry Logic**: Failed payments now automatically retry up to 3 times,
  reducing failed transaction rates by an estimated 15-20%.
- **Order Export**: Merchants can now export order history to CSV directly from the dashboard.

### Bug Fixes
- **Fixed**: Order status occasionally showed "Pending" after successful delivery.
  This affected ~2% of orders.

### Performance Improvements
- Dashboard loads 40% faster for merchants with more than 10,000 orders.
```

---

## Step 6: Validate for Breaking Changes

Scan for breaking change markers and generate a migration guide if needed:

```bash
# Find breaking changes
git log --oneline | grep -E "^[a-f0-9]+ (feat|fix|refactor)(\(.+\))?!:"
git log --format="%B" | grep -A5 "BREAKING CHANGE:"
```

If breaking changes are found, generate a migration section:

```markdown
## Migration Guide — v1.x → v2.0

### Breaking Changes

#### API: `POST /users` — `username` field removed
**Before:**
```json
{ "username": "jsmith", "email": "j@example.com" }
```
**After:** `username` is now auto-generated from `email`. Remove it from your requests.

#### SDK: `UserService.create()` signature changed
**Before:** `createUser(username: string, email: string)`
**After:** `createUser(email: string)` — username parameter removed
```

---

## Step 7: Output and Next Steps

```
Changelog Generated
═══════════════════════════════════════════════════════

Output file  : CHANGELOG.md
Range        : <range>
Releases     : N versions documented
Commits      : N total (N conventional, N skipped)

Highlights:
  New features  : N
  Bug fixes     : N
  Breaking changes: N  [MIGRATION GUIDE generated]
  Security fixes: N

Stakeholder summary: RELEASE-NOTES-vX.Y.Z.md

Next steps:
  1. Review and edit CHANGELOG.md — AI may misinterpret commit messages
  2. Verify breaking change section is complete
  3. Share stakeholder summary with product team
  4. Tag the release: git tag -a vX.Y.Z -m "Release vX.Y.Z"
  5. Commit: git add CHANGELOG.md && git commit -m "docs: update changelog for vX.Y.Z"
```

---

Target range or version (optional — e.g., "unreleased", "v1.0.0..HEAD", "--tag v2.0.0"): $ARGUMENTS
