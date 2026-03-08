---
description: Security guidelines and OWASP protections. Always apply — security is non-negotiable.
globs:
alwaysApply: true
---

# Security Guidelines

Security is a first-class concern, not an afterthought. These rules apply to every line of code.

## OWASP Top 10 — Required Protections

### 1. Injection (SQL, Command, LDAP, NoSQL)
- **NEVER** concatenate user input into queries or shell commands
- Always use parameterized queries / prepared statements
- Use ORM query builders — never raw string interpolation with user data
- Validate and sanitize all external input before use

```typescript
// WRONG — SQL injection risk
db.query(`SELECT * FROM users WHERE email = '${email}'`);

// CORRECT — parameterized
db.query('SELECT * FROM users WHERE email = $1', [email]);
```

### 2. Broken Authentication
- Passwords must be hashed with bcrypt, Argon2, or scrypt — never MD5, SHA1, or plain
- Minimum password entropy enforced server-side
- Rate-limit login and password reset endpoints
- Implement account lockout after repeated failures
- Session tokens: cryptographically random, minimum 128 bits, rotated on privilege change

### 3. Sensitive Data Exposure
- Never log passwords, tokens, credit card numbers, or PII
- Sensitive fields must not appear in URLs (use POST body / headers)
- Encrypt PII at rest if required by compliance
- Use HTTPS everywhere — no mixed content
- Set appropriate `Cache-Control` headers for sensitive responses

### 4. Insecure Direct Object References (IDOR)
- Never trust client-supplied IDs for access control
- Always verify the authenticated user owns / has permission to access the resource
- Use opaque IDs (UUID) rather than sequential integers where feasible

```typescript
// WRONG — trusts client-supplied userId
const order = await getOrder(req.body.userId, orderId);

// CORRECT — uses authenticated session
const order = await getOrder(req.user.id, orderId);
```

### 5. Security Misconfiguration
- No default credentials in any environment
- Production error responses must not expose stack traces or internal details
- Remove unused dependencies, endpoints, and features
- HTTP security headers required: `Content-Security-Policy`, `X-Content-Type-Options`, `X-Frame-Options`, `Strict-Transport-Security`

### 6. Cross-Site Scripting (XSS)
- Always escape output in HTML context — use framework escaping (React, etc.)
- Never use `dangerouslySetInnerHTML` / `innerHTML` with user content
- Implement a strict Content Security Policy
- Use `HttpOnly` and `Secure` flags on cookies

### 7. Broken Access Control
- Default DENY — explicitly grant permissions, never assume
- Implement authorization checks at the service layer, not just UI
- Audit log all access to sensitive resources
- Test authorization for each role in integration tests

### 8. Insecure Deserialization
- Never deserialize untrusted data with language-native serialization
- Validate the structure and types of deserialized data
- Use schema validation (Zod, Pydantic, Joi) on all external input

### 9. Using Components with Known Vulnerabilities
- Audit dependencies regularly: `npm audit` / `pip audit` / `govulncheck`
- Automated dependency updates via Dependabot or Renovate
- Pin dependency versions in lock files

### 10. Insufficient Logging & Monitoring
- Log all authentication events (success and failure)
- Log all authorization failures
- Log all input validation failures
- Do NOT log sensitive data (passwords, tokens, PII)
- Structured logs with trace/request IDs for correlation

## Secrets Management

- **Never** hardcode secrets, API keys, or credentials in code
- **Never** commit `.env` files with real secrets
- Use environment variables loaded from a secrets manager (AWS Secrets Manager, HashiCorp Vault, Doppler)
- `.env.example` in git shows required variables with placeholder values
- Rotate secrets immediately if accidentally committed — assume compromised

## Input Validation

- Validate ALL input at system boundaries: HTTP requests, message queue events, file uploads
- Validate schema (structure), types, and business rules separately
- Fail fast: reject invalid input with a clear error before processing
- Whitelist valid values where possible; blacklist is insufficient

## Dependency Rules

- No dependencies with known high/critical CVEs in production
- Evaluate dependency licenses — GPL is usually incompatible with proprietary software
- Minimize dependency tree: prefer built-ins over third-party for simple operations

## Code Review Checklist (Security)

When reviewing code, specifically check:
- [ ] No SQL/command injection vectors
- [ ] Input validated at entry point
- [ ] Authorization checked before data access
- [ ] No secrets in code or logs
- [ ] Error messages don't leak internals
- [ ] Tests cover the security-critical path
