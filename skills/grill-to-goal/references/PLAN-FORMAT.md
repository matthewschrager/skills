# Plan Format

The plan is the handoff from design grilling to implementation.

It should be concrete enough for a developer or implementation agent to execute
without the original conversation.

## Required Sections

Use these headings unless the target project already has a stricter local plan
format.

```md
# {Plan Title}

## Purpose

What problem this solves and why it matters.

## Scope

What is included.

## Non-Scope

What is explicitly excluded.

## Current State

Relevant docs, code paths, data models, workflows, and constraints.

## Target State

The intended behavior after implementation.

## Milestones

Ordered implementation steps. Each milestone should be independently
verifiable when practical.

## Progress

Checklist of completed and remaining work.

## Surprises And Discoveries

Facts found during grounding or implementation that changed the plan.

## Decision Log

Settled decisions, who made them when known, and why they were chosen.

## Implementation Details

Concrete files, APIs, data shapes, migrations, runtime behavior, and edge
cases.

## Test Plan

Exact commands and manual verification steps.

## Acceptance Criteria

The stopping conditions for implementation.

## Risks And Mitigations

Known failure modes and how to reduce them.

## Next Steps

The next action after the plan is accepted.

## Outcomes And Retrospective

Filled in after implementation, if the project keeps living plans.
```

## Acceptance Criteria Rules

Acceptance criteria should answer: "How will we know this is done?"

Strong criteria include:

- observable user or operator behavior;
- required persistence and durability behavior;
- schema, provenance, migration, or compatibility checks;
- safety and failure-mode behavior;
- regression coverage for nearby systems;
- exact commands to run;
- explicit non-goals and stop conditions.

Weak criteria sound like "make it better", "clean up the UI", or "support the
new flow" without saying what must be true.
