# Security Guidelines

## Non-Negotiable Rules
- **NEVER** interpolate user input into SQL queries, shell commands, or HTML
- **NEVER** log passwords, tokens, credit card numbers, or PII
- **NEVER** hardcode secrets, API keys, or credentials in code
- **NEVER** trust client-supplied IDs for authorization — verify against session
- **ALWAYS** validate and sanitize all external input at system boundaries

## Input Validation
- Validate all input at HTTP boundary before processing
- Use schema validation (Zod, Pydantic, Joi) — never manual type checks
- Whitelist valid values; reject everything else with a clear error

## Authentication & Authorization
- Passwords: bcrypt, Argon2, or scrypt only — never MD5/SHA1/plain
- Rate-limit authentication endpoints
- Default DENY for authorization — explicitly grant, never assume
- Check authorization at the service layer, not just in UI

## SQL / Database
```typescript
// WRONG
db.query(`SELECT * FROM users WHERE email = '${email}'`);

// CORRECT
db.query('SELECT * FROM users WHERE email = $1', [email]);
```

## XSS Prevention
- Always use framework escaping (React, Jinja2, etc.)
- No `dangerouslySetInnerHTML` / `innerHTML` with user content
- Implement Content Security Policy

## Secrets
- Use environment variables loaded from a secrets manager
- `.env.example` in git with placeholder values only
- Rotate any accidentally committed secret immediately

## Error Responses
- Production errors must not expose stack traces or internal details
- Log full details server-side; return safe generic message to client

## Dependencies
- Run `npm audit` / `pip audit` as part of CI
- No production dependencies with known high/critical CVEs
