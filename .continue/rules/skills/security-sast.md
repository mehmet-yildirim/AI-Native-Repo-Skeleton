# Security SAST — Vulnerability Detection Patterns

## Universal Rules
- Validate ALL input at every system boundary (HTTP, MQ, file upload, external API, CLI)
- Parameterized queries always — no string interpolation into SQL, LDAP, or commands
- Never `shell=True` / `exec()` / `system()` with any non-constant string
- Never hardcode credentials — load from env vars or secrets manager
- Never log passwords, tokens, PII, or session data

## Injection Patterns (All Languages)
```
BAD:  db.query(`SELECT * FROM users WHERE id = '${id}'`)
GOOD: db.query('SELECT * FROM users WHERE id = $1', [id])

BAD:  exec(`ls ${userPath}`)
GOOD: execFile('ls', [userPath])          # args as array, no shell

BAD:  subprocess.run(f"ls {path}", shell=True)
GOOD: subprocess.run(["ls", path])
```

## Authentication
- Tokens: use `crypto.randomBytes(32)` / `secrets.token_hex(32)` / `SecRandomCopyBytes` — NEVER `Math.random()` / `random.randint()`
- Password storage: bcrypt / Argon2 / scrypt only — NEVER MD5 / SHA1 / SHA256 plain
- JWT: always verify signature; never `alg: none`; always check `exp` claim
- Timing-safe comparison for secrets: `timingSafeEqual` / `hmac.compare_digest`

## Access Control
- Verify ownership server-side before every data access — never trust client-supplied resource ID
- Default DENY — explicitly grant, never assume
- Check authorization at service layer, not just at UI

## Cryptography
```
WEAK (forbidden):  MD5, SHA1, DES, RC4, ECB mode, RSA < 2048-bit
STRONG (required): AES-256-GCM, SHA-256+, ChaCha20-Poly1305, RSA 2048+
```

## Path Traversal
```
BAD:  open(f"/uploads/{filename}")
GOOD: target = (base_path / filename).resolve()
      assert target.is_relative_to(base_path)
```

## Secrets
- Never commit: API keys, passwords, private keys, tokens
- Detect with `gitleaks` or `truffleHog` in CI
- Rotate any accidentally committed secret immediately

## Sensitive Data in Logs / Storage
- Mobile: use Keychain (iOS) / EncryptedSharedPreferences (Android) — NOT UserDefaults / SharedPreferences
- Never `console.log` / `print` / `NSLog` secrets — strip logs in production builds
- PII in DB: encrypt at rest if required by compliance

## OWASP Top 10 — Fast Check

| Code area | What to verify |
|-----------|----------------|
| Any DB query | Parameterized? |
| Auth endpoint | Rate-limited? Account lockout? |
| File access | Path traversal guard? |
| External URL fetch | Allowlist validated? SSRF blocked? |
| HTML output | Framework-escaped? No innerHTML with user data? |
| Cookie | Secure + HttpOnly + SameSite=Lax? |
| Dependency manifest | `npm audit` / `pip-audit` / `govulncheck` passing? |
