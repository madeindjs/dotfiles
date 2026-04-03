---
name: conventional-commits
description: Formats Git commit messages per Conventional Commits 1.0.0 (type, optional scope, imperative description, optional body and footers, breaking changes). Use when writing or suggesting commit messages, git commit, preparing commits, reviewing staged changes for a commit, or when the user mentions commits, changelog, or Conventional Commits.
---

# Conventional Commits (1.0.0)

Follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/). Spec rules below use RFC 2119 terms.

## Structure

```
<type>[optional scope][optional !]: <description>

[optional body]

[optional footer(s)]
```

- **Subject line**: single line; type prefix is mandatory; scope and `!` are optional; then `: ` (colon and single space); then short description.
- **Body**: optional; MUST start with one blank line after the subject.
- **Footers**: optional; MUST start one blank line after the body (or after subject if no body). Footer format: token, then `: ` or ` #`, then value (git trailer style).

## Type and scope

1. **Type** (required): a noun — commonly `feat` or `fix`; other types are allowed (e.g. `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`). Pick the primary intent of the change.
2. **`feat`**: new feature (maps to SemVer MINOR).
3. **`fix`**: bug fix (maps to SemVer PATCH).
4. **Scope** (optional): noun in parentheses after the type, describing a section of the codebase — e.g. `feat(parser):`, `fix(api):`. No space before `(`.

## Description (subject)

- MUST immediately follow `: ` after `type`, `type(scope)`, `type!`, or `type(scope)!`.
- Short summary of the change; imperative mood is conventional (e.g. "add", "fix", not "added" / "fixes").
- Spec: casing MAY vary; be consistent within the project.

## Breaking changes

- **In the header**: append `!` immediately before `:` — e.g. `feat!: ...` or `feat(api)!: ...`. Description SHOULD explain the break if you omit a `BREAKING CHANGE` footer.
- **In the footer**: `BREAKING CHANGE: <description>` (token MUST be uppercase; `BREAKING-CHANGE` is synonymous in footers).
- Breaking changes map to SemVer MAJOR regardless of type.

## Body

- Free-form; MAY be multiple paragraphs separated by blank lines.
- Use for motivation, context, or what changed vs. why if it does not fit the subject line.

## Footers

- Token MUST use `-` instead of spaces (e.g. `Reviewed-by:`, `Refs:`). Exception: `BREAKING CHANGE` / `BREAKING-CHANGE`.
- Common examples: `Refs: #123`, `Reviewed-by: Name`, pairs like `Acked-by:`.

## Workflow when drafting a message

1. Inspect the change (diff or summary): identify whether it is a feature, fix, docs-only, refactor, etc.
2. Choose **type** and optional **scope** (subsystem, package, or area).
3. Write the **subject** in one line: `<type>(<scope>): <description>` or `<type>: <description>`.
4. If the change is **breaking**, add `!` before `:` and/or a `BREAKING CHANGE:` footer with a clear migration note.
5. Add a **body** only if the subject is not enough (rationale, complex behavior).
6. Add **footers** for issue references, review metadata, or extra `BREAKING CHANGE` detail.

## Examples

**Minimal:**

```
docs: correct spelling of CHANGELOG
```

**With scope:**

```
feat(lang): add Polish language
```

**Breaking via `!`:**

```
feat!: send an email when a product is shipped
```

**Breaking via footer:**

```
feat: allow config object to extend other configs

BREAKING CHANGE: `extends` key in config is now used for extending other config files
```

**Body + footers:**

```
fix: prevent racing of requests

Introduce a request id and dismiss stale responses.

Reviewed-by: Z
Refs: #123
```

## Anti-patterns

- Missing type or missing `: ` after the prefix.
- Subject line too long (aim ~50–72 chars for the description part; wrap body instead).
- Mixing unrelated changes in one commit when they deserve separate types — prefer split commits.
- Wrong casing only for `BREAKING CHANGE` in footers: it MUST stay uppercase.
