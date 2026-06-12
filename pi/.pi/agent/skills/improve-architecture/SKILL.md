---
name: improve-architecture
description: Audit a codebase's structure — coupling, layering, dependencies, duplication, testability — and produce a prioritized, incremental improvement plan, optionally executing the safest steps. Invoke manually (/improve-architecture), optionally scoped to a module or directory.
disable-model-invocation: true
---

# Improve Architecture

Architecture work fails in two opposite ways: grand rewrites that never land, and drive-by
"cleanups" that churn code without removing any actual constraint. This skill avoids both by
diagnosing first, tying every recommendation to a concrete pain, and improving in steps that each
leave the system working.

## Hard gates (do not skip)

- G1: No refactoring of untested behavior — characterization tests come first, always.
- G2: One plan step at a time: refactor → full suite green (quote it) → report → next. Never
  start step N+1 with step N unverified.
- G3: Refactoring steps change zero behavior. A bug found mid-refactor stops the step and gets
  reported, not silently fixed.
- G4: Every recommendation cites a consequence someone actually pays; aesthetics alone never
  justify churn.

## Phase 1 — Map the current state

Before judging anything, build an evidence-based picture:

- **Structure**: modules/packages and their dependency direction. Find cycles — they're the
  strongest signal of structural decay.
- **Hotspots**: cross-reference change frequency (`git log` on paths) with size/complexity. Code
  that is both large and frequently edited is where architecture pain is actually paid.
- **Boundaries**: where do domain logic and infrastructure (IO, frameworks, UI) mix? Can the core
  logic be tested without a database/network/UI?
- **Duplication**: same concept implemented in several places (search for sibling patterns, not
  just identical lines).
- **Test posture**: what can be tested in isolation today, what can't, and why.
- **Trust boundaries**: where external input enters and where privileges are checked. Scattered,
  repeated, or layer-crossing security checks are an architecture smell with teeth — centralizing
  them is often the highest-value structural change available.
- **Knobs and config**: hard-coded values, global state, singletons, hidden temporal coupling.

Use whatever the project offers (dependency graphs, lint rules, complexity tools) but don't block
on tooling — reading the imports and the git history gets you most of the way in any language.

## Phase 2 — Diagnose, tied to pain

For each finding, state it as: **observation → consequence → evidence.**
("`orders` and `billing` depend on each other → neither can be tested or changed alone →
3 of the last 10 bug fixes touched both.")

Findings without a consequence anyone feels are *not* recommendations — list them at most as
observations. Resist aesthetic refactoring: different is not better.

## Phase 3 — Prioritized plan

Produce a plan where every step:
1. is independently shippable (the system builds, tests pass, behavior unchanged),
2. is ordered by **value ÷ risk** — usually: characterization tests first, then breaking the
   worst cycle, then extracting the most-paid-for boundary,
3. names its verification (which tests prove behavior didn't change).

Where behavior is currently untested, the first step is always *adding characterization tests*
that pin existing behavior — refactoring without a net converts structural debt into outages.

Format the plan as a markdown document (save it where the project keeps docs/ADRs):

```markdown
# Architecture review: <scope> — <date>
## Summary (5 lines max)
## Findings (observation → consequence → evidence, ordered by severity)
## Improvement plan (ordered steps; each with: change, value, risk, verification)
## Explicitly not recommended (tempting changes that don't pay)
```

## Phase 4 — Execute (only what was agreed)

If the user asks to proceed, execute steps in order, one at a time: refactor → run full suite →
report → next. Never mix behavior changes into a refactoring step; if a real bug surfaces
mid-refactor, stop and report it (fixing it changes behavior — that's a separate, flagged change).

The "explicitly not recommended" section is not filler: telling the user which fashionable
restructuring *isn't* worth it here is half this skill's value.
