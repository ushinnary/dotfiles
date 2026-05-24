---
name: capture-knowledge
description: "Capture and update domain knowledge from conversations into docs/. Use when you learn something new about the codebase, detect a recurring pattern, or identify a coding style rule."
---

# Capture Knowledge

Systematically evolve the project's knowledge base so future sessions don't start from zero.

## Project root detection

Determine the project root by walking up from the working directory or the file being discussed until you find a `.git` directory. That's the root. Lazily create `docs/` and `refactorings/` inside it if they don't exist.

## Before any task

List `docs/` in the project root. If any filename (kebab-case) matches substrings in the task description, read those files first. This lets you reuse past learnings instead of re-exploring the whole codebase.

## Capturing knowledge (explicit)

The user says "capture this" or "save this as knowledge" or similar. Do:

1. **Check for existing coverage.** Grep `docs/` filenames for the topic. If a file already covers it, update that file instead of creating a new one.
2. **Create or update** a file at `docs/<kebab-case-topic>.md` using this lightweight structure:

```markdown
# Title

**Use this when:** one-line description of when an agent should read this file

What you learned — the rule, pattern, concept, or decision. Keep it concise.

## Example

Code snippet or scenario illustrating the pattern.
```

3. **No YAML frontmatter.** Keep it lightweight.

## Passive detection

While reading code during any task, watch for:
- **Recurring patterns** that could be codified as rules
- **Coding style conventions** (naming, formatting, file organization)
- **Unexpected gotchas** or non-obvious behavior

When you notice something worth capturing, offer: *"Want me to save this as a knowledge entry?"* If yes, follow the capture flow above.

## Deduplication

Before creating a new knowledge file, check if an existing file already covers the same topic by comparing filenames and brief content scan. Update the existing file if the new information supplements it.
