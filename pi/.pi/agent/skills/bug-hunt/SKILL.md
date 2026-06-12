---
name: bug-hunt
description: Proactively hunt for latent, not-yet-reported bugs in existing code — logic errors, race conditions, resource leaks, unhandled edge cases, security flaws — then prove each finding, fix it, and lock it in with a regression test. Invoke manually (/bug-hunt), optionally scoped to a directory, module, or recent changes.
disable-model-invocation: true
---

# Bug Hunt

This is the inverse of `fix-bug`: there is no report, no reproduction, no complaining user. The
job is to find defects *before* anyone hits them — and the cardinal rule is that **a finding is
not a bug until it is proven**. Plausible-looking "bugs" that turn out to be intentional behavior
waste everyone's time and erode trust in the hunt. Prove, then fix, then test.

## Hard gates (do not skip)

- G1: No fixing during the sweep (Phase 2) — log suspicions and keep hunting.
- G2: No fix without proof (Phase 3) and no proof without an attempt to refute it first.
- G3: One bug = one coherent change, each with a regression test seen red before the fix.
- G4: Security-class findings (injection, auth, secrets, data exposure) are flagged as such,
  rated for severity, and never reported with working exploit payloads or leaked secret values.
- G5: The report's "dropped" and "coverage" sections are mandatory, even when empty.

## Phase 1 — Choose hunting grounds

If the user gave a scope, use it. Otherwise prioritize where bugs cluster:
- recently changed code (`git log --since` — most bugs are young),
- complex, branchy code with weak test coverage,
- concurrency, caching, and time/date handling,
- boundary layers: parsing external input, building queries/commands, (de)serialization,
- error-handling paths (the least-executed code in any system),
- anything handling money, permissions, deletion, or PII.

## Phase 2 — Sweep with multiple lenses

Read the code adversarially, pass by pass — each lens catches what the others miss:

1. **Logic** — inverted/`off-by-one` conditions, wrong operator precedence, unintended
   fallthrough, copy-paste with an un-renamed variable, dead branches that should be live.
2. **Edge inputs** — empty, null/none, zero, negative, max-size, duplicates, unicode,
   malformed encodings. Trace each through the code mentally.
3. **Error paths** — swallowed exceptions, errors logged-then-ignored, partial state after a
   midway failure, missing rollback, retry without idempotency.
4. **Resources & concurrency** — unclosed handles/connections, check-then-act races, shared
   mutable state without synchronization, deadlock-prone lock ordering, async results ignored.
5. **Time & locale** — timezone-naive comparisons, DST boundaries, month-length arithmetic,
   locale-dependent parsing/formatting/casing.
6. **Security** — injection via string-built queries/commands/paths, missing authorization on a
   reachable path, secrets in code or logs, unsafe deserialization, SSRF-able URLs.
7. **Contract drift** — code whose behavior contradicts its name, docs, types, or callers'
   visible assumptions.

Log every suspicion with file:line. Don't fix anything yet — fixing during the sweep narrows
your attention and ends the hunt early.

## Phase 3 — Prove or drop

For each suspicion, attempt to confirm it:
- **Best**: write a failing test demonstrating the wrong behavior with concrete input.
- Else: a runnable snippet/REPL session showing the defect.
- Else (e.g. genuine races): a precise interleaving/input narrative plus corroborating evidence
  (docs of the API being misused, a matching TODO, an issue, behavior of sibling code).

Actively try to *refute* your own finding first — check callers, invariants upstream that make
the "impossible" input impossible, tests that pin the behavior as intended. What survives
refutation is a confirmed bug. What doesn't gets dropped, or at most listed as an observation.

## Phase 4 — Fix and lock in

For each confirmed bug, apply the `fix-bug` discipline: root cause (not symptom), smallest fix,
search for the same bug-family elsewhere, regression test that failed before the fix and passes
after, full suite green. Keep **one bug = one coherent change** so each fix is reviewable and
revertable on its own.

If a confirmed bug is too risky to fix blind (behavior others may depend on, unclear intended
semantics), don't fix it — report it with the failing test attached and let the user decide.

## Phase 5 — Report

```markdown
# Bug hunt: <scope> — <date>
## Confirmed & fixed  (each: severity → root cause → impact → fix → regression test)
## Confirmed, not fixed  (each: severity → proof + why the decision is the user's)
## Suspicions dropped  (one line each — what looked wrong and why it isn't)
## Coverage note  (what was NOT examined, so absence of findings isn't read as absence of bugs)
```

The "dropped" and "coverage" sections are mandatory: a hunt that only reports kills overstates
both its findings and its thoroughness.
