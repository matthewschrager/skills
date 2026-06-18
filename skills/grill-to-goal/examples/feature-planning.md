# Example: Feature Planning Session

This example shows the expected shape of a `grill-to-goal` interaction.

## User Prompt

```text
Use grill-to-goal to plan saved searches for our issue tracker. Users should be
able to save a filtered issue list and come back to it later.
```

## Agent Behavior

The agent should first inspect project docs and code. It should look for the
current issue model, existing filter syntax, route conventions, persistence
layer, permissions, and tests.

After grounding, it should avoid broad questions like:

```text
How should saved searches work?
```

It should ask a narrower question with a recommendation:

```text
Question: Should saved searches be personal to each user or shareable across
the workspace?

Recommended answer: personal-only for the first milestone.

Why: the existing permission model only distinguishes issue visibility by
workspace membership. Shareable saved searches would need ownership, sharing
rules, and UI affordances that do not exist yet. Personal-only gives users the
main workflow without creating a new authorization surface.
```

If the user accepts the recommendation, the agent records the decision in the
plan. If installed Matt Pocock domain-modeling guidance is available, the agent
should use it for any `CONTEXT.md` or ADR updates. If not, it should use the
vendored fallback and create an ADR only if the choice is hard to reverse,
surprising without context, and based on a real trade-off.

## Example Plan Excerpt

```md
## Scope

- Users can save the current issue filter as a named saved search.
- Users can view, rename, update, and delete their own saved searches.
- Saved searches are personal-only in this release.

## Non-Scope

- Workspace-shared saved searches.
- Public links.
- Notification rules.

## Acceptance Criteria

- A signed-in user can save the current issue filter with a required name.
- Saved searches persist across sessions and browser restarts.
- A user cannot read, update, or delete another user's saved search.
- Deleting a saved search removes it from navigation without changing issues.
- Existing issue filtering behavior is unchanged when no saved search is used.
- Automated tests cover create, read, update, delete, and authorization failure.
- Run `npm test` and `npm run lint`.
```
