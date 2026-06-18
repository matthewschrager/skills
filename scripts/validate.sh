#!/usr/bin/env bash
set -u

status=0
tracked_files="$(mktemp)"
trap 'rm -f "$tracked_files" /tmp/grill-to-goal-leaks.txt' EXIT

git ls-files --cached --others --exclude-standard > "$tracked_files"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  status=1
}

pass() {
  printf 'OK: %s\n' "$1"
}

required_files=(
  "README.md"
  "LICENSE"
  "CONTRIBUTING.md"
  "CHANGELOG.md"
  ".gitignore"
  "scripts/install.sh"
  "skills/grill-to-goal/SKILL.md"
  "skills/grill-to-goal/references/PLAN-FORMAT.md"
  "skills/grill-to-goal/vendor/mattpocock-domain-modeling/README.md"
  "skills/grill-to-goal/vendor/mattpocock-domain-modeling/LICENSE"
  "skills/grill-to-goal/vendor/mattpocock-domain-modeling/ADR-FORMAT.md"
  "skills/grill-to-goal/vendor/mattpocock-domain-modeling/CONTEXT-FORMAT.md"
  "skills/grill-to-goal/examples/feature-planning.md"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    fail "missing required file: $file"
  fi
done

if [[ $status -eq 0 ]]; then
  pass "required files exist"
fi

if [[ -f "scripts/install.sh" && ! -x "scripts/install.sh" ]]; then
  fail "scripts/install.sh must be executable"
fi

if [[ $status -eq 0 ]]; then
  pass "installer is executable"
fi

if [[ -e "skills/grill-to-goal/references/ADR-FORMAT.md" ]] ||
  [[ -e "skills/grill-to-goal/references/CONTEXT-FORMAT.md" ]]; then
  fail "context and ADR fallback files must live under vendor/, not references/"
fi

if [[ $status -eq 0 ]]; then
  pass "first-party references contain only owned docs"
fi

skill_file="skills/grill-to-goal/SKILL.md"

if [[ -f "$skill_file" ]]; then
  first_line="$(sed -n '1p' "$skill_file")"
  if [[ "$first_line" != "---" ]]; then
    fail "SKILL.md must start with YAML frontmatter"
  fi

  if ! grep -q '^name: grill-to-goal$' "$skill_file"; then
    fail "SKILL.md frontmatter must include name: grill-to-goal"
  fi

  if ! grep -q '^description: .*Use when ' "$skill_file"; then
    fail "SKILL.md description must include trigger language with 'Use when'"
  fi

  frontmatter_end_count="$(sed -n '1,8p' "$skill_file" | grep -c '^---$')"
  if [[ "$frontmatter_end_count" -lt 2 ]]; then
    fail "SKILL.md frontmatter must be closed"
  fi
fi

if [[ $status -eq 0 ]]; then
  pass "skill frontmatter is valid"
fi

vendor_readme="skills/grill-to-goal/vendor/mattpocock-domain-modeling/README.md"

if [[ -f "$vendor_readme" ]]; then
  if ! grep -q '^- Upstream repository: https://github.com/mattpocock/skills$' "$vendor_readme"; then
    fail "vendor README must record upstream repository"
  fi

  if ! grep -q 'skills/engineering/domain-modeling/CONTEXT-FORMAT.md' "$vendor_readme"; then
    fail "vendor README must record CONTEXT-FORMAT.md upstream path"
  fi

  if ! grep -q 'skills/engineering/domain-modeling/ADR-FORMAT.md' "$vendor_readme"; then
    fail "vendor README must record ADR-FORMAT.md upstream path"
  fi

  if ! grep -q '^- License: MIT$' "$vendor_readme"; then
    fail "vendor README must record MIT license"
  fi

  if ! grep -Eq '^- Vendored sync date: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$vendor_readme"; then
    fail "vendor README must record vendored sync date"
  fi

  if ! grep -Eq '^- Upstream commit: `[0-9a-f]{40}`$' "$vendor_readme"; then
    fail "vendor README must record upstream commit hash"
  fi
fi

if [[ $status -eq 0 ]]; then
  pass "vendor provenance metadata is valid"
fi

while IFS= read -r file; do
  lines="$(wc -l < "$file" | tr -d ' ')"
  if [[ "$lines" -gt 600 ]]; then
    fail "$file has $lines lines; keep files under 600 lines"
  fi
done < "$tracked_files"

if [[ $status -eq 0 ]]; then
  pass "file sizes are within limit"
fi

leak_targets=(
  "README.md"
  "CONTRIBUTING.md"
  "CHANGELOG.md"
  "skills"
  "scripts"
)

if grep -RInE '(/Users/|chief_of_staff|Nessie|gstack|\.claude)' "${leak_targets[@]}" 2>/dev/null \
  | grep -v '^scripts/validate.sh:' >/tmp/grill-to-goal-leaks.txt; then
  cat /tmp/grill-to-goal-leaks.txt >&2
  fail "possible private path or workflow leakage"
fi

if [[ $status -eq 0 ]]; then
  pass "no private path leakage found"
fi

while IFS= read -r md_file; do
  while IFS= read -r link; do
    [[ -z "$link" ]] && continue
    [[ "$link" =~ ^https?:// ]] && continue
    [[ "$link" =~ ^mailto: ]] && continue
    [[ "$link" =~ ^# ]] && continue

    link="${link%%#*}"
    link="${link%%\?*}"
    [[ -z "$link" ]] && continue

    target="$(dirname "$md_file")/$link"
    if [[ ! -e "$target" ]]; then
      fail "broken link in $md_file: $link"
    fi
  done < <(awk '/^```/ { in_fence = !in_fence; next } !in_fence { print }' "$md_file" \
    | grep -Eo '\[[^]]+\]\([^)]+\)' \
    | sed -E 's/^.*\]\(([^)#?]+).*$/\1/')
done < <(grep -E '\.md$' "$tracked_files")

if [[ $status -eq 0 ]]; then
  pass "internal Markdown links resolve"
fi

exit "$status"
