# Workflow: Security Evaluation

Security evaluation is not a one-time checklist — it runs continuously across the development
lifecycle. This guide defines when, how, and by whom security assessments are triggered for
both human-guided and autonomous development.

## Security Evaluation Touchpoints

```
Code written (human or agent)
        │
        ▼
Pre-commit hook ──── quick secret scan (gitleaks, < 2s)
        │
        ▼
PR creation ──────── /security-audit diff  (OWASP + SAST on changed files)
        │                     │
        │             CRITICAL/HIGH → block merge, create issue
        │             MEDIUM/LOW → document in PR, proceed
        ▼
CI pipeline ──────── full security job (SAST + CVE + secrets + IaC)
        │
        ▼
Staging deployment ── /deploy checklist includes CVE verification
        │
        ▼
Production deployment ── security sign-off required for HIGH risk changes
        │
        ▼
Weekly ──────────────── /security-audit full (entire codebase + all deps)
```

---

## When to Run /security-audit

### Always (Mandatory)
- Any PR touching: authentication, authorization, payment, user input processing, file operations, external API calls
- Any dependency upgrade (even patch version)
- Before any production deployment
- When the autonomous agent creates a PR

### Strongly Recommended
- After merging a large or complex feature branch
- When adding a new integration with an external service
- When changing data models that handle PII or financial data

### Scheduled (Automated)
- Daily: `npm audit` / `pip-audit` / `govulncheck` on all dependency manifests
- Weekly: Full SAST + dependency + secret scan of entire codebase
- Monthly: License audit for all dependencies

---

## Running /security-audit Manually

### Full codebase scan
```
/security-audit
```
or
```
/security-audit full
```

### Only the current branch changes
```
/security-audit diff
```
(Scans `git diff main...HEAD` — faster, used before PR creation)

### Dependencies only
```
/security-audit deps
```

### Secret scan only
```
/security-audit secrets
```

### Specific file or directory
```
/security-audit src/payments/
/security-audit src/api/users.ts
```

---

## Interpreting Results

The security audit outputs:
1. **Human-readable report** in the terminal (markdown table)
2. **JSON report** at `.agent/audit/<date>-security-report.json` (schema: `docs/agent/schemas/security-report.json`)

### Reading the overall verdict

| Verdict | Meaning | Action |
|---------|---------|--------|
| `BLOCK_DEPLOYMENT` | CRITICAL or HIGH finding in the diff | Fix before proceeding |
| `REVIEW_REQUIRED` | MEDIUM finding or HIGH with active CVE | Human security review; fix within sprint |
| `APPROVED_WITH_NOTES` | LOW / INFO findings only | Document in PR; fix when convenient |
| `CLEAN` | No findings | Proceed |

### What the autonomous agent does

| Verdict | Agent behavior |
|---------|---------------|
| `BLOCK_DEPLOYMENT` | Attempts auto-fix (CVE upgrade, obvious pattern). If fails → `/escalate critical security_vulnerability_detected` |
| `REVIEW_REQUIRED` | Adds findings to PR description. Tags PR with `security-review`. Does not block PR creation. |
| `APPROVED_WITH_NOTES` | Adds findings as PR comments. |
| `CLEAN` | Proceeds silently. |

---

## Remediation Workflow

### CRITICAL Findings

```
1. Stop current work
2. Identify the root cause (see finding.location and finding.evidence)
3. Apply fix (see finding.remediation.codeExample)
4. Re-run: /security-audit diff
5. Verify finding is gone
6. Add regression test that would catch this class of vulnerability
7. Commit fix with message: fix(security): <description> [CRITICAL]
```

If the CRITICAL finding involves a **committed secret**:
```bash
# Revoke the credential IMMEDIATELY (before fixing code)
# Then remove from git history:
git filter-repo --path <file> --invert-paths
# or for a specific string:
git filter-repo --replace-text <(echo "old-secret==>REMOVED")
# Force push (coordinate with team):
git push --force-with-lease origin main
# Notify team to re-clone
```

### HIGH Findings

```
1. Assess exploitability in current environment
2. If exploitable in production: treat as CRITICAL
3. If not immediately exploitable: fix within current sprint
4. Create a Jira ticket: [SECURITY-HIGH] <finding title>
5. Link ticket to the PR
6. Fix + re-scan + close ticket
```

### CVE Findings

```
1. Check: is a fix version available?
   - YES: upgrade to the fixed version; test; commit
   - NO: check for workarounds in the CVE advisory
     - Workaround available: implement and document
     - No workaround: assess risk; accept or remove the dependency

2. Upgrade command by stack:
   Node.js: npm update <package>@<fixed-version>
   Python:  pip install <package>==<fixed-version>
   Java:    update <version> in pom.xml or build.gradle.kts
   Go:      go get <module>@<version> && go mod tidy
   .NET:    dotnet add package <package> --version <fixed>

3. Run tests after upgrade (dependency upgrade may break things)
4. Document in commit message: fix(deps): upgrade <package> to fix CVE-YYYY-NNNNN
```

---

## Security in Code Review

When reviewing a PR (manually or with `/review`), always check:

### Access Control
- [ ] Does every endpoint that returns or modifies data verify the caller owns that data?
- [ ] Is there a way to access another user's data by changing an ID in the request?

### Input Handling
- [ ] Is all external input validated before use?
- [ ] Could any input reach a database query, shell command, or template without sanitization?

### Cryptography & Secrets
- [ ] Are any credentials hardcoded (even in test files)?
- [ ] Is `crypto.randomBytes` / `secrets.token_hex` used for security-sensitive randomness?
- [ ] Are passwords hashed with bcrypt/Argon2, not MD5/SHA?

### Session & Auth
- [ ] Is the session invalidated on logout?
- [ ] Are tokens rotated on privilege change?
- [ ] Are JWT claims verified (signature, expiry, issuer)?

### Logging
- [ ] Could any log line contain a token, password, or PII?

---

## Security Debt Tracking

Security findings that are deferred (MEDIUM / LOW) must be tracked:

1. Create a Jira issue: `[SECURITY-MEDIUM] <title>`
2. Label: `security`, `tech-debt`
3. Sprint target: 2 sprints from discovery date
4. Review in sprint planning: is the deferred finding still relevant?

**Never suppress findings without:**
- Written justification in `.agent/security-suppressions.json`
- Expiry date set (max 6 months)
- Security lead or team lead approval (comment on the Jira ticket)

---

## Compliance Mapping

If your project has compliance requirements, map security findings to controls:

| OWASP | NIST SP 800-53 | ISO 27001 | PCI DSS |
|-------|---------------|-----------|---------|
| A01 (Access Control) | AC-3, AC-6 | A.9 | Req 7 |
| A02 (Crypto) | SC-8, SC-13 | A.10 | Req 3, 4 |
| A03 (Injection) | SI-10 | A.14 | Req 6 |
| A05 (Misconfiguration) | CM-6, CM-7 | A.12 | Req 2, 6 |
| A06 (Components) | SI-2 | A.12 | Req 6 |
| A07 (Auth) | IA-2, IA-5 | A.9 | Req 8 |
| A09 (Logging) | AU-2, AU-12 | A.12 | Req 10 |

Use the JSON report's `owaspId` and `cweId` fields to generate compliance evidence artifacts.
