---
name: security-audit
description: Systematic security review of a codebase, module, or pending change — injection, auth flaws, secrets exposure, unsafe deserialization, SSRF, supply chain — with proven findings, severity ratings, and a remediation plan. Invoke manually (/security-audit), optionally scoped ("/security-audit src/api" or "/security-audit diff").
disable-model-invocation: true
---

# Security Audit

An audit's value depends on two disciplines: **coverage you can state** (what was and wasn't
examined) and **findings you can prove** (a vulnerability you can't demonstrate or trace
concretely is a guess). False alarms erode trust; missed coverage creates false confidence.
This is a *defensive* review of code the user owns or is authorized to assess.

## Hard gates

- G1: Do not report a finding without evidence (trace, snippet, or test) — see Phase 3.
- G2: Do not fix anything during the audit. Audit first, remediate only on request.
- G3: Never paste discovered secrets or working exploit payloads into the report.
- G4: The report must include the "Not examined" section, even if empty.

## Phase 1 — Scope and map

- Fix the scope: whole repo, a module, or the pending diff. Say what you chose.
- Map the attack surface first: every entry point where external data arrives (HTTP handlers,
  CLI args, file/queue consumers, env vars, webhooks), every trust boundary, every place
  privileges are checked, every outbound call, every secret in use.
- Note the stack's known sharp edges (e.g., native deserialization, template injection, XXE in
  the XML parser the project uses).

## Phase 2 — Sweep by category

Work through each category against the mapped surface. For each, record suspicions with
file:line. Use `checklists/security.md` as the per-item reference.

1. **Injection** — SQL/NoSQL, OS command, template, header, log injection; any string-built
   query/command/path that can carry external input.
2. **Authentication** — missing/weak verification, credential storage, session and token
   lifecycle, password reset flows.
3. **Authorization** — endpoints/operations missing checks, object-level access (IDOR),
   privilege escalation paths, client-side-only enforcement.
4. **Secrets** — hard-coded keys/tokens/passwords anywhere (code, config, tests, fixtures, git
   history if feasible), secrets in logs or error output.
5. **Input & files** — validation gaps, path traversal, upload handling, deserialization,
   XXE, ReDoS.
6. **Output & data exposure** — XSS/encoding gaps, verbose errors leaking internals, PII in
   logs/URLs, missing TLS or disabled certificate validation.
7. **Server-side requests** — SSRF via user-influenced URLs, open redirects, missing timeouts.
8. **Supply chain** — vulnerable/abandoned/typosquatted dependencies, unpinned versions,
   risky install scripts. Run the ecosystem's audit tool if present.
9. **Concurrency & logic** — check-then-act races on security decisions, replay/double-submit,
   fail-open error handling in security paths.

## Phase 3 — Prove or drop

For each suspicion, attempt confirmation *without* causing harm:
- **Best**: a failing test or local demonstration with harmless input showing the flaw class
  (e.g., a quote-containing string reaching the query text).
- Else: a concrete data-flow trace — "user input enters at A (file:line), flows through B
  unvalidated, reaches sink C" — with each hop quoted.
- Try to refute it first: is the input actually validated upstream? Is the path reachable?
  Is the privilege already enforced at a boundary you missed?

Drop what you can refute. What survives gets a severity:

| Severity | Meaning |
|---|---|
| Critical | Remotely exploitable, no auth needed, or secrets exposed |
| High | Exploitable by an authenticated user, or auth bypass |
| Medium | Requires unusual conditions, or significant info disclosure |
| Low | Hardening gap, defense-in-depth, best-practice deviation |

## Phase 4 — Report

ALWAYS use this exact template:

```markdown
# Security audit: <scope> — <date>
## Summary
<counts by severity; one-paragraph overall posture>
## Findings
### [SEV-N] <title> — <file:line>
- Category:
- Evidence: <trace or test, no live secrets/payloads>
- Impact:
- Remediation: <specific fix, 1-3 lines>
## Suspicions dropped
<one line each: what looked wrong, why it isn't>
## Not examined
<paths/categories outside this audit, so silence isn't read as safety>
## Recommended order of remediation
<numbered, by severity then effort>
```

## Phase 5 — Remediate (only on request)

Fix findings one at a time, highest severity first, each as its own change with a regression
test where the flaw class is testable (e.g., traversal attempt rejected, parameterization in
place). Run the full suite after each fix. Complete `checklists/definition-of-done.md`.
