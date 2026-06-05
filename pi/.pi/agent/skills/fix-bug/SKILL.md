---
name: fix-bug
description: This skill automates the process of reproducing a bug, creating a test that captures the buggy behavior, then fixing the underlying issue, and finally ensuring the test passes. It is intended for use within the coding agent environment.
---

## Steps performed

1. **Identify the bug**: Analyze error reports, failing builds, or user complaints to pinpoint the problematic code region.
2. **Create reproduction test**: Write a unit test (or integration test) that reproduces the bug. The test should initially fail (red phase).
3. **Run the test**: Execute the test suite to confirm the failure matches the reported issue.
4. **Fix the bug**: Modify the source code to resolve the issue while preserving existing functionality.
5. **Verify the fix**: Run the test again to ensure it passes (green phase). Also run related tests to avoid regressions.
6. **Document**: Add or update documentation describing the bug, its root cause, and the fix.
7. **Commit**: Record changes with a clear commit message referencing the bug identifier.

## Integration points

- Uses `devenv` environment to run tests.
- May invoke `cargo test`, `pytest`, or other test runners depending on the project.
- Leverages `capture-knowledge` to log details into `docs/` if needed.
- Emits a `refactorings/` entry if the fix reveals architectural concerns.

## Configuration

No additional configuration is required. The skill will automatically detect the project's test framework by checking `Cargo.toml`, `pyproject.toml`, `package.json`, or `*.test` files.

## Example usage (within pi)

```
/pi/run fix-bug --description "Null pointer in user login flow"
```

The command line arguments are parsed to tag the test and bug tracking entry.

## Related skills

- `capture-knowledge` – for documenting discovered bugs and fixes.
- `detect-code-smells` – to identify related quality issues before fixing.
- `grill-me` – can be used to grilling the plan before execution.

