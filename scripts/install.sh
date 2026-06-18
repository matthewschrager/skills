#!/usr/bin/env bash
set -u

skill_name="grill-to-goal"
force=0
dry_run=0
yes=0
no_prompts=0
targets=()
target_dirs=()
dest_parents=()
dest_labels=()

usage() {
  cat <<'USAGE'
Usage:
  scripts/install.sh --target claude [--target codex] [--target-dir PATH]
  scripts/install.sh --target claude,codex,cursor

Options:
  --target NAME       Install to a named target. Supported: agents, claude,
                      codex, cursor.
                      Can be repeated or comma-separated.
  --target-dir PATH   Install to custom parent skills directory PATH.
  --force             Replace existing grill-to-goal install directories.
  --dry-run           Print planned actions without writing files.
  --yes               Answer yes to prompts.
  --no-prompts        Do not prompt; print optional recommendations only.
  -h, --help          Show this help.
USAGE
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

warn() {
  printf 'WARN: %s\n' "$1" >&2
}

info() {
  printf '%s\n' "$1"
}

canonical_path() {
  path="$1"
  suffix=""

  case "$path" in
    /*) ;;
    *) path="$PWD/$path" ;;
  esac

  if [[ -d "$path" ]]; then
    (CDPATH= cd -P -- "$path" && pwd -P)
    return
  fi

  while [[ ! -e "$path" && "$path" != "/" ]]; do
    suffix="/$(basename -- "$path")$suffix"
    path="$(dirname -- "$path")"
  done

  if [[ -d "$path" ]]; then
    (CDPATH= cd -P -- "$path" && printf '%s%s\n' "$(pwd -P)" "$suffix")
  elif [[ -e "$path" ]]; then
    parent="$(dirname -- "$path")"
    leaf="$(basename -- "$path")"
    (CDPATH= cd -P -- "$parent" && printf '%s/%s%s\n' "$(pwd -P)" "$leaf" "$suffix")
  fi
}

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(CDPATH= cd -- "$script_dir/.." && pwd)"
source_dir="$repo_root/skills/$skill_name"
source_real="$(canonical_path "$source_dir")"

add_target() {
  old_ifs="$IFS"
  IFS=','
  # shellcheck disable=SC2206
  parts=($1)
  IFS="$old_ifs"

  for part in "${parts[@]}"; do
    case "$part" in
      agents|claude|codex|cursor)
        targets+=("$part")
        ;;
      '')
        fail "empty target in --target"
        ;;
      *)
        fail "unknown target: $part"
        ;;
    esac
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || fail "--target requires a value"
      add_target "$2"
      shift 2
      ;;
    --target=*)
      add_target "${1#--target=}"
      shift
      ;;
    --target-dir)
      [[ $# -ge 2 ]] || fail "--target-dir requires a path"
      target_dirs+=("$2")
      shift 2
      ;;
    --target-dir=*)
      target_dirs+=("${1#--target-dir=}")
      shift
      ;;
    --force)
      force=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --yes)
      yes=1
      shift
      ;;
    --no-prompts)
      no_prompts=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "unknown option: $1"
      ;;
  esac
done

if [[ ${#targets[@]} -eq 0 && ${#target_dirs[@]} -eq 0 ]]; then
  usage >&2
  fail "at least one --target or --target-dir is required"
fi

required_source_files=(
  "$source_dir/SKILL.md"
  "$source_dir/references/PLAN-FORMAT.md"
  "$source_dir/vendor/mattpocock-domain-modeling/README.md"
  "$source_dir/vendor/mattpocock-domain-modeling/CONTEXT-FORMAT.md"
  "$source_dir/vendor/mattpocock-domain-modeling/ADR-FORMAT.md"
)

for file in "${required_source_files[@]}"; do
  [[ -f "$file" ]] || fail "missing source file: $file"
done

if [[ ${#targets[@]} -gt 0 ]]; then
  for target in "${targets[@]}"; do
    case "$target" in
      agents)
        dest_parents+=("$HOME/.agents/skills")
        dest_labels+=("agents")
        ;;
      claude)
        dest_parents+=("$HOME/.claude/skills")
        dest_labels+=("claude")
        ;;
      codex)
        dest_parents+=("$HOME/.codex/skills")
        dest_labels+=("codex")
        ;;
      cursor)
        dest_parents+=("$HOME/.cursor/skills-cursor")
        dest_labels+=("cursor")
        ;;
    esac
  done
fi

if [[ ${#target_dirs[@]} -gt 0 ]]; then
  for target_dir in "${target_dirs[@]}"; do
    [[ -n "$target_dir" ]] || fail "--target-dir cannot be empty"
    dest_parents+=("$target_dir")
    dest_labels+=("custom")
  done
fi

seen_file="$(mktemp)"
trap 'rm -f "$seen_file"' EXIT

for parent in "${dest_parents[@]}"; do
  dest="$parent/$skill_name"
  dest_real="$(canonical_path "$dest" 2>/dev/null || true)"

  if [[ -z "$dest_real" ]]; then
    parent_real="$(canonical_path "$parent" 2>/dev/null || true)"
    if [[ -n "$parent_real" ]]; then
      dest_real="$parent_real/$skill_name"
    fi
  fi

  if [[ "$dest_real" == "$source_real" || "$dest_real" == "$source_real"/* ]]; then
    fail "destination would overwrite source skill: $dest"
  fi

  if grep -Fxq "$dest_real" "$seen_file"; then
    fail "duplicate install destination: $dest"
  fi
  printf '%s\n' "$dest_real" >> "$seen_file"
done

for parent in "${dest_parents[@]}"; do
  dest="$parent/$skill_name"
  if [[ -e "$dest" && $force -ne 1 ]]; then
    fail "destination exists: $dest (use --force to replace)"
  fi
done

source_commit="unknown"
if command -v git >/dev/null 2>&1; then
  if git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    source_commit="$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
  fi
fi

info "Install plan:"
for i in "${!dest_parents[@]}"; do
  parent="${dest_parents[$i]}"
  label="${dest_labels[$i]}"
  info "  - $label -> $parent/$skill_name"
done

if [[ $dry_run -eq 1 ]]; then
  info "Dry run only. No files were written."
  exit 0
fi

for i in "${!dest_parents[@]}"; do
  parent="${dest_parents[$i]}"
  label="${dest_labels[$i]}"
  dest="$parent/$skill_name"

  mkdir -p "$parent" || fail "could not create parent directory: $parent"

  if [[ -e "$dest" && $force -eq 1 ]]; then
    rm -rf "$dest" || fail "could not remove existing destination: $dest"
  fi

  cp -R "$source_dir" "$dest" || fail "could not copy skill to: $dest"

  installed_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  {
    printf 'skill=%s\n' "$skill_name"
    printf 'installed_at=%s\n' "$installed_at"
    printf 'target=%s\n' "$label"
    printf 'install_parent=%s\n' "$parent"
    printf 'source_repo=%s\n' "$repo_root"
    printf 'source_commit=%s\n' "$source_commit"
    printf 'installer=scripts/install.sh\n'
  } > "$dest/.install-info" || fail "could not write install metadata: $dest/.install-info"

  info "Installed $skill_name to $dest"
done

mattpocock_installed=0
if [[ -f "$HOME/.agents/.skill-lock.json" ]] &&
  grep -q 'mattpocock/skills' "$HOME/.agents/.skill-lock.json"; then
  mattpocock_installed=1
fi

if [[ -f "$HOME/.agents/skills/grill-with-docs/SKILL.md" ]] ||
  [[ -f "$HOME/.agents/skills/setup-matt-pocock-skills/SKILL.md" ]]; then
  mattpocock_installed=1
fi

if [[ $mattpocock_installed -eq 1 ]]; then
  info "Matt Pocock skills detected. grill-to-goal will prefer them for glossary and ADR capture."
  exit 0
fi

install_mattpocock=0
if [[ $yes -eq 1 ]]; then
  install_mattpocock=1
elif [[ $no_prompts -eq 1 ]]; then
  info "Matt Pocock's domain-modeling/grill-with-docs skills are preferred for glossary and ADR capture."
  info "Install them later with: npx skills@latest add mattpocock/skills"
else
  printf 'Matt Pocock skills are preferred for glossary and ADR capture.\n'
  printf 'Install them now with `npx skills@latest add mattpocock/skills`? [y/N] '
  read -r answer
  case "$answer" in
    y|Y|yes|YES|Yes)
      install_mattpocock=1
      ;;
  esac
fi

if [[ $install_mattpocock -eq 1 ]]; then
  if ! command -v npx >/dev/null 2>&1; then
    warn "npx is not installed; skipping Matt Pocock skills install."
    info "Install them later with: npx skills@latest add mattpocock/skills"
    exit 0
  fi

  info "Running: npx skills@latest add mattpocock/skills"
  if ! npx skills@latest add mattpocock/skills; then
    warn "Matt Pocock skills install failed. grill-to-goal remains installed."
  fi
fi
