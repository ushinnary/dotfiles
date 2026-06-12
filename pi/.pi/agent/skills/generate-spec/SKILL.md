---
name: generate-spec
description: Turn a feature idea or vague requirement into a precise, implementable specification with acceptance criteria, edge cases, and open questions. Invoke manually (/generate-spec) before starting significant work, when requirements are fuzzy, or when a spec document is the deliverable.
disable-model-invocation: true
---

# Generate Spec

A spec exists to surface disagreements while they're still cheap. The measure of a good spec is
that two different implementers reading it would build observably the same thing — and that the
hard questions were asked *before* implementation, not discovered during it.

## Hard gates (do not skip)

- G1: Every acceptance criterion is mechanically testable — if you can't sketch the test, rewrite
  the criterion.
- G2: The "Security & privacy" section is mandatory, never "N/A" without justification — every
  feature that accepts input, stores data, or exposes an operation has security consequences.
- G3: Unknowns become numbered open questions, never silent assumptions baked into the design.

## Workflow

### 1. Gather context

- Read the relevant code, existing specs/ADRs, and any linked issue or discussion. Ground the
  spec in what exists — a spec that ignores the current system describes a fantasy.
- Identify the actual problem behind the request. If the user asked for a solution ("add a cache"),
  capture the underlying need ("p95 latency on X exceeds Y") — solutions can change, needs rarely do.

### 2. Interrogate the requirement

Work through these and either answer from context or list as open questions:
- Who are the users/consumers of this? What triggers it?
- What is explicitly **out of scope**? (An unstated scope boundary is a future argument.)
- What happens on failure — partial completion, retries, rollback, user messaging?
- Concurrency, ordering, and idempotency expectations?
- Volume/performance expectations, even rough ones?
- Permissions and data-sensitivity implications?
- Migration/compatibility: what happens to existing data, existing clients, existing config?

### 3. Write the spec

Save as a markdown file in the project's docs location (or where the user says). Use this structure:

```markdown
# Spec: <name>
Status: Draft | Reviewed | Approved   ·   Date   ·   Author

## Problem
What hurts today and for whom. Not the solution.

## Goals / Non-goals
Bullet lists. Non-goals are as binding as goals.

## Proposed behavior
The system as the user/consumer will experience it. Concrete:
inputs, outputs, states, error behavior. Include examples with real-looking data.

## Acceptance criteria
Numbered, individually testable statements ("Given X, when Y, then Z").
Each one should map to at least one future test.

## Edge cases & failure modes
The table of what happens when things are empty, huge, duplicated,
concurrent, unauthorized, or down.

## Security & privacy
Who may invoke this and how is that enforced (authn + authz, server-side)?
What external input arrives and how is it validated/bounded?
What data is stored/logged — any PII, retention, who can read it?
New dependencies, new secrets, new network destinations?
Abuse cases: how could a hostile user weaponize this feature?

## Design notes (optional)
Touched components, data model changes, new dependencies, alternatives rejected and why.

## Open questions
Numbered, each with an owner/decision-needed-by if known.
```

### 4. Quality bar before delivering

- Every acceptance criterion is testable — no "should be fast", no "user-friendly".
- Examples use concrete values, not placeholders like `<value>`.
- Open questions are real decisions for the user, not rhetorical filler.
- Short enough to be read: aim for 1–3 pages. A spec nobody reads specifies nothing.

Deliver the file path plus a 5-line summary and the open questions inline — those need answers
before implementation starts.
