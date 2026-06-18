---
name: grill-to-goal
description: Turns vague feature ideas into implementation-ready plans by reading repo docs/code, asking only unresolved design questions, capturing durable decisions, and writing concrete acceptance criteria. Use when a user wants to stress-test a proposed change, clarify domain language, or produce a plan an implementation agent can execute.
---

# Grill To Goal

Use this before implementation when the user wants a plan that has been tested
against the actual project.

This skill turns a repo-grounded grilling/design session into an implementation
handoff with confirmed project context, explicit scope and non-scope,
implementation milestones, verification commands, and acceptance criteria.

## Workflow

Use this workflow in all cases. When Matt Pocock's skills are installed, they
provide the preferred mechanics for steps 2 and 3. The local guidance below is
the standalone fallback and the handoff contract.

### 1. Ground The Session

- Read local planning or agent rules when present.
- Read domain context files, architecture notes, ADRs, and existing plans.
- Inspect the code paths that can answer factual questions.
- Identify what is already decided before involving the user.

Do not ask the user questions that the project can answer safely.

### 2. Grill The Design

Prefer Matt Pocock's `grill-with-docs` or `grilling` mechanics here when they
are installed. If unavailable, use this fallback:

Walk the design tree one decision at a time.

For each unresolved question:

- state the question briefly;
- give the recommended answer;
- explain the trade-off using project evidence where possible;
- wait for the user before moving to the next unresolved decision.

Auto-answer when:

- the project already has one clear pattern;
- the answer follows from a prior accepted decision;
- the answer is low-risk and asking would waste attention.

When auto-answering a meaningful decision, say so and record it.

### 3. Capture Durable Decisions

Prefer Matt Pocock's `domain-modeling` guidance here when it is installed. If
unavailable, use the vendored domain-modeling fallback at
[vendor/mattpocock-domain-modeling](vendor/mattpocock-domain-modeling/README.md).
Do not block the planning session just because preferred companion guidance is
not installed.

Update documentation as decisions settle.

- Add domain vocabulary to context docs only when the term matters to domain
  experts.
- Create ADRs only for decisions that are hard to reverse, surprising without
  context, and the result of a real trade-off.
- Keep implementation details out of context docs. Put them in ADRs or the
  implementation plan.

### 4. Distill The Plan

When the design is settled enough, create or update a plan using
[PLAN-FORMAT.md](references/PLAN-FORMAT.md).

The plan must be self-contained enough that another agent or developer can
implement it without relying on chat history.

## Acceptance Criteria

Acceptance criteria are the most important output.

Include:

- user-visible behavior;
- persistence, schema, provenance, and safety requirements;
- regression checks for adjacent systems;
- exact test, build, lint, or runtime verification commands;
- browser or runtime checks when UI behavior matters;
- explicit non-goals and stop conditions.

If live provider calls or paid APIs are allowed, state the budget and require
mock or fixture paths for automated tests.

## Completion

Before finishing:

- verify the plan has all required sections;
- summarize created or updated files;
- state that implementation has not started unless the user asked for it;
- list open questions only when they block execution.
