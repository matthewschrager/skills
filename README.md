# Grill To Goal

`grill-to-goal` is an agent skill, inspired by Matt Pocock's agent skills, for
turning a vague product or engineering idea into an implementation-ready plan.

Use it before implementation when you want the agent to read the project,
challenge unresolved decisions, capture durable choices, and finish with clear
acceptance criteria.

## Install

Clone the repo:

```sh
git clone https://github.com/matthewschrager/skills.git
cd skills
```

Install the skill into your agent's local skills directory:

```sh
scripts/install.sh --target codex
```

When the installer offers to add Matt Pocock's skills, prefer installing them.
`grill-to-goal` works best when those skills are available.

Supported targets:

| Target | Installs to |
| --- | --- |
| `agents` | `$HOME/.agents/skills` |
| `claude` | `$HOME/.claude/skills` |
| `codex` | `$HOME/.codex/skills` |
| `cursor` | `$HOME/.cursor/skills-cursor` |

Install to multiple targets:

```sh
scripts/install.sh --target claude,codex,cursor
```

Install to a custom skills directory:

```sh
scripts/install.sh --target-dir "$HOME/.some-agent/skills"
```

If the destination already exists, replace it with:

```sh
scripts/install.sh --target codex --force
```

Preview the install without writing files:

```sh
scripts/install.sh --target codex --dry-run
```

Restart or reload your agent if it does not discover newly installed skills
automatically.

For agents without a named installer target, copy the full
`skills/grill-to-goal` directory into the agent's skills directory. Keep
`SKILL.md`, `references/`, and `vendor/` together.

## Use

Ask your agent to use the skill before it starts building:

```text
Use grill-to-goal to stress-test this feature idea and turn it into an
implementation-ready plan.
```

More specific prompts work well:

```text
Use grill-to-goal to plan saved searches for our issue tracker. Read the repo
first, ask only unresolved design questions, and stop before implementation.
```

The skill should produce a plan, not code. A good result includes:

- confirmed project context;
- unresolved design questions with recommended answers;
- durable decisions captured in docs when appropriate;
- scope and non-scope;
- implementation milestones;
- exact test or verification commands;
- acceptance criteria clear enough for another agent or developer to execute.

## Preferred Companion Skills

This skill is inspired by Matt Pocock's `domain-modeling` and
`grill-with-docs` skills. When your agent runtime can use those skills, prefer
installing them.

When Matt Pocock's `domain-modeling` or `grill-with-docs` guidance is installed,
the skill uses it for context docs, glossary work, and ADR capture. Otherwise it
uses the vendored fallback included in this repo so planning is not blocked.

Install the preferred skills with:

```sh
npx skills@latest add mattpocock/skills
```

## License

MIT. See [LICENSE](LICENSE).
