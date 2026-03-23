# Security Policy

## Supported Versions

Only the versions listed below receive security updates.

| Version | Supported |
| ------- | --------- |
| TODO: e.g., `1.x` | ✅ |
| TODO: e.g., `< 1.0` | ❌ |

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Please report vulnerabilities by emailing:

> **TODO: security@your-domain.com**

Include as much of the following as possible:

- Type of issue (e.g., SQL injection, XSS, authentication bypass)
- Affected component, file path, or endpoint
- Steps to reproduce
- Proof-of-concept or exploit code (if available)
- Impact assessment — what an attacker could achieve

We will acknowledge receipt within **48 hours** and aim to provide a remediation timeline within **7 days**.

## Disclosure Policy

This project follows **coordinated disclosure**:

1. You report the vulnerability privately.
2. We confirm and assess the severity.
3. We develop and test a fix.
4. We release the fix and credit you (unless you prefer anonymity).
5. You may publish details **90 days** after the initial report, or after the fix ships — whichever comes first.

## Security Practices

TODO: Describe your security controls. Examples below — keep what applies, remove the rest.

- All dependencies are scanned for known CVEs on every CI run.
- Secrets are managed via TODO (e.g., Vault, AWS Secrets Manager, environment variables).
- Authentication uses TODO (e.g., JWT, OAuth 2.0, session cookies with SameSite=Strict).
- Input validation is enforced at all API boundaries.
- SQL queries use parameterised statements — no string concatenation.
- HTTPS is enforced in all environments; HSTS is enabled in production.

## Known Security Gaps

TODO: List any accepted risks or temporarily unmitigated issues here, with a linked issue and target resolution date. Remove this section when empty.

| Gap | Issue | Target |
| --- | ----- | ------ |
| Example: rate limiting not yet implemented on /auth/login | #TODO | TODO |

## Security Contact

TODO: Add a GPG key fingerprint here if you accept encrypted reports.

```
TODO: GPG fingerprint (optional)
```
