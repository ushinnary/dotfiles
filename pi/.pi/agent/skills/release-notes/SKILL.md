---
name: release-notes
description: Generate release notes or a changelog entry from git history between two refs, written for the people affected rather than echoing commit messages. Invoke manually (/release-notes), optionally with a range like "/release-notes v1.2.0..HEAD".
disable-model-invocation: true
---

# Release Notes

Commit messages answer "what changed in the code"; release notes answer "what changes for *you*"
— the user, operator, or integrator. The work of this skill is the translation between the two,
plus the hunt for the things commit messages reliably under-communicate: breaking changes,
migrations, and config/dependency changes.

## Hard gates (do not skip)

- G1: Every claimed breaking change and removal is verified against the actual diff, not just
  the commit message.
- G2: Security fixes are listed in their own **Security** section so upgraders can prioritize —
  describe impact and affected versions, never reproduction steps or exploit details.
- G3: No internal hostnames, customer names, or secrets copied from commit messages into the
  public notes.
- G4: Changes you cannot classify confidently become questions to the user, never guessed
  impact statements.

## Workflow

### 1. Establish the range

Use the range the user gave, otherwise from the latest tag to `HEAD` (`git describe --tags
--abbrev=0`). If there are no tags, ask for the range — guessing a release boundary produces
wrong notes. Collect `git log` with bodies, plus `--stat` for a sense of where changes landed,
and any merged PR titles/issue references in the messages.

### 2. Classify by audience impact

Bucket every change as:
- **Breaking changes** — anything requiring action from a consumer: removed/renamed APIs or
  flags, changed defaults, schema/data migrations, dropped platform support.
- **New features** — capabilities that didn't exist.
- **Improvements** — existing behavior, now better (performance, UX, clearer errors).
- **Security** — vulnerability fixes and security-relevant dependency bumps; always their own
  section (see G2).
- **Fixes** — defects resolved; lead with the symptom the user saw, not the internal cause.
- **Dependencies / internal** — only what's externally observable (security bumps, license
  changes); pure refactors usually don't belong in release notes at all.

Hunt actively for hidden breaking changes — they hide in innocuous commits: check diffs touching
config schemas, public types, CLI argument parsing, env-var reads, and default values.

### 3. Write for the reader

- One line per change, leading with the user-visible effect: *"Exports no longer time out on
  files over 10 MB"*, not *"refactored export buffering"*.
- Name the feature/area, link the PR/issue where the convention exists.
- For each breaking change, include a **migration line**: what to change, before → after.
- Match the project's existing format (`CHANGELOG.md` style, Keep-a-Changelog, GitHub Releases
  tone). If the project follows a convention like conventional-commits, use it for classification
  but never copy commit subjects verbatim — they were written for maintainers.

### 4. Verify against reality

Spot-check claims that matter: confirm a "removed flag" is really gone, a renamed option really
renamed. Release notes are a public contract; a wrong note is a support ticket.

### 5. Deliver

Write the entry where the project keeps it (`CHANGELOG.md` on top, or a draft release body) and
show it in full in your response. Flag anything you couldn't classify confidently as a question
rather than guessing its impact.
