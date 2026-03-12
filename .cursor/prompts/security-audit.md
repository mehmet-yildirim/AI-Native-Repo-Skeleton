Perform a comprehensive security evaluation of the specified target — code changes, a module, a full codebase scan, or a dependency manifest.

Reference the relevant source files and dependency manifests before producing findings.

---

## Step 1: Determine Scan Scope

Identify scope from what is provided:
- **Full / empty** → scan entire repository (dependency audit + SAST + secrets)
- **File or directory path** → scan that path only
- **PR / branch** → scan diff from `git diff main...HEAD`
- **"deps"** → dependency CVE scan only
- **"secrets"** → secret / credential scan only

Identify the tech stack from the loaded project rules — language, framework, and tooling determine which SAST rules and CVE scanners apply.

---

## Step 2: Dependency CVE Scan

Run the appropriate dependency auditor in your terminal:

```bash
# Node.js
npm audit --audit-level=none --json > .agent/audit/deps-scan.json

# Python
pip-audit --format=json --output=.agent/audit/deps-scan.json

# Java (Maven)
mvn org.owasp:dependency-check-maven:check -Dformat=JSON -DoutputDirectory=.agent/audit/

# .NET
dotnet list package --vulnerable --include-transitive --format json > .agent/audit/deps-scan.json

# Go
govulncheck ./... 2>&1 | tee .agent/audit/deps-scan.txt

# iOS / Flutter
osv-scanner --lockfile Package.resolved --format json > .agent/audit/deps-scan.json
```

Report all findings. For each vulnerability:
- Package name and version
- CVE ID and CVSS score
- Severity (CRITICAL / HIGH / MEDIUM / LOW)
- Affected version range and fixed version
- Recommended action

---

## Step 3: SAST — Static Application Security Testing

Run Semgrep (universal) in your terminal:

```bash
semgrep --config=auto \
        --config=p/owasp-top-ten \
        --config=p/secrets \
        --json \
        --output=.agent/audit/sast-results.json \
        .
```

Language-specific:
```bash
# JS/TS
npx eslint . --format json > .agent/audit/eslint-security.json 2>/dev/null || true

# Python
bandit -r . -f json -o .agent/audit/bandit.json 2>/dev/null || true

# Go
gosec -fmt=json -out=.agent/audit/gosec.json ./... 2>/dev/null || true
```

After running tools, perform AI-assisted pattern analysis on the target files checking each OWASP Top 10 category.

---

## Step 4: OWASP Top 10 Assessment

For each category, examine the code in scope and report findings:

### A01 — Broken Access Control
- [ ] Missing authorization checks before resource access
- [ ] IDOR: client-supplied IDs used without server-side ownership verification
- [ ] Privilege escalation paths (user → admin without check)
- [ ] CORS misconfiguration (wildcard `*` on sensitive endpoints)
- [ ] Missing rate limiting on sensitive operations

### A02 — Cryptographic Failures
- [ ] Sensitive data (PII, passwords, tokens) transmitted without TLS
- [ ] Weak algorithms: MD5, SHA1, DES, RC4 in any cryptographic context
- [ ] Hardcoded encryption keys or salts
- [ ] Passwords stored without bcrypt/Argon2/scrypt
- [ ] Weak random number generators for security-sensitive values

### A03 — Injection
- [ ] SQL injection: string concatenation into SQL
- [ ] NoSQL injection: unvalidated objects passed to DB operators
- [ ] Command injection: `exec()`, `system()`, `subprocess.run(shell=True)` with user data
- [ ] Template injection: user input rendered by template engines without escaping

### A04 — Insecure Design
- [ ] Missing rate limiting on authentication, password reset, OTP endpoints
- [ ] Lack of account lockout after failed attempts
- [ ] Business logic flaws (e.g., can buy items at negative price)
- [ ] Mass assignment: blindly accepting all user-provided fields

### A05 — Security Misconfiguration
- [ ] Default credentials or example secrets left in code
- [ ] Debug mode or verbose stack traces in production configs
- [ ] Missing security headers (`CSP`, `X-Frame-Options`, `HSTS`)
- [ ] Overly permissive CORS on auth endpoints
- [ ] Environment-specific secrets committed to version control

### A06 — Vulnerable and Outdated Components
- Covered by Step 2. Additionally:
- [ ] Unmaintained libraries (last release > 2 years ago)
- [ ] Runtime/language version out of security support window

### A07 — Identification and Authentication Failures
- [ ] Weak session token generation (non-cryptographic random)
- [ ] Session not invalidated on logout
- [ ] JWT: `alg: none` accepted, weak secret, missing expiry
- [ ] Password reset tokens: long-lived, reusable, or guessable

### A08 — Software and Data Integrity Failures
- [ ] Deserialization of untrusted data (Java ObjectInputStream, Python pickle)
- [ ] Dependencies fetched without integrity verification (no lockfile)
- [ ] CI/CD pipeline allows unauthorized injection of build artifacts

### A09 — Security Logging and Monitoring Failures
- [ ] Failed authentication attempts not logged
- [ ] PII or sensitive data appearing in log statements
- [ ] No correlation IDs in logs

### A10 — Server-Side Request Forgery (SSRF)
- [ ] User-controlled URLs fetched by the server
- [ ] No URL allowlist validation before fetch
- [ ] Internal metadata endpoints reachable: `169.254.169.254`

---

## Step 5: Secret / Credential Scan

Run in your terminal:

```bash
# gitleaks
gitleaks detect --source=. --format=json \
  --report-path=.agent/audit/secrets-scan.json 2>/dev/null || \
  echo "Install: brew install gitleaks"

# truffleHog
trufflehog filesystem . --json > .agent/audit/trufflehog.json 2>/dev/null || true
```

Also scan manually for:
- AWS access keys (`AKIA[0-9A-Z]{16}`)
- Private keys (`-----BEGIN RSA PRIVATE KEY-----`)
- Generic API keys (`[Aa]pi[_-]?[Kk]ey\s*=\s*['"][^'"]{20,}`)
- Database passwords in connection strings

---

## Step 6: Infrastructure-as-Code Security (if applicable)

```bash
hadolint Dockerfile --format=json 2>/dev/null || true
checkov -d . --framework terraform --output json 2>/dev/null || true
actionlint .github/workflows/*.yml 2>/dev/null || true
```

---

## Step 7: Compile Security Report

```
## Security Audit Report
**Date**: <ISO timestamp>
**Scope**: <what was scanned>
**Overall Risk**: CRITICAL | HIGH | MEDIUM | LOW | CLEAN

---

### CRITICAL Issues (must fix before any deployment)
| # | Category | File:Line | Finding | CVE/CWE | Remediation |
|---|----------|-----------|---------|---------|-------------|

### HIGH Issues (fix before next release)
...

### MEDIUM Issues (fix within 2 sprints)
...

### Dependency CVEs
| Package | Version | CVE | CVSS | Severity | Fix Version |
...

### Secrets Found
| File | Line | Type | Action Required |
...

---

### Summary Metrics
- Total findings: N
- Critical: N | High: N | Medium: N | Low: N
- OWASP categories with findings: A01, A03, ...

### Recommendation
BLOCK_DEPLOYMENT | REVIEW_REQUIRED | APPROVED_WITH_NOTES | CLEAN
```

---

**Target to scan** (leave empty for full scan, or specify path / "deps" / "secrets"):
