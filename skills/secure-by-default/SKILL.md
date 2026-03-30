---
name: secure-by-default
description: Use automatically on any task involving web APIs, authentication, forms, database queries, file uploads, user input, environment config, or external data. Runs a security checklist before any feature is marked complete.
---

# Secure by Default

## Overview

Security issues found after deployment cost 10–100x more to fix than ones caught during implementation. This skill embeds a security checklist into the definition of "done" for every relevant feature.

**This skill is ALWAYS-ON** for any task touching user input, data storage, authentication, or external systems.

---

## The Checklist

Run this before marking any feature complete. A feature is not done until every applicable item passes.

### Input Validation
- [ ] All user input validated at the system boundary — not inside business logic
- [ ] Validation rejects unexpected types, lengths, and formats (don't just sanitize — reject)
- [ ] File uploads: type checked by content (magic bytes), not extension; size limited
- [ ] Numbers: min/max bounds enforced; integer vs float explicit

### Injection Prevention
- [ ] All database queries use parameterized statements or ORM — zero string concatenation
- [ ] Shell commands: no user input passed to `exec`/`spawn`/`system` — use argument arrays, never shell strings
- [ ] HTML rendering: user content always escaped as text nodes — never set raw HTML from user input without a sanitizer (e.g. DOMPurify)
- [ ] XML/HTML parsers: entity expansion disabled; XXE prevented

### Authentication & Authorization
- [ ] Every route/endpoint has an explicit auth check — no "protected by default" assumptions
- [ ] Tokens: short-lived, signed, validated on every request — not just at login
- [ ] Passwords: hashed with bcrypt/argon2/scrypt — never MD5/SHA1/plaintext
- [ ] Session IDs: regenerated on privilege change (login, role switch)
- [ ] Sensitive actions (delete, payment, password change) require re-authentication

### Secrets & Config
- [ ] No secrets, API keys, or credentials anywhere in source code
- [ ] All secrets loaded from environment variables or a secrets manager
- [ ] `.env` files are in `.gitignore` and never committed
- [ ] Error messages shown to users contain no stack traces, internal paths, or config values

### Cross-Site Scripting (XSS)
- [ ] All user-supplied content rendered as text by default
- [ ] Content Security Policy header set
- [ ] Auth cookies have `httpOnly` and `secure` flags

### Cross-Site Request Forgery (CSRF)
- [ ] State-changing endpoints (POST/PUT/PATCH/DELETE) require a CSRF token or `SameSite=Strict` cookies
- [ ] CORS: `Access-Control-Allow-Origin` is not `*` for any credentialed requests

### Data Exposure
- [ ] API responses return only fields the caller is authorized to see — no full model serialization
- [ ] Paginated endpoints have a maximum page size enforced server-side
- [ ] PII and sensitive fields are not written to logs

### Dependencies
- [ ] No known CVEs in direct dependencies (`npm audit` / `pip-audit` / `cargo audit`)
- [ ] Lockfile committed with pinned versions

---

## Implementation Patterns

### Input validation (TypeScript / Zod)
```typescript
import { z } from "zod";

const CreateUserSchema = z.object({
  email: z.string().email().max(254),
  password: z.string().min(12).max(128),
  role: z.enum(["user", "admin"]),
});

// At the boundary — before any business logic
const parsed = CreateUserSchema.safeParse(req.body);
if (!parsed.success) {
  return res.status(400).json({ error: parsed.error.flatten() });
}
```

### Parameterized query
```typescript
// BAD — string concatenation
db.query(`SELECT * FROM users WHERE email = '${email}'`);

// GOOD — parameterized
db.query("SELECT * FROM users WHERE email = $1", [email]);
```

### Explicit auth on every route
```typescript
// Applied explicitly per route — never assumed globally
router.get("/admin/users",   requireRole("admin"), listUsers);
router.post("/account/delete", requireAuth, reAuthCheck, deleteAccount);
```

---

## Quick Reference

| Threat | Prevention |
|--------|-----------|
| SQL injection | Parameterized queries only |
| XSS | Escape as text; sanitize if HTML is required; CSP header |
| CSRF | CSRF token or SameSite cookies |
| Broken auth | Explicit check on every route |
| Secrets leak | Env vars only; `.env` in `.gitignore` |
| Over-exposure | Allowlist response fields explicitly |
| Supply chain | `npm audit`; committed lockfile |

---

## Common Mistakes

**Validating in the wrong layer** — business logic checks are not a substitute for boundary validation. The boundary check is the security control.

**Trusting the client** — client-side validation is UX, not security. Every constraint must be re-enforced server-side.

**`SELECT *` in API responses** — always project only the fields you intend to expose.

**Assuming the framework handles it** — frameworks reduce surface area but don't eliminate it. Know exactly what your framework does and does not protect against.
