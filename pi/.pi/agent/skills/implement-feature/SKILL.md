---
name: implement-feature
description: Structured workflow for implementing a new feature or capability in any codebase, in any language. Use whenever the user asks to add, build, create, implement, or extend functionality — a new endpoint, command, UI element, option, integration, or behavior — even if they don't use the word "feature". Not for fixing broken behavior (use fix-bug) or pure refactoring.
---

# Implement Feature

Ship a feature as a complete vertical slice: understood, designed, implemented, tested, verified.
Skipping the early steps is the main cause of rework — the cheapest place to catch a wrong
assumption is before the first line of code.

## Hard gates (do not skip, in any project, under any time pressure)

- G1: No code before a written plan listing the files to change and the tests that will prove it.
- G2: Touch only planned files. Need another? Update the plan first and say so.
- G3: Every new external input (parameter, field, file, env var) is validated at the boundary
  and gets at least one invalid-input test.
- G4: Not done until build + lint + full test suite ran in this session, with output quoted.
  If something can't run, write `NOT VERIFIED: <what> — <why>`.

## Workflow

### 1. Clarify the goal

Restate the feature in one or two sentences: who uses it, what it does, what "done" looks like.
If acceptance criteria exist (issue, spec, ticket), extract them. If the request is ambiguous in
a way that changes the design (not just the details), ask now — one question before coding beats
a rewrite after.

### 2. Explore before designing

- Find where similar features live in this codebase and how they're wired: routing, dependency
  injection, configuration, error handling, persistence, tests.
- Identify every layer the feature must touch (API surface, domain logic, storage, UI, config,
  docs) — features fail most often at the layer everyone forgot.
- Note the conventions you must match. The feature should look like the codebase wrote it.

### 3. Plan the slice

Write a short plan before editing: the files you'll touch, the new/changed interfaces, the data
flow, and the test cases that will prove it works. For anything non-trivial, share the plan as
part of your response. Prefer the design that adds the least new surface area.

### 4. Implement

- Build in dependency order (data/domain first, surface last) so each step compiles and is testable.
- Follow every rule in the global AGENTS.md: smallest correct change, match conventions, handle
  unhappy paths, no secrets, validate input at boundaries.
- Wire the feature fully: a feature that exists but is unreachable (not routed, not registered,
  not exported) is not implemented.

### 5. Test

Add tests at the level the codebase already uses (unit / integration / e2e):
- one test per acceptance criterion,
- the key unhappy paths (invalid input, missing dependency, permission denied),
- edge values for any boundary in the logic.

### 6. Security checkpoint

Before verifying, re-read your diff with `checklists/security.md` if available; at minimum
answer these against the actual diff:
- Any new input reaching a query/command/path/markup by string concatenation? (Must be none.)
- Any new operation missing a server-side authentication/authorization check?
- Any secret, token, or realistic-looking credential in code, config samples, or tests?
- Any new dependency? (Must be named and justified in the report.)

### 7. Verify and report

Run the project's full check pipeline (build, lint, tests) and quote the results. Then
summarize: what was built, which files changed, how it's verified, what was deliberately left
out of scope, and any follow-ups worth doing (don't do them unasked).

## Definition of done

- [ ] All acceptance criteria implemented and reachable end-to-end
- [ ] Tests added; seen failing without the change (red before green)
- [ ] Invalid-input and failure-path tests included for every new boundary
- [ ] Build, linter, and full test suite pass with project commands — output quoted
- [ ] Security checkpoint answered against the diff
- [ ] No unrelated changes mixed in
- [ ] Docs/config samples updated if the feature changes user-facing behavior
- [ ] Assumptions stated as `ASSUMPTION:` lines in the report
