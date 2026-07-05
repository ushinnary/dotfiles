---
name: performance-review
description: Disciplined measure-first workflow for making code faster. Use whenever the user reports something slow, asks to optimize, speed up, reduce latency/memory, fix a bottleneck, or improve throughput — anything where "make it fast" is the goal. Establish a baseline and profile before changing anything; prove the win with before/after numbers.
---

# Performance Review

The goal is not to make the code *look* optimized — it is to make a measured metric
hit a target. An optimization without a baseline is a guess; an optimization without
a re-measurement is a story. Numbers gate every step.

Read [`PERFORMANCE_GUIDELINES.md`](../../PERFORMANCE_GUIDELINES.md) before starting —
it holds the principles this workflow enforces.

## Hard gates (do not skip)

- G1: No optimization change before a baseline measurement taken **this session** and
  a stated target/budget (a metric and a number). If you cannot measure, write
  `NOT VERIFIED: <what> — <why>` and stop — do not optimize blind.
- G2: No change to a code path before a profile (or a clearly-reasoned, stated
  hypothesis backed by complexity analysis) shows it is the dominant cost.
- G3: No "done" without a re-measurement against the baseline, before/after numbers
  quoted. If the number didn't move, revert — complexity without a measured gain is
  a regression.
- G4: Behavior must not change. All existing tests stay green; quote the result.
  Performance work is a refactor (`AGENTS.md` non-negotiable 7) — keep it separate
  from behavior changes.

## Workflow

### 1. Define the metric and target

State precisely what "fast enough" means before measuring:
- The metric: p50/p95/**p99** latency, throughput (rps), memory ceiling, allocation
  rate, query count — whichever the user actually feels.
- The target/budget: a number. "Faster" is not a target; "p99 under 200ms" is.
- The scope: which operation, under what load, with what data size and shape.

### 2. Measure the baseline

- Build a reproducible benchmark or load test with **representative** data size and
  shape (10 rows tells you nothing about 10 million) and realistic warm/cold state.
- Record the baseline numbers. This is what every later claim is measured against.
- Keep the benchmark — it becomes the regression guard in step 6.

### 3. Profile to find the dominant cost

- Profile (CPU / allocations / I/O wait / lock contention) — do not guess the
  hotspot; intuition is wrong more often than right.
- Identify the **one** biggest cost. Remember Amdahl: speeding up 5% of runtime caps
  your gain at 5%. For backends, suspect I/O first (N+1, serial remote calls,
  missing index, no pooling).
- State the root cause of the slowness in plain language before touching code.

### 4. Change the dominant cost

- Apply the highest-leverage fix, in order of leverage: algorithm/data structure →
  do-less (cache/batch/lazy/avoid recompute) → I/O (batch, parallelize, stream,
  pool) → micro/memory last.
- Make one change at a time so each one's effect is measurable.
- Keep correctness intact: same inputs, same outputs, same tests.

### 5. Re-measure and prove the win

- Re-run the same benchmark; quote before/after numbers.
- If it didn't beat the baseline meaningfully, **revert it** and try the next cost —
  do not keep complexity that bought nothing.
- Stop when the budget is met. Don't gold-plate past the target.

### 6. Lock it in and report

- Add a guardrail where the project supports it: a CI benchmark, a perf assertion, or
  a query-count test that fails if an N+1 returns.
- Run the full test suite — the optimization must not have changed behavior — and
  quote the result.

ALWAYS use this exact report structure:

```markdown
## Metric & target
<the metric, the budget number, the operation/load/data scope>
## Baseline
<the measured starting numbers; how they were measured>
## Bottleneck
<the dominant cost the profile revealed, in plain language>
## Change
<what changed and why it addresses that cost; the trade-off accepted>
## Result
<after numbers vs baseline; budget met? full test-suite result>
## Guardrail
<benchmark/perf-test added to prevent regression, or why none>
```

Finish with `checklists/definition-of-done.md` if available in the workspace.

## Anti-patterns to refuse

- Optimizing without a baseline or a target ("this should be faster").
- Micro-optimizing a cold path while the profiled hotspot stays untouched.
- Keeping a change that didn't move the number "because it's probably better".
- Trading correctness or readability for an unmeasured, unbudgeted speedup.
- Claiming a speedup from memory or expectation instead of a re-measurement.
