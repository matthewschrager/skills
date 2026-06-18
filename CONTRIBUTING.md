# Contributing

This repository currently publishes one skill: `grill-to-goal`.

The quality bar is intentionally narrow. A useful public skill should be easy
to install, clear about when it triggers, portable across agent runtimes, and
free of private workflow assumptions.

## Scope

Good changes:

- clarify the workflow;
- improve examples;
- improve reference formats;
- resync vendored fallback files from upstream with updated provenance;
- make validation stricter without adding dependencies;
- remove private or platform-specific assumptions.

Avoid:

- adding unrelated skills before `grill-to-goal` is stable;
- adding package-manager dependencies for simple checks;
- expanding `SKILL.md` when a reference file would be clearer;
- editing vendored fallback files as if they were first-party docs;
- turning examples into long fictional case studies.

## Style

- Keep files under 600 lines.
- Keep `SKILL.md` concise; move detail into `references/`.
- Use plain Markdown and ASCII text.
- Prefer concrete agent behavior over motivational language.
- Explain trade-offs when a rule is surprising.

## Pull Request Checklist

Before opening a pull request:

```sh
scripts/validate.sh
git diff --check
```

Also confirm that new text does not assume a specific private repository,
company, user path, or agent command.

## Releases

Use semantic versions.

- Patch: wording fixes, examples, validation improvements.
- Minor: compatible workflow additions.
- Major: trigger semantics or output contract changes.
