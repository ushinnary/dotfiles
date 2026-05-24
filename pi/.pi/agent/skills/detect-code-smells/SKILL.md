---
name: detect-code-smells
description: "Detect code duplications, security issues, or performance problems while reading code. Use when asked to review code quality, find issues, or suggest improvements."
---

# Detect Code Smells

While reading code, watch for tactical issues and capture them as actionable refactoring proposals.

## Project root detection

Determine the project root by walking up from the working directory or the file being discussed until you find a `.git` directory. Lazily create `docs/` and `refactorings/` inside it if they don't exist.

## Before touching a file

Before modifying any file, scan `refactorings/` for open `.md` files that list the file being changed. If any open issue (Status: open) references that file, fix the issue(s) in that file first during your edit.

## Detecting issues (ambient)

While reading or editing code, watch for:

| Type | Signals |
|---|---|
| **Duplication** | Similar blocks of code across files or within a file; repeated logic that could be DRY'd |
| **Security** | Hardcoded secrets, SQL injection vectors, unsanitized input, missing access control, command injection |
| **Performance** | N+1 queries, unnecessary allocations, O(n²) in hot paths, large data copies |

### What to do when you find an issue

1. **Check `refactorings/`** — if a `.md` file already exists for this issue type near this location, open it.
   - If the issue matches and is `Status: open`, append the new location to that file under a new `### Location` entry.
   - If the issue already lists every location you found, skip.
2. **If no existing file covers it**, create `refactorings/<kebab-case-issue>.md`:

```markdown
# Issue title

**Type:** duplication | security | performance

## Location
- `path/to/file.rs:42-56` — brief description of the problem

## Suggested fix

Short, actionable description of what to change and how.

## Status

open
```

## Fixing issues

When you need to edit a file that has an open issue:
1. Fix the occurrence in the file you're about to touch.
2. Remove that location entry from the refactoring `.md`.
3. If the file has no more locations listed, delete the `.md` file entirely.
4. Then create a knowledge file at `docs/<kebab-case-pattern>.md` documenting the correct pattern with minimal context — so future code avoids the same mistake.

## When to NOT create a refactoring

- Trivial style preferences that don't affect correctness or performance
- Issues you fixed immediately during the edit that spawned no new knowledge
