# Grill To Goal

Grill To Goal is an agent skill for turning an under-specified product or
engineering idea into an implementation-ready plan.

It makes the agent read the project first, challenge unresolved decisions one
at a time, capture durable decisions, and finish with acceptance criteria clear
enough for an implementation agent to execute.

## Why Use It

Use this skill when:

- a feature idea is directionally right but still fuzzy;
- a codebase already has docs, domain language, or architecture decisions that
  should shape the plan;
- you want the agent to ask fewer but sharper questions;
- implementation should not begin until the stopping conditions are explicit.

The skill is intentionally generic. It works with any agent runtime that can
load Markdown-based skills or project instructions. Codex-style skill loading
is supported, but not required.

## Repository Layout

```text
skills/
  grill-to-goal/
    SKILL.md
    references/
      PLAN-FORMAT.md
    vendor/
      mattpocock-domain-modeling/
        ADR-FORMAT.md
        CONTEXT-FORMAT.md
        LICENSE
        README.md
    examples/
      feature-planning.md
scripts/
  install.sh
  validate.sh
```

## Install

Clone this repository, then run the local installer.

For Claude local skills:

```sh
scripts/install.sh --target claude
```

For Codex local skills:

```sh
scripts/install.sh --target codex
```

For Cursor local skills:

```sh
scripts/install.sh --target cursor
```

For shared `.agents` local skills:

```sh
scripts/install.sh --target agents
```

Named targets install to:

| Target | Directory |
| --- | --- |
| `claude` | `$HOME/.claude/skills` |
| `codex` | `$HOME/.codex/skills` |
| `cursor` | `$HOME/.cursor/skills-cursor` |
| `agents` | `$HOME/.agents/skills` |

Install to multiple targets:

```sh
scripts/install.sh --target claude,codex,cursor
```

Install to a custom skills directory:

```sh
scripts/install.sh --target-dir "$HOME/.some-agent/skills"
```

For other agents, use `skills/grill-to-goal/SKILL.md` as the entrypoint and
keep the `references/` and `vendor/` directories beside it.

The installer writes only the `grill-to-goal` skill directory plus a generated
`.install-info` file. If an install destination already exists, rerun with
`--force` to replace it.

Useful installer options:

```sh
scripts/install.sh --target claude --dry-run
scripts/install.sh --target claude --force
scripts/install.sh --target claude --no-prompts
```

By default, the installer may offer to install Matt Pocock's companion skills
with `npx skills@latest add mattpocock/skills`. Those skills are preferred for
glossary and ADR capture, but `grill-to-goal` works without them by using its
vendored fallback.

## Usage

Ask your agent to use `grill-to-goal` before implementation starts:

```text
Use grill-to-goal to stress-test this feature idea and turn it into an
implementation-ready plan.
```

The expected output is not code. The expected output is a settled plan,
including concrete acceptance criteria and exact verification commands.

## Optional Matt Pocock Integration

`grill-to-goal` works standalone.

When Matt Pocock's `domain-modeling` or `grill-with-docs` guidance is
available in the current agent runtime, the skill tells the agent to use it for
`CONTEXT.md`, `CONTEXT-MAP.md`, and ADR capture.

When that guidance is not available, the skill falls back to a vendored
snapshot under `skills/grill-to-goal/vendor/mattpocock-domain-modeling/`.
That snapshot is MIT-licensed upstream material with explicit provenance. It
is not this repo's first-party planning format.

## Validation

Run the local validation script before publishing changes:

```sh
scripts/validate.sh
```

It checks required files, skill frontmatter, internal Markdown links, file
length, and accidental private-path leakage.

## License

MIT. See [LICENSE](LICENSE).
