---
name: fix-bug
description: Disciplined root-cause workflow for fixing defects. Use whenever the user reports something broken, failing, crashing, wrong, flaky, or unexpected — an error message, stack trace, failing test, wrong output, or "it used to work" — even if they don't say the word "bug". Reproduce first, fix the cause not the symptom, lock it in with a regression test.
---

# Fix Bug

The goal is not to make the symptom disappear — it is to understand *why* the defect exists, fix
that cause, and make this class of bug impossible to silently return. A fix without a reproduction
is a guess; a fix without a regression test is temporary.

## Hard gates (do not skip)

- G1: No code change before either (a) a reproduction you ran in this session, or (b) an explicit
  written statement "COULD NOT REPRODUCE: <why>" plus the evidence you're acting on instead.
- G2: No "done" without a regression test seen failing on pre-fix code and passing on fixed code
  — quote both outputs.
- G3: One bug = one change. No refactoring, no unrelated cleanups in the fix diff.
- G4: If the bug is security-relevant (injection, auth bypass, secret exposure, data leak),
  say so prominently, check for the same flaw elsewhere, and never include working exploit
  payloads or leaked secret values in the report.

## Workflow

### 1. Reproduce

Make the bug happen on demand before changing anything:
- Get the exact failing input, environment, and observed-vs-expected behavior.
- The best reproduction is a failing automated test. Write it now if feasible — it becomes the
  regression test later, for free.
- If you cannot reproduce it, say so and gather more evidence (logs, versions, data); do not
  "fix" what you cannot observe.

### 2. Localize the root cause

- Follow the evidence: stack traces, logs, `git log`/`git blame` on the suspect area (a recent
  change is the most common culprit), bisection if needed.
- Form a hypothesis, then *confirm it* by prediction: "if this is the cause, then X should
  happen when I do Y." Only fix once a hypothesis survives testing.
- Distinguish the *defect* (wrong code) from the *symptom* (where it blew up). They are usually
  in different places. Fixing where it blew up — adding a null check at the crash site, catching
  the exception — usually buries the real bug deeper.

### 3. Fix

- Apply the smallest change that corrects the root cause.
- Check for the same mistake elsewhere: bugs come in families (same copy-pasted pattern, same
  misused API, same off-by-one). Search the codebase for siblings and fix or report them.
- Do not mix refactoring into the fix. Keep the diff reviewable as "the fix".

### 4. Lock it in

- Ensure the regression test from step 1 exists, is named after the behavior (not the ticket),
  fails on the pre-fix code, and passes now. If you couldn't write one in step 1, write it now.
- Cover the neighboring edge cases the bug revealed (the bug existed because a case was untested
  — there are usually more).

### 5. Verify and report

Run the full test suite — the fix must not break anything else — and quote the result.

ALWAYS use this exact report structure:

```markdown
## Root cause
<one paragraph, plain language: the defect, not the symptom>
## Fix
<files changed and why this corrects the cause>
## Evidence
<regression test name; its failing output pre-fix; passing output post-fix; full-suite result>
## Siblings
<same bug-family found elsewhere: fixed / reported, or "none found, searched for <pattern>">
```

Finish with `checklists/definition-of-done.md` if available in the workspace.

## Anti-patterns to refuse

- Catching and swallowing the exception to stop the crash.
- Adding a special-case `if` for the reported input without understanding why it misbehaves.
- Re-running flaky tests until green instead of fixing the flake.
- Declaring victory because "it works now" without a test proving it stays working.
