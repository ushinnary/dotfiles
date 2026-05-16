# Agent Instructions

## Environment

This agent runs inside **NixOS**. The main repository is located at `/home/ushinnary/dotfiles`.

## File Operations

### Reading Files

- **Avoid reading entire files** when only specific information is needed
- Use targeted commands like `grep`, `rg` (ripgrep), `ast-grep`, or `head`/`tail` to find specific content
- Only use `read` or `cat` when you genuinely need the full file contents

### Editing Files

- Before any code add, check if simillar tool exist already with some regex that could match it mostly and if you find it and it fits your needs so use it instead, if it has limited function so try to extend it with some conditions if possible, or rewrite it in a reusable code and create a new reusable function to use elsewhere.
- **Patch only the lines that need changing** - never rewrite an entire file just to modify a few lines
- Use precise edits with the `edit` tool to target specific text
- Use `write` only for new files or complete rewrites
- You are allowed to check changes between some commits or other details with `git` but do not commit or stash or discard changes without my permission

## Development Environments

### Project-Specific Dev Environments

- If a coding project has **no devenv config defined**, generate one with the needed packages **before** doing any development work
- Use `devenv` to create and manage project-specific development environments
- Keep project dependencies isolated in the project's devenv, not globally

### Global Packages

- Global packages should be defined in the **main Nix config** (not in project devenvs)
- **Always ask for confirmation** before adding any global package - the goal is to stay minimal
- Prefer project-level dependencies over global ones whenever possible
- Prefer tools that are written in Rust language

### Language

- Refer to `CONTEXT.md` to understand and use some specific terms

### Knowledge base

- When you learn something new about code base, you may create / update a file inside docs/ directory. Small parts of logic might go to spec/ directory. Make sure to explain everything by Domain Driven Design language, using vocabulary from `CONTEXT.md` that you can also evolve.
