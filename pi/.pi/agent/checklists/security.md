# Security Checklist

Run this checklist whenever a change touches: external input, authentication/authorization, data
storage, file or network access, cryptography, sessions, dependencies, configuration, or logging.
Each item is a yes/no question — answer it against the actual diff, not against intentions.
Anything you cannot answer, mark `NOT VERIFIED` and say so in the report.

## Secrets & configuration
- [ ] No secrets (keys, tokens, passwords, connection strings) in code, comments, tests, fixtures, docs, examples, or logs
- [ ] Secrets come from environment/secret manager; example configs use obvious placeholders (`CHANGE_ME`), never realistic-looking values
- [ ] Nothing sensitive added to version control (check fixtures and sample data too)
- [ ] Debug/verbose modes are off by default and cannot be enabled by untrusted input

## Input handling (every boundary: HTTP, CLI, file, queue, env, DB reads of user data)
- [ ] Every external input validated for type, length, range, and format — allowlist over blocklist
- [ ] SQL/NoSQL queries are parameterized; zero string-built queries
- [ ] Shell/process invocations use argument arrays, never interpolated command strings
- [ ] Output is encoded for its context (HTML-escape, URL-encode, header-sanitize) — no raw interpolation into markup
- [ ] File paths from input are canonicalized and checked against an allowed base directory (no `../` traversal)
- [ ] Uploaded/parsed files: size limits, type verification by content not extension, parsed with hardened settings (XML: no external entities)
- [ ] Deserialization of untrusted data uses safe formats (JSON + schema), never native object deserializers
- [ ] Regexes applied to untrusted input checked for catastrophic backtracking; input length capped first

## Authentication & authorization
- [ ] Every non-public operation checks authentication AND authorization on the server side
- [ ] Authorization checks the *object* too (can this user act on this record — not just "is logged in")
- [ ] No security decisions made client-side only, or based on spoofable values (headers, hidden fields, client IP alone)
- [ ] Password handling uses slow salted hashing (bcrypt/scrypt/argon2 family); no custom schemes
- [ ] Session/token lifecycle sane: expiry, rotation on privilege change, server-side revocation possible
- [ ] Failures fail **closed**: an erroring security check denies access

## Data & privacy
- [ ] PII and credentials never written to logs, error messages, URLs, or analytics
- [ ] Outward-facing errors are generic; details (stack traces, queries, paths) stay in internal logs
- [ ] Data in transit uses TLS; certificate validation is never disabled (no `verify=false`, no trust-all)
- [ ] Anything cached or stored now has a deliberate answer for "who can read this and when is it deleted?"

## Network & server-side requests
- [ ] URLs derived from user input are validated against an allowlist before fetching (SSRF)
- [ ] Redirect targets validated (no open redirects)
- [ ] Timeouts and size limits on every outbound call

## Dependencies & supply chain
- [ ] New dependency justified, maintained, widely used, name spelled exactly (typosquatting check)
- [ ] Versions pinned via lockfile; lockfile committed
- [ ] No install scripts/postinstall hooks from untrusted packages without review
- [ ] Known-vulnerability audit run if the project has one (`npm audit`, `pip-audit`, `cargo audit`, `dotnet list package --vulnerable`, …)

## Concurrency & integrity
- [ ] No check-then-act races on security decisions (e.g., balance check then debit) — use atomic operations or locks
- [ ] State-changing operations protected against replay/double-submit where it matters (idempotency keys, CSRF protection for browser-facing apps)

## If you find an existing vulnerability while working
- Report it immediately and prominently, with location and impact.
- Do not include working exploit payloads or the secret's value in the report.
- Do not fix it silently inside an unrelated change — it deserves its own visible change.
