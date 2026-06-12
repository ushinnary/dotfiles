---
name: generate-docs
description: Generate or refresh project documentation — README, getting-started, API reference, architecture overview, contributor guide — derived from the actual code, not assumptions. Invoke manually (/generate-docs), optionally with a target like "/generate-docs readme" or "/generate-docs api".
disable-model-invocation: true
---

# Generate Docs

Documentation has one enemy: drift. Docs that describe the code as it *was* are worse than no
docs, because readers trust them. Therefore every claim in generated docs must be derived from
the current code, and verified where possible by actually running the commands being documented.

## Hard gates (do not skip)

- G1: Every documented command was either run in this session or carries the literal marker
  `(not verified in this environment)`.
- G2: No secrets, real tokens, internal hostnames, or production URLs in examples — use obvious
  placeholders (`https://api.example.com`, `CHANGE_ME`), never realistic-looking credentials a
  reader might mistake for safe-to-commit patterns.
- G3: Signatures, defaults, flags, env vars are copied from source, never written from memory.
- G4: When refreshing existing docs, every corrected drift item is listed in the report.

## Workflow

### 1. Determine target and audience

If the user named a target (readme, api, architecture, onboarding, changelog), do that. Otherwise
inventory what exists, check it against reality, and propose: what's missing, what's stale, what
one document would help most. Each audience reads differently:

- **README** — an evaluator: what is this, why would I use it, how do I run it in 5 minutes.
- **Getting started / onboarding** — a new contributor: setup that *actually works* end to end.
- **API reference** — an integrator: every public surface, parameters, errors, one example each.
- **Architecture** — a maintainer: components, responsibilities, data flow, and *why* it's shaped
  this way (constraints, rejected alternatives).

### 2. Derive from source — the trust rules

- Document only what you verified in the code. Signatures, defaults, env vars, config keys, CLI
  flags: copy them from source, never from memory.
- **Run every command you document** (install, build, test, start) where the environment allows.
  A setup guide with an untested command sequence is a bug report waiting to happen. If you can't
  run something, mark it explicitly: *"(not verified in this environment)"*.
- Examples must be real and runnable: actual request/response shapes, actual file paths, output
  the user will really see.
- Where the project has doc-comment conventions (docstrings, JSDoc, XML docs, rustdoc), put API
  documentation *there* — next to the code, where it has the best chance of staying current — and
  generate the standalone reference from them if tooling exists.

### 3. Write

- Lead every document with what the reader most needs; details descend in order of decreasing
  urgency.
- Prose for concepts, tables for enumerable facts (flags, env vars, endpoints), code blocks for
  anything the reader will copy-paste.
- State the *why* for anything surprising. Readers can see the what.
- Match the project's existing docs style and location (`docs/`, wiki conventions, doc site
  framework). Don't introduce a new docs system uninvited.

### 4. Refresh pass (when docs already exist)

Diff every existing claim against current code: commands, versions, paths, names, screenshots'
described behavior. Fix what drifted, delete what's dead, and list the corrections in your report
— drift findings are valuable to the user beyond the docs themselves.

### 5. Deliver

Report which files were created/updated, which commands were verified by running them, and what
remains undocumented (with a recommendation, not an unprompted continuation).
