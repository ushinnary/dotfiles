# Definition of Done

Complete this checklist at the end of **every** task that changed code or files. Copy it into
your final report and mark each line `[x]` done, `[ ]` not done (with one-line reason), or
`[-]` not applicable (with one-line reason). Do not mark a line `[x]` on memory or expectation —
only on evidence from this session.

## Scope
- [ ] The original request is re-read; everything asked for is delivered or explicitly listed as not delivered
- [ ] No changes outside the task's scope (no drive-by refactors, renames, reformatting)
- [ ] Replaced code is deleted — no commented-out blocks, dead branches, unused imports

## Verification (quote real output, not summaries)
- [ ] Build/compile passes — command run this session
- [ ] Linter/formatter passes with project settings — command run this session
- [ ] Full test suite passes — command run this session; failures quoted verbatim if any
- [ ] Anything that could not be run is marked `NOT VERIFIED: <what> — <why>`

## Tests
- [ ] Every behavior change has a test that fails without it
- [ ] New tests were seen failing before the change or against broken code (red before green)
- [ ] Unhappy paths covered: empty, null, boundary, invalid, failing dependency

## Security (full list: checklists/security.md)
- [ ] No secret written, logged, printed, or committed
- [ ] No SQL/shell/HTML/path built by concatenating external input
- [ ] New external input validated at the boundary (type, length, range, format)
- [ ] New/changed endpoints or operations enforce authentication and authorization server-side
- [ ] No new dependency — or it is named, justified, pinned, and reported

## Hygiene
- [ ] Code matches the project's existing conventions (style, naming, idiom, structure)
- [ ] No generated artifacts, local config, or vendor files staged for commit
- [ ] Docs/config samples updated if user-visible behavior changed

## Report
- [ ] Report leads with the outcome (what changed, where, verified how)
- [ ] All assumptions are stated as `ASSUMPTION:` lines
- [ ] Out-of-scope problems discovered are reported, not silently fixed or ignored
