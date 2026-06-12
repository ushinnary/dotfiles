---
name: generate-tests
description: Backfill meaningful automated tests for existing untested or under-tested code, in any language. Use whenever the user asks to add tests, improve coverage, "write tests for X", or before a risky refactor of code that has no safety net. Produces behavior-focused tests, not assertion-free snapshots or mock-everything theater.
---

# Generate Tests

Backfilling tests is different from TDD: the code already exists and is presumed *mostly*
correct, but the tests must still be able to fail — a test suite that passes against broken code
is worse than no tests, because it manufactures false confidence.

## Hard gates (do not skip)

- G1: Prove-can-fail (step 5) is mandatory for the most important tests, with the failing output
  quoted. A backfilled suite with zero observed reds is not done.
- G2: Never change production code to make a test pass. A mismatch between code and expectation
  is a *finding* to report, not an obstacle to remove.
- G3: Restore the code exactly after any deliberate breakage; run the suite to confirm
  everything is green again before reporting.
- G4: Security-sensitive behavior (validation, authorization, escaping, limits) is tested
  *first*, before convenience coverage — those tests defend the most.

## Workflow

### 1. Understand the subject

- Read the code under test and its callers. The callers tell you the *actual* contract — what
  inputs occur in practice, what outputs are relied upon.
- Identify the seams: what are the inputs, outputs, side effects, and external dependencies
  (clock, filesystem, network, database, randomness)?
- Find the existing test conventions (framework, file layout, naming, fixture style, how the
  project fakes its dependencies) and match them exactly.

### 2. Choose what to test — by risk, not by line

Prioritize, in order:
1. Code with complex branching or arithmetic (most likely to hide bugs)
2. Code that handles money, permissions, deletion, or external input (most expensive when wrong)
3. Public contracts other modules rely on
4. Code about to be refactored

Skip trivial pass-throughs and framework-generated code; coverage of those is noise.

### 3. Derive the cases

For each behavior, enumerate before writing:
- the representative happy path(s),
- each boundary (empty, one, many, max, zero, negative, expired, unicode, duplicate),
- each failure mode (invalid input, dependency throws/times out, permission denied),
- any invariant that must always hold (round-trip, ordering, idempotency).

### 4. Write the tests

- Test through the public interface; treat private internals as opaque so refactors don't break
  the suite.
- One behavior per test, named as a readable sentence about behavior.
- Arrange-Act-Assert with real assertions on *outcomes*. Asserting "the mock was called" is only
  acceptable when the call *is* the contract (e.g. "sends exactly one email").
- Fake only true externals (network, clock, fs, db). Mocking everything tests the mocks.
- Keep tests deterministic and independent of execution order.

### 5. Prove the tests can fail

This is the step that makes backfilled tests trustworthy: for at least the most important tests,
temporarily break the code (invert a condition, return early), confirm the test fails, then
restore it. A backfilled test you've never seen red is unverified. Mention in the report that you
did this.

### 6. Run and report

Run the new tests and the whole suite, quoting results. ALWAYS use this report structure:

```markdown
## Now covered
<behaviors, not line percentages>
## Proven able to fail
<which tests were seen red against deliberately broken code, with the breakage reverted>
## Deliberately not covered
<what and why>
## Findings
<real bugs or suspicious behavior discovered while testing — reported, NOT fixed;
deciding bug-vs-contract belongs to the user>
```
