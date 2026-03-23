# Security Evaluator — Architecture & Operations Guide

The security evaluator is a cross-cutting concern that runs at multiple points in both the
human-guided and autonomous development workflows. This document describes its architecture,
integration points, severity handling, and remediation workflow.

---

## Why a Dedicated Security Evaluator?

Standard QA (`/qa`) validates correctness, coverage, and code quality. Security evaluation
is a distinct concern because:

1. **Different tools**: SAST scanners, CVE databases, secret detectors — not covered by linters or test runners
2. **Different expertise**: OWASP patterns require security-specific knowledge
3. **Different thresholds**: A CRITICAL security finding blocks deployment even if all tests pass
4. **Audit requirements**: Security findings must be logged, tracked, and signed off
5. **Autonomous agents produce more code, faster** — security gates must be automated

---

## Integration Points

### In Human-Guided Development

```
Developer workflow:
  /implement ──▶ /qa ──▶ /security-audit ──▶ /review ──▶ PR open
                              │
                     CRITICAL/HIGH found?
                              │
                    YES: Fix before PR
                    NO:  Proceed with findings documented in PR
```

When to run `/security-audit`:
- Before every PR that touches: auth, authorization, user input handling, payments, data export, external API integration
- After every dependency upgrade
- Weekly full scan of the entire codebase
- Before every production deployment

### In the Autonomous Agent Loop

Security evaluation is integrated as a mandatory gate in `/loop`:

```
/loop execution:
  ...implement... ──▶ /qa ──▶ /security-audit ──▶ create PR
                                     │
                         CRITICAL/HIGH findings?
                                     │
                   YES: /escalate critical security_vulnerability_detected
                   NO (MEDIUM/LOW only): include findings in PR description
                                         proceed with creating PR
```

The agent **never creates a PR** with CRITICAL security findings unresolved.

### In CI Pipeline

Security evaluation also runs in CI as an independent quality gate, catching any findings
that might have slipped through:

```yaml
# .github/workflows/ci.yml — add this job
  security:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for secret scanning

      - name: Dependency CVE Audit
        run: |
          # Adjust for your stack:
          npm audit --audit-level=high        # Node.js
          # pip-audit                         # Python
          # govulncheck ./...                 # Go
          # dotnet list package --vulnerable  # .NET

      - name: SAST — Semgrep
        uses: semgrep/semgrep-action@v1
        with:
          config: >-
            p/owasp-top-ten
            p/secrets
            p/security-audit
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}  # Optional — for Semgrep Cloud

      - name: Secret Scanning — Gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Upload Security Report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: security-report-${{ github.sha }}
          path: .agent/audit/*-security-report.json
```

---

## Severity Classification

### Severity Levels & Actions

| Severity | Definition | Agent Action | Human Action |
|----------|-----------|-------------|-------------|
| **CRITICAL** | Exploitable vulnerability with direct business impact (RCE, auth bypass, data breach) | Block PR creation. `/escalate critical`. Do not deploy. | Fix immediately. Security lead review required before merge. |
| **HIGH** | Significant vulnerability, likely exploitable (SQL injection, insecure deserialization, hardcoded secret) | Block PR creation. Attempt auto-fix. If fix fails → `/escalate high`. | Fix before this sprint ends. |
| **MEDIUM** | Vulnerability requiring specific conditions to exploit (missing rate limit, weak cipher for non-sensitive data) | Create PR with findings documented. No block. | Fix within 2 sprints. Add to security backlog. |
| **LOW** | Defense-in-depth improvement (missing security header, verbose error messages) | Include in PR description as notes. | Fix when convenient. |
| **INFO** | Informational — no immediate risk | Log only. | Track for awareness. |

### CVSS Score → Severity Mapping (for CVEs)

| CVSS Score | Severity |
|-----------|---------|
| 9.0 – 10.0 | CRITICAL |
| 7.0 – 8.9  | HIGH |
| 4.0 – 6.9  | MEDIUM |
| 0.1 – 3.9  | LOW |
| 0.0        | INFO |

---

## Autonomous Agent Security Gate — Detailed Flow

```
After /implement (all tasks committed to branch):
                │
                ▼
    Run /security-audit diff
    (scans only changed files + dependency manifests)
                │
    ┌───────────────────────────────────────────────────┐
    │ Parse security-report.json                        │
    │ Check: ciGate.blockMerge == true?                 │
    └───────────────────────────────────────────────────┘
                │
    ┌───────────┬──────────────────────────────────┐
    │ CRITICAL or HIGH findings?                   │
    └──────────────────────────────────────────────┘
         │ YES                           │ NO
         ▼                               ▼
  Attempt auto-remediation:        Proceed to /qa
  ─ CVE with upgrade available?
    → upgrade package + commit
    → re-run security-audit
    │
  ─ CRITICAL code pattern?
    → apply known fix pattern
    → re-run security-audit
    │
  ─ Still CRITICAL/HIGH after retry?
    → /escalate critical|high
        security_vulnerability_detected
    → BLOCK — await AGENT_RESUME
         │
    Human reviews + fixes
    → AGENT_RESUME
    → re-run security-audit
    → if clean → proceed to /qa
```

### Auto-Remediation Capabilities

The agent can automatically fix:

| Finding | Auto-fix |
|---------|---------|
| CVE in `package.json` with non-breaking upgrade | `npm update <package>` + commit |
| CVE in `pyproject.toml` with available patch | `pip install <package>==<fixed>` + commit |
| CVE in `go.mod` | `go get <module>@<fixed>` + `go mod tidy` + commit |
| Hardcoded secret in new file (never committed) | Remove the secret, add to `.env.example`, load from env |
| Missing `HttpOnly` / `Secure` cookie flag | Apply the flag in the response configuration |

The agent **cannot** auto-fix:
- Logic-level access control flaws (require understanding business rules)
- SQL injection in complex query builders (risk of breaking behavior)
- Deserialization vulnerabilities (require architectural change)
- Secrets that have already been committed to git history (require `git filter-repo`)

---

## Scheduled Security Scans

Beyond per-PR scans, schedule these recurring security evaluations:

| Scan | Frequency | Scope | Trigger |
|------|-----------|-------|---------|
| Full SAST | Weekly | Entire codebase | Cron every Monday 02:00 |
| Dependency CVE | Daily | All dependency manifests | Cron or Dependabot |
| Secret scan | On every push | Full git history delta | CI hook |
| IaC scan | On infra changes | Terraform / K8s / Dockerfiles | CI on path filter |
| License audit | Monthly | All dependencies | Cron |

### Systemd Timer for Weekly Full Scan

```ini
# /etc/systemd/system/ai-agent-security-scan.service
[Unit]
Description=AI Agent — Weekly Full Security Scan

[Service]
Type=oneshot
User=ai-agent
WorkingDirectory=/opt/ai-agent/project
EnvironmentFile=/opt/ai-agent/.env
ExecStart=/usr/bin/claude --headless "/security-audit full"
StandardOutput=append:/var/log/ai-agent/security-scan.log

[Install]
WantedBy=multi-user.target
```

```ini
# /etc/systemd/system/ai-agent-security-scan.timer
[Timer]
OnCalendar=Mon *-*-* 02:00:00
Persistent=true
Unit=ai-agent-security-scan.service

[Install]
WantedBy=timers.target
```

---

## Security Finding Lifecycle

### Issue Tracker Integration

CRITICAL and HIGH findings automatically create tracker issues:

```
CRITICAL finding detected:
  1. Create Jira issue:
     Type:    Bug
     Priority: Highest
     Labels:  security, critical, agent-security-finding
     Summary: [SECURITY-CRITICAL] <finding title>
     Description: <full finding from security-report.json>
     Due date: TODAY (CRITICAL) / end of sprint (HIGH)

  2. Link to the PR that introduced the finding (if known)
  3. Assign to security lead or team lead
  4. Comment on original feature PR: "Blocked by security finding: <issue-url>"
```

### Finding States

```
OPEN → IN_REMEDIATION → FIXED → VERIFIED → CLOSED
              │
              └─ ACCEPTED_RISK (needs security lead sign-off + documented justification)
              └─ FALSE_POSITIVE (mark in security-report.json; add suppression rule)
```

### Suppressing False Positives

When a finding is confirmed as a false positive, suppress it to prevent noise:

```json
// In .agent/security-suppressions.json
{
  "suppressions": [
    {
      "ruleId": "semgrep.generic.secrets.keychain",
      "path": "src/auth/keychain-helper.ts",
      "reason": "This is a wrapper around the OS keychain — not a hardcoded secret",
      "addedBy": "dev@company.com",
      "addedAt": "2024-03-09",
      "expiresAt": "2024-09-09"
    }
  ]
}
```

The agent reads this file and excludes suppressed findings from reports.
Suppressions expire — they must be renewed to prevent permanent blind spots.

---

## Security Metrics & KPIs

Track these metrics to assess security posture over time:

| Metric | Target | Source |
|--------|--------|--------|
| Mean Time to Remediate CRITICAL | < 24 hours | Jira issue created → closed |
| Mean Time to Remediate HIGH | < 1 sprint | Jira |
| Open CRITICAL / HIGH count | 0 CRITICAL, < 5 HIGH | Security report |
| Dependency CVE age (HIGH+) | < 7 days unpatched | deps scan |
| False positive rate | < 10% | suppression log |
| Secrets committed to git | 0 | gitleaks scan |
| Security findings per PR | Trending down | report history |

---

## Security Tool Stack — Recommended Setup

Install these tools on the agent host for automated scanning:

```bash
# Semgrep — SAST (universal)
pip install semgrep
# or: brew install semgrep

# Gitleaks — secret scanning
# macOS: brew install gitleaks
# Linux: see https://github.com/gitleaks/gitleaks/releases
wget https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_linux_x64.tar.gz
tar -xf gitleaks_linux_x64.tar.gz && sudo mv gitleaks /usr/local/bin/

# OSV Scanner — multi-ecosystem CVE scanning
go install github.com/google/osv-scanner/cmd/osv-scanner@latest
# or: brew install osv-scanner

# Hadolint — Dockerfile security
brew install hadolint
# Linux: wget https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64

# Trivy — container + IaC security
brew install aquasecurity/trivy/trivy
# Linux: apt install trivy

# Language-specific (install based on project stack):
npm install -g retire          # Node.js retired/vulnerable packages
pip install pip-audit bandit   # Python
go install golang.org/x/vuln/cmd/govulncheck@latest  # Go
```

Verify all tools are available:
```bash
for tool in semgrep gitleaks osv-scanner trivy hadolint; do
  command -v $tool && echo "OK: $tool" || echo "MISSING: $tool"
done
```
