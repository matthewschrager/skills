# Changelog

## Unreleased

## 0.1.1 - 2026-06-18

- Added named installer targets for Claude and Cursor local skill directories,
  and clarified that `.agents` is the shared local skills target.
- Refined README install, usage, and quick-example guidance, including a link to
  Matt Pocock's skills repository.
- Clarified how `grill-to-goal` uses Matt Pocock `grill-with-docs`, `grilling`,
  and `domain-modeling` guidance when installed.
- Added completion guidance to provide a copy/pasteable `/goal` implementation
  prompt.
- Removed `CONTRIBUTING.md` until contribution guidance is needed.
- Updated validation to allow that removal and skip deleted tracked files during
  pre-commit checks.

## 0.1.0

- Initial public release of `grill-to-goal`.
- Added portable skill instructions, a planning reference format, one example
  workflow, MIT license, contributor guide, and dependency-free validation.
- Moved Matt Pocock context and ADR guidance into a vendored fallback with
  provenance metadata.
- Added a local installer for Codex, `.agents`, and custom skill directories.
