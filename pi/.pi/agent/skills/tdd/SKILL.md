---
name: tdd
description: Red-green-refactor test-driven development loop for any language or framework. Use whenever the user asks to work test-first, mentions TDD, says "write the tests first", or when building well-specified logic (parsers, calculators, validators, converters, business rules) where behavior can be pinned down by examples before implementation.
---

# Test-Driven Development

Drive the implementation from tests, one small behavior at a time. The discipline has one
non-negotiable rule: **never write production code without a failing test demanding it.** The
failing test is what proves the test can fail — a test you've never seen red proves nothing.

## Hard gates (do not skip)

- G1: No production code without a currently-failing test demanding it.
- G2: Every RED step's failure output is actually observed by running the test — quote at least
  the assertion line. "It would fail" is not evidence.
- G3: Run the *whole* suite at every GREEN and after every refactoring step, not just the new test.
- G4: Never refactor while any test is red.

## The loop

Repeat until the feature is complete. Keep each cycle small — minutes, not hours.

### RED — write one failing test
- Pick the *next simplest* behavior not yet implemented. Start with the degenerate case (empty
  input, zero, single element) and grow toward the general case.
- Write one test expressing that behavior through the public interface. Name it after the
  behavior: `returns_empty_list_when_no_matches`, not `test_2`.
- **Run it and watch it fail** — and fail for the right reason (the assertion, not a typo or
  import error). Announce the failure before proceeding.

### GREEN — make it pass, minimally
- Write the simplest code that passes *all* tests so far. Hard-coding and obvious faking are
  legitimate at this stage — the growing test list is what forces the real generalization.
- Resist implementing behaviors no test demands yet. That code is untested by construction.
- Run the whole suite, not just the new test.

### REFACTOR — clean up on green
- With all tests passing, improve names, remove duplication (in tests too), extract structure
  that the last few cycles revealed.
- Run the tests after every refactoring step. Never refactor on red.

## Order of test selection

1. Degenerate / empty case
2. Single simplest example
3. The general case
4. Boundaries (limits, off-by-one, overflow points)
5. Error and invalid-input cases
6. Interactions / integration with collaborators

If a test forces too big an implementation leap, it was too ambitious — back up and write a
smaller intermediate test.

## Keep the user in the loop

Narrate the cycle compactly as you go (e.g. "RED: `rejects_expired_token` fails as expected →
GREEN → refactored token parsing"). This makes the discipline auditable rather than claimed.

## Security in the test list

When the unit under test handles external input, security cases belong in the test order like
any other behavior: injection-shaped strings treated as data, oversized input bounded, invalid
auth rejected, errors that fail closed. Writing them as tests first is the cheapest security
review there is.

## When NOT to use TDD

Be honest about fit: exploratory spikes, glue/config code, and UI layout are usually better
tested after the fact or via higher-level tests. If the user asked for TDD on such code, do it at
the highest level that's practical and say why.

## Final self-check

- [ ] Every production change was demanded by a test seen red first
- [ ] Whole suite green — output quoted
- [ ] Test names read as behavior sentences; no `test_2`
- [ ] Error/invalid-input cases included, not just happy paths
- [ ] The narrated RED/GREEN/REFACTOR log appears in the report
